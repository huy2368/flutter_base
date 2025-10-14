import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// Widget thông minh để hiển thị SVG từ network, tự động phát hiện và xử lý
/// trường hợp SVG có nhúng raster image (PNG/JPEG) bên trong
class XNetworkVectorImage extends StatelessWidget {
  const XNetworkVectorImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.error,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadWidget(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return placeholder ?? const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return error ?? const SizedBox.shrink();
        }
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _loadWidget() async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final contentType = res.headers['content-type'] ?? '';
    final bytes = res.bodyBytes;

    // Nếu không phải SVG content, render như image bình thường
    if (!contentType.contains('image/svg') && !_looksLikeSvg(bytes)) {
      return Image.memory(bytes, width: width, height: height, fit: fit);
    }

    final svgText = utf8.decode(bytes);

    // Phát hiện raster image được nhúng trong SVG (ví dụ: <image href="data:image/png;base64,...">)
    final embeddedRaster = _extractEmbeddedRasterBase64(svgText);
    if (embeddedRaster != null) {
      return Image.memory(
        embeddedRaster,
        width: width,
        height: height,
        fit: fit,
      );
    }

    // Render như SVG bình thường
    return SvgPicture.string(
      svgText,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }

  /// Kiểm tra xem bytes có phải là SVG không (heuristic đơn giản)
  bool _looksLikeSvg(Uint8List bytes) {
    // Kiểm tra header để tránh parse XML đầy đủ
    final head = utf8
        .decode(bytes.take(256).toList(), allowMalformed: true)
        .toLowerCase();
    return head.contains('<svg');
  }

  /// Trích xuất base64 raster image từ SVG
  Uint8List? _extractEmbeddedRasterBase64(String svg) {
    // Tìm pattern data:image/png;base64, hoặc data:image/jpeg;base64,
    final regex = RegExp(
      r'data:image/(?:png|jpeg|jpg);base64,([A-Za-z0-9+/=]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(svg);
    if (match == null) return null;

    try {
      final b64 = match.group(1)!;
      return base64.decode(b64);
    } catch (_) {
      return null;
    }
  }
}
