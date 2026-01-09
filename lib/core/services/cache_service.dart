import 'dart:async';
import 'dart:developer' show log;
import 'dart:io' show Directory, File;

import 'package:core/core.dart' show navigatorKey;
import 'package:core/core/extensions/string_extension.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart'
    show
        WidgetsBindingObserver,
        WidgetsBinding,
        AppLifecycleState,
        NetworkImage,
        FileImage,
        ImageProvider,
        precacheImage,
        ImageConfiguration,
        Size;
import 'package:http_cache_stream/http_cache_stream.dart'
    show HttpCacheManager, GlobalCacheConfig;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

enum ImageCacheSize {
  none, // no limit
  fullscreen, // fullscreen content
  expanded, // expanded content
  normal, // normal content
}

/// This service can be used to cache content for learning section, not for long term storage.
/// The cache is stored in the application's cache directory.
/// The cache is cleared when the section is completed.
class NodeCacheService {
  NodeCacheService() {
    _initCacheManager();
  }

  Future<void> _initCacheManager() async {
    final directory = await (kDebugMode
        ? getApplicationDocumentsDirectory()
        : getApplicationCacheDirectory());
    _cacheDirectory = Directory('${directory.path}/http_cache');
    log('NodeCacheService: cache directory: ${_cacheDirectory!.path}');
    await HttpCacheManager.init(
      config: GlobalCacheConfig(
        cacheDirectory: _cacheDirectory!,
        rangeRequestSplitThreshold: 1024 * 1024 * 2, // 2MB
        //onCacheDone: _handleHttpCacheDone,
        validateOutdatedCache: true,
      ),
    );
  }

  Directory? _cacheDirectory;
  // Map contains video or image url and its data (video player controller or image provider)
  final _videoUrlCacheMap = <String, Uri>{};
  final _imageCacheMap = <String, ImageProvider>{};
  final _audioUrlCache = <String, bool>{};
  // Map contains its video or image urls and a set of tags
  // Used to manage and clear cache by tag
  final _videoTagMap = <String, Set<String>>{};
  final _imageTagMap = <String, Set<String>>{};
  final _keepAliveList = <String>{};
  //final _keepAliveCacheManager = CacheManager(
  //  Config('node_keep_alive_cache', stalePeriod: const Duration(days: 30)),
  //);
  //CacheManager get keepAliveCacheManager => _keepAliveCacheManager;

  final imageCacheSizeMap = <ImageCacheSize, Size>{};
  bool useMpvPlayer = false;

  /// for Debug if any image / video is not dispose at the end
  final _cachedUrlSet = <String>{};
  final videoDownloadSpeedMap = <String, String>{};

  bool isImageCached(String imageUrl) {
    return _imageCacheMap.containsKey(imageUrl.trim());
  }

  bool isVideoCached(String videoUrl) {
    return _videoUrlCacheMap.containsKey(videoUrl.trim());
  }

  bool isAudioCached(String audioUrl) {
    return _audioUrlCache.containsKey(audioUrl.trim());
  }

  Future<void> refreshLocalServerCache() async {
    log('NodeCacheService: refreshLocalServerCache');
    await HttpCacheManager.instance.dispose();
    await _initCacheManager();
    final videoUrls = _videoUrlCacheMap.keys.toList();
    _videoUrlCacheMap.clear();
    for (var url in videoUrls) {
      final keepAlive = _keepAliveList.contains(url);
      await preCacheVideo(
        url,
        keepAlive: keepAlive,
        looping: keepAlive,
        volume: keepAlive ? 0 : null,
        tag: _videoTagMap[url]?.firstOrNull,
      );
    }
  }

  ImageProvider? getImageCacheUrl(String imageUrl) {
    final url = imageUrl.trim();
    if (url.isEmpty) return null;
    final stream = _imageCacheMap[url];
    log('NodeCacheService: image cache hit ${stream != null} $url');
    return stream;
  }

