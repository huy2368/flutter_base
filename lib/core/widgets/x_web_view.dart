import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class XWebView extends StatefulWidget {
  static const _httpPrefix = 'http';

  static Future<void> openUrl(
    BuildContext context, {
    String? url,
    String? title,
    Function()? callBack,
    bool addHeaders = false,
    void Function(String)? onRedirect,
  }) async {
    final isValidUrl =
        url != null && url.startsWith(_httpPrefix) && Uri.tryParse(url) != null;
    if (!isValidUrl) {
      log('Open webview with Invalid url $url');
      return;
    }
    final topSafeArea = navigatorKey.currentContext!.mediaData.padding.top;
    final height = navigatorKey.currentContext!.xheight - topSafeArea;

    String correctUrl = url;
    final uri = Uri.tryParse(url);
    if (uri?.hasScheme != true) {
      correctUrl = 'https://$correctUrl';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: height,
          child: XWebView(
            correctUrl,
            title: title,
            addHeaders: addHeaders,
            onRedirect: onRedirect,
          ),
        );
      },
    );

    callBack?.call();
  }

  final String? title;
  final String url;
  final bool addHeaders;
  final void Function(String)? onRedirect;

  const XWebView(
    this.url, {
    super.key,
    this.title,
    this.addHeaders = false,
    this.onRedirect,
  });

  @override
  State<StatefulWidget> createState() => _XWebViewState();
}

class _XWebViewState extends State<XWebView> {
  final _navigationBarHeight = 47.0;
  static final Set<Factory> _gestureRecognizers =
      <Factory<OneSequenceGestureRecognizer>>{
        const Factory(EagerGestureRecognizer.new),
      };
  final _isLoading = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.title != null)
          SizedBox(
            height: _navigationBarHeight,
            child: Row(
              children: <Widget>[
                const XBackButton(),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.title!,
                      maxLines: 2,
                      style: context.bodyM,
                    ),
                  ),
                ),
                // Make title center
                const SizedBox(width: 40),
              ],
            ),
          ),
        Expanded(child: _buildWebView(widget.url)),
      ],
    );
  }

  URLRequest? _urlRequest(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    return URLRequest(url: WebUri.uri(uri));
  }

  Widget _buildWebView(String url) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: _urlRequest(url),
          onWebViewCreated: (controller) {},
          onLoadStart: (_, __) => _isLoading.value = true,
          onConsoleMessage: (controller, consoleMessage) {
            log('onConsoleMessage $consoleMessage');
          },
          onLoadStop: (controller, url) {
            log('onLoadStop');
            _isLoading.value = false;
            widget.onRedirect?.call(url?.rawValue ?? '');
          },
          onProgressChanged: (controller, progress) {
            log('onProgressChanged  $progress');
          },
          gestureRecognizers:
              _gestureRecognizers
                  as Set<Factory<OneSequenceGestureRecognizer>>?,
        ),
        ValueListenableBuilder(
          valueListenable: _isLoading,
          builder: (context, value, child) => value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox(),
        ),
      ],
    );
  }
}
