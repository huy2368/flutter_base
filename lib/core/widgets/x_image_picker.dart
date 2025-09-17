import 'dart:io';

import 'package:image_picker/image_picker.dart';
//import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class XImagePicker {
  XImagePicker._();

  //static Future<List<AssetEntity>> pickImages(
  //  BuildContext context, {
  //  int maxAssets = 9,
  //  List<AssetEntity>? selectedAssets,
  //}) async {
  //  return await AssetPicker.pickAssets(
  //        context,
  //        pickerConfig: AssetPickerConfig(
  //          maxAssets: maxAssets,
  //          selectedAssets: selectedAssets,
  //          requestType: RequestType.image,
  //          themeColor: Colors.grey,
  //        ),
  //      ) ??
  //      [];
  //}

  static Future<File?> openCamera({
    double maxWidth = 300,
    double maxHeight = 300,
    int imageQuality = 100,
  }) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  //static Future<AssetEntity> saveImage(String filePath) async {
  //  return await PhotoManager.editor.saveImageWithPath(
  //    filePath,
  //    title: 'Mini-IELTS',
  //  );
  //}
}
