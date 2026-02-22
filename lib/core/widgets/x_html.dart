import 'dart:developer';

import 'package:core/core/extensions/_extensions.dart';
import 'package:core/core/navigator_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'x_network_vector_image.dart';
import 'x_shimmer.dart';

class XHtml extends StatelessWidget {
  const XHtml(
    this.html, {
    this.style = const {},
    this.fontFamily,
    this.fontWeight,
    this.fontSize = 14,
    this.lineHeight = 1.5,
    this.fontColor,
    this.extensions = const [],
    this.shrinkWrap = false,
    super.key,
    this.linkTap,
  });

  final String? html;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double fontSize;
  final double lineHeight;
  final Color? fontColor;
  final Map<String, Style> style;
  final List<HtmlExtension> extensions;
  final bool shrinkWrap;
  final void Function(String)? linkTap;

  @override
  Widget build(BuildContext context) {
    if (html?.isNotEmpty != true) return const SizedBox();
    final effectiveFontFamily =
        fontFamily ?? context.xTheme.textTheme.bodyMedium?.fontFamily;
    final defaultStyle = {
      "*": Style(
        margin: Margins.zero,
        fontFamily: effectiveFontFamily,
        fontSize: FontSize(fontSize, Unit.px),
        color: fontColor,
        fontWeight: fontWeight,
        lineHeight: LineHeight(lineHeight),
      ),
      'p': Style(
        fontFamily: effectiveFontFamily,
        fontWeight: fontWeight,
        fontSize: FontSize(fontSize, Unit.px),
        verticalAlign: VerticalAlign.middle,
        alignment: Alignment.center,
      ),
      'h3': Style(
        fontSize: FontSize(fontSize + 2, Unit.px),
        fontFamily: effectiveFontFamily,
      ),
      "table": Style(
        height: Height.auto(),
        width: Width.auto(),
        padding: HtmlPaddings.zero,
        border: const Border(
          left: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 0.5),
          top: BorderSide(color: Colors.black, width: 1),
          right: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
      "tr": Style(height: Height.auto(), width: Width.auto()),
      "th": Style(padding: HtmlPaddings.all(6), height: Height.auto()),
      "td": Style(
        padding: HtmlPaddings.all(6),
        height: Height.auto(),
        width: Width.auto(),
        alignment: Alignment.centerLeft,
        display: Display.block,
        border: const Border(
          left: BorderSide(color: Colors.black, width: 0.5),
          bottom: BorderSide(color: Colors.black, width: 1),
          top: BorderSide(color: Colors.black, width: 0.5),
          right: BorderSide(color: Colors.black, width: 1),
        ),
        fontSize: FontSize(fontSize, Unit.px),
      ),
      "ul": Style(
        margin: Margins.only(left: 4),
        padding: HtmlPaddings.only(left: 12),
      ),
      "li": Style(margin: Margins.only(left: 4), padding: HtmlPaddings.zero),
    };
    Map<String, Style> mergedStyle;
    if (style.isNotEmpty) {
      mergedStyle = Map.of(style);
      for (var e in defaultStyle.entries) {
        mergedStyle.putIfAbsent(e.key, () => e.value);
      }
    } else {
      mergedStyle = defaultStyle;
    }

    return Html(
      data: html,
      style: mergedStyle,
      shrinkWrap: shrinkWrap,
      onLinkTap: (url, _, _) {
        if (linkTap != null) {
          linkTap!(url!);
        } else {
          launchUrlString(url!);
        }
      },
      extensions: [...extensions, const ImgHtmlExtension()],
    );
  }
}

class DelHtmlExtension extends HtmlExtension {
  const DelHtmlExtension();

  @override
  Set<String> get supportedTags => {'del'};

  @override
  InlineSpan build(ExtensionContext context) {
    return TextSpan(
      children: [
        TextSpan(
          text: context.innerHtml,
          style: navigatorKey.currentContext?.bodyM.copyWith(
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const TextSpan(text: ' '),
      ],
    );
  }
}

class ImgHtmlExtension extends HtmlExtension {
  const ImgHtmlExtension();

  @override
  Set<String> get supportedTags => {'img'};

  @override
  InlineSpan build(ExtensionContext context) {
    final imageUrl = context.element?.attributes['src'] ?? '';
    log('== $imageUrl');
    return WidgetSpan(
      child: imageUrl.toLowerCase().endsWith('.svg')
          ? XNetworkVectorImage(
              url: imageUrl,
              fit: BoxFit.contain,
              placeholder: const XShimmer(
                done: false,
                child: SizedBox(height: 200),
              ),
            )
          : Image.network(
              imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                final done =
                    loadingProgress == null ||
                    loadingProgress.cumulativeBytesLoaded >=
                        (loadingProgress.expectedTotalBytes ?? 0);

                return XShimmer(
                  done: done,
                  child: done
                      ? child
                      : SizedBox(width: context.xwidth - 32, height: 200),
                );
              },
              errorBuilder: (_, o, st) {
                log(o.toString());
                log(st?.toString() ?? '');
                return const SizedBox();
              },
            ),
    );
  }
}
