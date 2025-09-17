import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgUtils {
  SvgUtils._();

  static Future<ui.Image> svgToImage(
    String svgStringContent,
    double targetWidth,
    double targetHeight,
  ) async {
    final SvgStringLoader svgStringLoader = SvgStringLoader(svgStringContent);
    final PictureInfo pictureInfo = await vg.loadPicture(svgStringLoader, null);
    final ui.Picture picture = pictureInfo.picture;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(
      recorder,
      Rect.fromPoints(Offset.zero, Offset(targetWidth, targetHeight)),
    );
    canvas.scale(
      targetWidth / pictureInfo.size.width,
      targetHeight / pictureInfo.size.height,
    );
    canvas.drawPicture(picture);
    return await recorder.endRecording().toImage(
      targetWidth.ceil(),
      targetHeight.ceil(),
    );
  }
}
