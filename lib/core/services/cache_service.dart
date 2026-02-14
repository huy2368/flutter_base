import 'dart:async';
import 'dart:developer' show log;
import 'dart:io' show Directory, File;

import 'package:core/core.dart' show navigatorKey;
import 'package:core/core/extensions/string_extension.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart'
    show NetworkImage, FileImage, ImageProvider, precacheImage, Size;
import 'package:http_cache_stream/http_cache_stream.dart'
    show HttpCacheManager, GlobalCacheConfig;
import 'package:path_provider/path_provider.dart';

/// This service can be used to cache content for learning section, not for long term storage.
/// The cache is stored in the application's cache directory.
/// The cache is cleared when the section is completed.
class CacheService {
  CacheService() {
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
  final _tagMap = <String, List<String>>{};
  final _keepAliveList = <String>{};
  final _fileQueue = <String>{};

  bool useMpvPlayer = false;

  /// for Debug if any image / video is not dispose at the end
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

  void setFileQueue(List<String> urls, {String? tag}) {
    _fileQueue
      ..clear()
      ..addAll(urls);
    for (final url in urls) {
      _registerTag(url.trim(), tag);
    }
  }

  void removeFromFileQueue(String url) {
    _fileQueue.remove(url);
  }

  void clearFileQueue() {
    _fileQueue.clear();
  }

  Future<void> refreshLocalServerCache() async {
    log('NodeCacheService: refreshLocalServerCache');
    try {
      await HttpCacheManager.instance.dispose();
    } catch (e) {
      log(
        'NodeCacheService: Error disposing HttpCacheManager (may not be initialized): $e',
      );
    }
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
        tag: _tagMap[url]?.firstOrNull,
      );
    }
  }

  ImageProvider? getImageCacheUrl(String imageUrl) {
    final url = imageUrl.trim();
    if (url.isEmpty) return null;
    if (_keepAliveList.contains(url)) {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;
      final cachedInfo = HttpCacheManager.instance.getCacheFiles(uri);
      if (cachedInfo.complete.existsSync()) {
        return FileImage(cachedInfo.complete);
      }
    }
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
    // ignore: dead_code
    if (audioUrl?.isNotEmpty != true) {
      log('NodeCacheService: preCacheAudio called with empty URL.');
      return;
    }
    if (_audioUrlCache.containsKey(audioUrl)) {
      log('NodeCacheService: Audio $audioUrl is already in cache.');
      return;
    }
    try {
      final uri = Uri.tryParse(audioUrl!);
      if (uri == null) {
        log('NodeCacheService: Invalid audio URL: $audioUrl');
        return;
      }

      // Mark as cached after successful preload
      _audioUrlCache[audioUrl] = true;
      log(
        'NodeCacheService: Audio $audioUrl successfully preloaded and cached.',
      );
    } catch (e) {
      log(
        'NodeCacheService: Error during pre-caching audio for $audioUrl: $e.',
      );
    }
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
    Size? size,
  }) async {
    for (var url in urls) {
      preCacheImage(url, keepAlive: keepAlive, tag: tag, size: size);
    }
  }

  Future<void> downloadFiles(List<String> urls) async {
    for (var url in urls) {
      await downloadFile(url);
    }
  }

  Future<File?> downloadFile(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty || !trimmedUrl.isURL) return null;
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null) return null;

    try {
      _keepAliveList.add(trimmedUrl);
      return await HttpCacheManager.instance.preCacheUrl(uri);
    } catch (e) {
      log('NodeCacheService: File Error during downloading $trimmedUrl: $e.');
    }
    return null;
  }

  File? getCachedFile(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty || !trimmedUrl.isURL) return null;
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null) return null;

    try {
      final cachedInfo = HttpCacheManager.instance.getCacheFiles(uri);
      if (cachedInfo.complete.existsSync()) {
        return cachedInfo.complete;
      }
    } catch (e) {
      log('NodeCacheService: Error getting cached file for $trimmedUrl: $e.');
    }
    return null;
  }

  Future<void> preCacheImage(
    String? imageUrl, {
    bool keepAlive = false,
    String? tag,
    Size? size,
  }) async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      log('NodeCacheService: image called with empty URL.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      log('NodeCacheService: Invalid image URL: $url');
      return;
    }
    log('NodeCacheService: Image $url is pre caching');
    _registerTag(url, tag);
    if (_imageCacheMap.containsKey(url)) {
      log('NodeCacheService: Image $url is already in cache map');
      return;
    }
    if (keepAlive) {
      _keepAliveList.add(url);
      final cachedInfo = HttpCacheManager.instance.getCacheFiles(uri);
      if (cachedInfo.complete.existsSync()) {
        final provider = FileImage(cachedInfo.complete);
        _imageCacheMap[url] = provider;
        precacheImage(provider, navigatorKey.currentContext!, size: size);
        log(
          'NodeCacheService: Image $url restored from keepAlive cache. ${cachedInfo.complete.path} ',
        );
        return;
      }
    }
    try {
      final provider = NetworkImage(url);
      precacheImage(provider, navigatorKey.currentContext!, size: size);
      _imageCacheMap[url] = provider;
    } catch (e) {
      log('NodeCacheService: Image Error during pre-caching for $url: $e.');
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
    if (keepAlive) {
      _keepAliveList.add(url);
    }
    if (_videoUrlCacheMap.containsKey(url)) return;
    _registerTag(url, tag);
    final cacheFile = HttpCacheManager.instance.getCacheFiles(uri);
    if (cacheFile.complete.existsSync()) {
      log(
        'NodeCacheService: Video $videoUrl tag $tag is already cached in cache file ${cacheFile.complete.path} keepAlive $keepAlive ${_videoUrlCacheMap.length} stream ${HttpCacheManager.instance.allStreams.where((e) => !e.isDisposed).length}',
      );
      _videoUrlCacheMap[url] = Uri.file(cacheFile.complete.path);
      videoDownloadSpeedMap[url] = 'CACHED';
      return;
    }
    final stream = HttpCacheManager.instance.createStream(uri)..download();
    _videoUrlCacheMap[url] = stream.cacheUrl;
    final startTime = DateTime.now();
    StreamSubscription<double?>? progressSubscription;
    progressSubscription = stream.progressStream.listen(
      (event) {
        if (event != null && event >= 1) {
          log(
            'NodeCacheService: Video $videoUrl is cached done. Switching to localfile. keepAlive $keepAlive all streams ${HttpCacheManager.instance.allStreams.length} downloading ${HttpCacheManager.instance.allStreams.where((e) => e.isDownloading).length} ${_videoUrlCacheMap.containsKey(url)}',
          );
          if (_videoUrlCacheMap.containsKey(url)) {
            _videoUrlCacheMap[url] = Uri.file(stream.cacheFile.path);
          }
          progressSubscription?.cancel();
          final downloadingStreamsLength = HttpCacheManager.instance.allStreams
              .where((e) => e.isDownloading)
              .length;
          if (downloadingStreamsLength < 2) {
            final nextUrl = _fileQueue.firstOrNull;
            if (nextUrl != null) {
              log(
                'NodeCacheService: done $url Pre-caching next video $nextUrl in queue $_fileQueue',
              );
              preCacheVideo(
                nextUrl,
                keepAlive: false,
                looping: looping,
                volume: volume,
                tag: tag,
              );
              removeFromFileQueue(nextUrl);
            }
          }
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
  }

  /// Remove audio URL from cache
  void removeCachedAudio(String audioUrl) {
    if (_audioUrlCache.containsKey(audioUrl)) {
      _audioUrlCache.remove(audioUrl);
      log('NodeCacheService: Removed audio $audioUrl from cache.');
    }
  }

  void _registerTag(String url, String? tag) {
    final tagValue = tag?.trim();
    if (tagValue == null || tagValue.isEmpty) {
      return;
    }
    final tagSet = _tagMap.putIfAbsent(url, () => <String>[]);
    if (!tagSet.contains(tagValue)) {
      tagSet.add(tagValue);
    }
  }

  void _removeFirstTag(String url) {
    final tagSet = _tagMap[url.trim()];
    if (tagSet != null && tagSet.isNotEmpty) {
      tagSet.removeAt(0);
    }
  }

  void disposeImage(String imageUrl) {
    final url = imageUrl.trim();
    if (url.isEmpty) return;
    final tags = _tagMap[url];
    if (tags != null && tags.length > 1) {
      log(
        'NodeCacheService: disposeImage skipped for $url because of multiple tags $tags',
      );
      _removeFirstTag(url);
      return;
    }
    final imageProvider = _imageCacheMap[url];
    if (imageProvider != null) {
      imageProvider.evict();
      _imageCacheMap.remove(url);
      _tagMap.remove(url);
      log('NodeCacheService: disposeImage $url');
    }
  }

  Future<void> disposeVideos(List<String> videoUrls) async {
    for (final videoUrl in videoUrls) {
      await disposeVideo(videoUrl);
    }
  }

  Future<void> disposeVideo(String videoUrl, {bool deleteFile = false}) async {
    final url = videoUrl.trim();
    if (url.isEmpty) return;
    final tags = _tagMap[url];
    if (tags != null && tags.length > 1) {
      log(
        'NodeCacheService: disposeVideo skipped for $url because of multiple tags $tags',
      );
      _removeFirstTag(url);
      return;
    }
    final length = _videoUrlCacheMap.length;

    if (_videoUrlCacheMap.containsKey(url)) {
      try {
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        _videoUrlCacheMap.remove(url);
        log(
          'NodeCacheService: disposeVideo $url stream ${HttpCacheManager.instance.getExistingStream(uri) != null ? 'exists' : 'not exists'}',
        );
        HttpCacheManager.instance.getExistingStream(uri)?.dispose();
        if (deleteFile &&
            !_keepAliveList.contains(url) &&
            uri.scheme.startsWith('http') == false) {
          File(uri.path).deleteSync();
        }
      } catch (e, st) {
        log('NodeCacheService: Error during disposeVideo $url for $e. $st');
      }
    }
    log(
      'NodeCacheService: disposeVideo $url stream ${HttpCacheManager.instance.allStreams.where((e) => !e.isDisposed).length} contain ${_videoUrlCacheMap.containsKey(url)} before $length after ${_videoUrlCacheMap.length} ${_videoUrlCacheMap.keys}',
    );
  }

  void dispose() {
    try {
      videoDownloadSpeedMap.clear();
      _fileQueue.clear();
      _videoUrlCacheMap.clear();
      _imageCacheMap.clear();
      _audioUrlCache.clear();
      _tagMap.clear();
      _keepAliveList.clear();
      HttpCacheManager.instance.dispose();
    } catch (e) {
      log('NodeCacheService: Error during dispose: $e');
    }
  }

  void clearCache({bool deleteAllDirectory = false}) {
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
        _tagMap.remove(e.key);
      } catch (ex) {
        log('NodeCacheService: Error during disposeImage for $ex.');
      }
    }
    _audioUrlCache.removeWhere((key, value) => !_keepAliveList.contains(key));
    log(
      'NodeCacheService: clearCache done deleteAllDirectory $deleteAllDirectory  _keepAliveList $_keepAliveList image ${_imageCacheMap.length}',
    );
    if (_cacheDirectory != null) {
      _deleteDirectorySafely(_cacheDirectory!, force: deleteAllDirectory);
    }
  }

  /// Xóa thư mục một cách an toàn với retry mechanism
  /// Xóa các file trong _cacheDirectory trừ:
  /// - Files có URL trong _keepAliveList (không bao giờ xóa)
  /// - Files khác có last access <= 7 ngày (giữ lại)
  void _deleteDirectorySafely(Directory directory, {bool force = false}) {
    if (!directory.existsSync()) {
      log('NodeCacheService: Directory does not exist: ${directory.path}');
      return;
    }

    try {
      // Build set of file paths that must be kept (from _keepAliveList)
      final filesToKeep = <String>{};
      if (!force) {
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
            log(
              'NodeCacheService: Error checking keepAlive cache for $url: $e',
            );
          }
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
              if (daysSinceAccess > 7 || force) {
                file.deleteSync();
                deletedCount++;
              } else {
                keptCount++;
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
        'NodeCacheService: Cleanup complete. Kept $keptCount files, deleted $deletedCount files',
      );
    } catch (e) {
      log('NodeCacheService: Failed to delete directory ${directory.path}: $e');
    }
  }

  Future<void> clearCacheByTag(String? tag) async {
    final tagValue = tag?.trim();
    if (tagValue == null || tagValue.isEmpty) {
      log('NodeCacheService: clearCacheByTag called with empty tag');
      return;
    }
    final imageTargets = <String>[];
    final imageEntries = _tagMap.entries.toList();
    for (final entry in imageEntries) {
      final tags = entry.value;
      if (!tags.contains(tagValue)) {
        continue;
      }
      if (tags.length == 1) {
        imageTargets.add(entry.key);
        _tagMap.remove(entry.key);
      } else {
        tags.remove(tagValue);
      }
    }
    for (final url in imageTargets) {
      disposeImage(url);
    }
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