  Uri? getVideoCacheUri(String videoUrl) {
    final url = videoUrl.trim();
    if (url.isEmpty) return null;
    return _videoUrlCacheMap[url];
  }

  Future<void> preCacheAudio(String? audioUrl, {String? tag}) async {
    // TODO: later cache audio override previous audio
    return;
  }

  Future<void> preCacheVideos(
    List<String?> urls, {
    bool keepAlive = false,
    String? tag,
  }) async {
    for (var url in urls) {
      preCacheVideo(url, keepAlive: keepAlive, tag: tag);
    }
  }

  Future<void> preCacheImages(
    List<String?> urls, {
    bool keepAlive = false,
    String? tag,
  }) async {
    for (var url in urls) {
      preCacheImage(url, keepAlive: keepAlive, tag: tag);
    }
  }

  Future<void> preCacheImage(
    String? imageUrl, {
    bool keepAlive = false,
    String? tag,
    ImageCacheSize? size,
  }) async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      log('NodeCacheService: image called with empty URL.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    log('NodeCacheService: Image $url is pre caching');
    if (_imageCacheMap.containsKey(url)) {
      log('NodeCacheService: Image $url is already in cache map');
      _cachedUrlSet.add(url);
      _registerImageTag(url, tag);
      return;
    }
    final cacheSize = imageCacheSizeMap[size];
    if (keepAlive) {
      final cachedInfo = HttpCacheManager.instance.getCacheFiles(uri);
      if (cachedInfo.complete.existsSync()) {
        _keepAliveList.add(url);
        final provider = FileImage(cachedInfo.complete);
        _imageCacheMap[url] = provider;
        precacheImage(provider, navigatorKey.currentContext!, size: cacheSize);
        _cachedUrlSet.add(url);
        _registerImageTag(url, tag);
        log(
          'NodeCacheService: Image $url restored from keepAlive cache. ${cachedInfo.complete.path}',
        );
        return;
      }
    }
    final start = DateTime.now();
    try {
      final provider = NetworkImage(url);
      precacheImage(provider, navigatorKey.currentContext!, size: cacheSize);
      _imageCacheMap[url] = provider;
      _cachedUrlSet.add(url);
      _registerImageTag(url, tag);
      provider.obtainCacheStatus(configuration: ImageConfiguration.empty).then((
        e,
      ) {
        log(
          'NodeCacheService: Image $url is cached done. ${e.toString()} ${DateTime.now().difference(start).inMilliseconds}ms',
        );
      });
      log('NodeCacheService: Image $url is cached done');
    } catch (e) {
      log('NodeCacheService: Error during pre-caching for $url: $e.');
      if (keepAlive) {
        _keepAliveList.remove(url);
      }
    }
  }

