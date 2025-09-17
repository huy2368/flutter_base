import 'package:core/core/navigator_key.dart';
import 'package:flutter/material.dart';

import '../ds/_xds.dart';
import '../extensions/_extensions.dart';
import 'x_image_picker.dart';
import 'x_modal_bottom_sheet.dart';

class XImagePickerBottomSheet {
  static Future<String?> show(String title) async {
    return await XModalBottomSheet.show([
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: navigatorKey.currentContext!.bodyL.semiBold),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          InkWell(
            onTap: () async => Navigator.pop(navigatorKey.currentContext!, await _openCamera()),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: _buildOption('Take a photo', Icons.camera_alt_outlined),
            ),
          ),
          InkWell(
            onTap: () async => Navigator.pop(navigatorKey.currentContext!, await _openGallery()),
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: _buildOption('Open gallery', Icons.image_search_rounded),
            ),
          ),
        ],
      ),
    ]);
  }

  static Widget _buildOption(String title, IconData iconData) {
    return Row(
      children: [
        Icon(iconData),
        const SizedBox(width: 8),
        Text(title, style: navigatorKey.currentContext!.bodyM),
      ],
    );
  }

  static Future<String?> _openCamera() async {
    final pickedFile = await XImagePicker.openCamera();

    if (pickedFile != null) {
      return pickedFile.path;
    }

    //if (stringImg64 == null) return null;
    //return 'data:image/png;base64,$stringImg64';
    return null;
  }

  static Future<String?> _openGallery() async {
    if (navigatorKey.currentContext == null) return null;
    //String? stringImg64;
    //final pickedFiles = await XImagePicker.pickImages(
    //  navigatorKey.currentContext!,
    //  maxAssets: 1,
    //);

    //if (pickedFiles.isNotEmpty) {
    //  return (await pickedFiles.first.file)?.path;
    //  //final bytes = await pickedFiles.first.thumbnailDataWithSize(
    //  //  const ThumbnailSize(300, 300),
    //  //);
    //  //stringImg64 = bytes != null ? base64Encode(bytes) : null;
    //}

    //if (stringImg64 == null) return null;
    //return 'data:image/png;base64,$stringImg64';
    return null;
  }
}