  Future<void> preCacheVideo(
    String? videoUrl, {
    bool keepAlive = false,
    bool looping = false,
    double? volume,
    String? tag,
  }) async {
    final url = videoUrl?.trim();
    if (url == null || url.isEmpty) {
      log('NodeCacheService: preCacheVideo called with empty URL.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final cacheFile = HttpCacheManager.instance.getCacheFiles(uri);
    if (keepAlive) {
      _keepAliveList.add(url);
    }
    _registerVideoTag(url, tag);
    if (cacheFile.complete.existsSync()) {
      log(
        '==huyhuy NodeCacheService: Video $videoUrl is already cached in cache file ${cacheFile.complete.path} keepAlive $keepAlive',
      );
      _videoUrlCacheMap[url] = Uri.file(cacheFile.complete.path);
      return;
    }
    final stream = HttpCacheManager.instance.createStream(uri)..download();
    final startTime = DateTime.now();
    StreamSubscription<double?>? progressSubscription;
    progressSubscription = stream.progressStream.listen(
      (event) {
        if (event != null && event >= 1) {
          if (_videoUrlCacheMap.containsKey(url)) {
            _videoUrlCacheMap[url] = Uri.file(stream.cacheFile.path);
          }
          log(
            '==huyhuy NodeCacheService: Video $videoUrl is cached done. $event ${stream.cacheFile.path} keepAlive $keepAlive',
          );
        }
        _calculateDownloadSpeed(
          url,
          startTime,
          event,
          stream.metadata.sourceLength?.toDouble(),
        );
      },
      onDone: () {
        log(
          'NodeCacheService: Video $videoUrl is cached done. ${stream.cacheUrl}',
        );
        progressSubscription?.cancel();
      },
      onError: (error) {
        log('NodeCacheService: Video $videoUrl is cached error: $error');
        progressSubscription?.cancel();
        if (keepAlive) {
          _keepAliveList.remove(videoUrl);
        }
      },
    );
    _videoUrlCacheMap[url] = stream.cacheUrl;
  }

  Future<void> predownloadFile(
    String? videoUrl, {
    bool keepAlive = false,
  }) async {
    final url = videoUrl?.trim();
    if (url == null || url.isEmpty) {
      log('NodeCacheService: preCacheVideo called with empty URL.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (keepAlive) {
      _keepAliveList.add(url);
    }
    HttpCacheManager.instance.preCacheUrl(uri);
    log('NodeCacheService: predownloadFile keepAlive $keepAlive');
  }

  /// Remove audio URL from cache
  void removeCachedAudio(String audioUrl) {
    if (_audioUrlCache.containsKey(audioUrl)) {
      _audioUrlCache.remove(audioUrl);
      log('NodeCacheService: Removed audio $audioUrl from cache.');
    }
  }

  void _registerVideoTag(String url, String? tag) {
    final tagValue = tag?.trim();
    if (tagValue == null || tagValue.isEmpty) {
      return;
    }
    final tagSet = _videoTagMap.putIfAbsent(url, () => <String>{});
    tagSet.add(tagValue);
  }

  void _registerImageTag(String url, String? tag) {
    final tagValue = tag?.trim();
    if (tagValue == null || tagValue.isEmpty) {
      return;
    }
    final tagSet = _imageTagMap.putIfAbsent(url, () => <String>{});
    tagSet.add(tagValue);
  }

  void disposeImage(String imageUrl) {
    if (imageUrl.isEmpty) return;
    final tags = _imageTagMap[imageUrl];
    if (tags != null && tags.length > 1) {
      log(
        'NodeCacheService: disposeImage skipped for $imageUrl because of multiple tags $tags',
      );
      return;
    }
    final imageProvider = _imageCacheMap[imageUrl];
    if (imageProvider != null) {
      imageProvider.evict();
      _imageCacheMap.remove(imageUrl);
      _cachedUrlSet.remove(imageUrl);
      _imageTagMap.remove(imageUrl);
      log('NodeCacheService: disposeImage $imageUrl');
    }
  }

  Future<void> disposeVideos(List<String> videoUrls) async {
    for (final videoUrl in videoUrls) {
      await disposeVideo(videoUrl);
    }
  }

  Future<void> disposeVideo(String videoUrl, {bool deleteFile = false}) async {
    if (videoUrl.isEmpty) return;
    final tags = _videoTagMap[videoUrl];
    if (tags != null && tags.length > 1) {
      log(
        'NodeCacheService: disposeVideo skipped for $videoUrl because of multiple tags $tags',
      );
      return;
    }
    if (_videoUrlCacheMap.containsKey(videoUrl)) {
      _cachedUrlSet.remove(videoUrl);
      _videoTagMap.remove(videoUrl);
      if (_keepAliveList.contains(videoUrl)) {
        return;
      }
      try {
        final cachedUri = _videoUrlCacheMap[videoUrl];
        _videoUrlCacheMap.remove(videoUrl);
        HttpCacheManager.instance.getExistingStream(cachedUri!)?.dispose();
        if (deleteFile && cachedUri.scheme.startsWith('http') == false) {
          File(cachedUri.path).deleteSync();
        }
      } catch (e, st) {
        log(
          'NodeCacheService: Error during disposeVideo $videoUrl for $e. $st',
        );
      }
    }
  }

  void dispose() {
    HttpCacheManager.instance.dispose();
  }

  void clearCache({bool deleteAllDirectory = false}) {
    videoDownloadSpeedMap.clear();
    final oldCachedUrlSet = _cachedUrlSet.toList();
    if (deleteAllDirectory) {
      _keepAliveList.clear();
    }
    final imageCaches = _imageCacheMap.entries
        .where((e) => !_keepAliveList.contains(e.key))
        .toList();
    _imageCacheMap.removeWhere((key, value) => !_keepAliveList.contains(key));
    for (var e in imageCaches) {
      try {
        log('NodeCacheService: disposeImage ${e.key} in map');
        _imageTagMap.remove(e.key);
        _cachedUrlSet.remove(e.key);
      } catch (ex) {
        log('NodeCacheService: Error during disposeImage for $ex.');
      }
    }
    _audioUrlCache.removeWhere((key, value) => !_keepAliveList.contains(key));
    if (deleteAllDirectory) {}
    log(
      'NodeCacheService: clearCache done deleteAllDirectory $deleteAllDirectory  _keepAliveList $_keepAliveList image ${_imageCacheMap.length}',
    );
    log(
      'NodeCacheService: Cached URLs snapshot: $_cachedUrlSet previous: $oldCachedUrlSet',
    );
    oldCachedUrlSet.clear();
    _videoUrlCacheMap.clear();
    if (_cacheDirectory != null) _deleteDirectorySafely(_cacheDirectory!);
  }

  /// Xóa thư mục một cách an toàn với retry mechanism
  /// Xóa các file trong _cacheDirectory trừ:
  /// - Files có URL trong _keepAliveList (không bao giờ xóa)
  /// - Files khác có last access <= 7 ngày (giữ lại)
  void _deleteDirectorySafely(Directory directory) {
    if (!directory.existsSync()) {
      log('NodeCacheService: Directory does not exist: ${directory.path}');
      return;
    }

    try {
      // Build set of file paths that must be kept (from _keepAliveList)
      final filesToKeep = <String>{};

      // Mark all files from _keepAliveList as must keep (never delete)
      for (final url in _keepAliveList) {
        try {
          final uri = Uri.tryParse(url);
          if (uri == null) continue;

          final cacheFile = HttpCacheManager.instance.getCacheFiles(uri);
          if (cacheFile.complete.existsSync()) {
            filesToKeep.add(cacheFile.complete.path);
          }
          if (cacheFile.partial.existsSync()) {
            filesToKeep.add(cacheFile.partial.path);
          }
          if (cacheFile.metadata.existsSync()) {
            filesToKeep.add(cacheFile.metadata.path);
          }
          log('NodeCacheService: Marked files as keep (keepAlive): $url');
        } catch (e) {
          log('NodeCacheService: Error checking keepAlive cache for $url: $e');
        }
      }

      // Iterate through all files in directory
      // Delete files not in keepAlive list if last access > 7 days
      final files = directory.listSync(recursive: true);
      int deletedCount = 0;
      int keptCount = 0;

      for (final file in files) {
        if (file is File) {
          try {
            final filePath = file.path;

            // Skip if this file should be kept (from _keepAliveList)
            if (filesToKeep.contains(filePath)) {
              keptCount++;
              continue;
            }

            // Check last access date
            try {
              final lastAccessed = file.lastAccessedSync();
              final daysSinceAccess = DateTime.now()
                  .difference(lastAccessed)
                  .inDays;

              // Delete if over 7 days
              if (daysSinceAccess > 7) {
                file.deleteSync();
                deletedCount++;
                log(
                  'NodeCacheService: Deleted file (over 7 days): $filePath (accessed $daysSinceAccess days ago)',
                );
              } else {
                keptCount++;
                log(
                  'NodeCacheService: Keeping file (<= 7 days): $filePath (accessed $daysSinceAccess days ago)',
                );
              }
            } catch (e) {
              // If we can't read last access, delete as orphaned
              file.deleteSync();
              deletedCount++;
              log(
                'NodeCacheService: Deleted file (cannot read metadata): $filePath',
              );
            }
          } catch (e) {
            log('NodeCacheService: Failed to delete file ${file.path}: $e');
          }
        }
      }

      log(
        '==huyhuy NodeCacheService: Cleanup complete. Kept $keptCount files, deleted $deletedCount files',
      );
    } catch (e) {
      log(
        '==huyhuy NodeCacheService: Failed to delete directory ${directory.path}: $e',
      );
    }
  }

  Future<void> clearCacheByTag(String? tag) async {
    final tagValue = tag?.trim();
    if (tagValue == null || tagValue.isEmpty) {
      log('NodeCacheService: clearCacheByTag called with empty tag');
      return;
    }
    final imageTargets = <String>[];
    final imageEntries = _imageTagMap.entries.toList();
    for (final entry in imageEntries) {
      final tags = entry.value;
      if (!tags.contains(tagValue)) {
        continue;
      }
      if (tags.length == 1) {
        imageTargets.add(entry.key);
        _imageTagMap.remove(entry.key);
      } else {
        tags.remove(tagValue);
      }
    }
    for (final url in imageTargets) {
      disposeImage(url);
    }
    final videoTargets = <String>[];
    final videoEntries = _videoTagMap.entries.toList();
    for (final entry in videoEntries) {
      final tags = entry.value;
      if (!tags.contains(tagValue)) {
        continue;
      }
      if (tags.length == 1) {
        videoTargets.add(entry.key);
        _videoTagMap.remove(entry.key);
      } else {
        tags.remove(tagValue);
      }
    }
    for (final url in videoTargets) {
      _keepAliveList.remove(url);
      await disposeVideo(url);
    }
  }

  void updateImageTargetSize({
    required double normalWidth,
    required double normalHeight,
    required double expandedWidth,
    required double expandedHeight,
    required double fullscreenWidth,
    required double fullscreenHeight,
  }) {
    imageCacheSizeMap[ImageCacheSize.normal] = Size(normalWidth, normalHeight);
    imageCacheSizeMap[ImageCacheSize.expanded] = Size(
      expandedWidth,
      expandedHeight,
    );
    imageCacheSizeMap[ImageCacheSize.fullscreen] = Size(
      fullscreenWidth,
      fullscreenHeight,
    );
  }

  // debug
  void _calculateDownloadSpeed(
    String videoUrl,
    DateTime? startTime,
    double? progress,
    double? sourceLength,
  ) {
    if (videoDownloadSpeedMap[videoUrl]?.isNotEmpty == true ||
        startTime == null ||
        videoUrl.isEmpty ||
        sourceLength == null ||
        progress == null ||
        progress < 0 ||
        sourceLength <= 0) {
      return;
    }
    try {
      final elapsedSeconds =
          DateTime.now().difference(startTime).inMilliseconds / 1000;
      if (elapsedSeconds < 10 && progress < 1) return;
      log(
        'NodeCacheService: Download speed for $videoUrl: $elapsedSeconds $progress $sourceLength',
      );
      final downloadedBytes = (sourceLength * progress).round();
      final speedBytesPerSecond = downloadedBytes / elapsedSeconds;

      // Format speed
      String speedFormatted;
      if (speedBytesPerSecond < 1024) {
        speedFormatted = '${speedBytesPerSecond.toStringAsFixed(2)} B/s';
      } else if (speedBytesPerSecond < 1024 * 1024) {
        speedFormatted =
            '${(speedBytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
      } else {
        speedFormatted =
            '${(speedBytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
      }
      videoDownloadSpeedMap[videoUrl] = speedFormatted;
      log('NodeCacheService: Download speed for $videoUrl: $speedFormatted ');
    } catch (ex) {
      log('NodeCacheService: Error during _calculateDownloadSpeed for $ex.');
    }
  }
}
