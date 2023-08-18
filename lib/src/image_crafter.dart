import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';



class ImageUtility {

  static Future<File?> imageFromGallery ({required int imageQuality}){
    var image = selectAndCropImage(imageSource: ImageSource.gallery, imageQuality: imageQuality);
    return image;
  }

  static Future<File?> imageFromCamera ({required int imageQuality}){
    var image = selectAndCropImage(imageSource: ImageSource.camera, imageQuality: imageQuality);
    return image;
  }

  static Future<File?> selectAndCropImage({required ImageSource imageSource,required int imageQuality }) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    if (statuses[Permission.camera]!.isGranted || Platform.isIOS) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: imageSource);

      if (pickedImage != null) {
        XFile? finalImage = await cropImage(image: pickedImage, imageQuality: imageQuality);
        return File(finalImage!.path);
      }
    } else {
      openAppSettings();
      debugPrint('no permission provided');
    }
    return null;
  }

  static Future<XFile?> cropImage(
      {required XFile image, required int imageQuality}) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9,
      ]
          : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Image Cropper',
        ),
      ],
    );
    final mb = await getSizeOfImageInMB(image: XFile(croppedFile!.path));
    if (kDebugMode) {
      print('Original image size:$mb');
    }
    final result =
    await compressSizeOfImage(croppedFile: croppedFile, imageQuality: imageQuality);
    final newMB = await getSizeOfImageInMB(image: result);
    if (kDebugMode) {
      print('Reduced image size:$newMB');
    }
    if (result != null) {
      return XFile(result.path);
    }
    return null;
  }

  static Future<double?> getSizeOfImageInMB({required XFile? image}) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      final kb = bytes.length / 1024;
      final mb = kb / 1024;
      return mb;
    }
    return null;
  }

  static Future<XFile?> compressSizeOfImage(
      {required CroppedFile? croppedFile, required int imageQuality}) async {
    final dir = await path_provider.getTemporaryDirectory();
    final uniqueFileName =
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    if(croppedFile != null) {
      final result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        '${dir.absolute.path}/$uniqueFileName',
        minHeight: 1080,
        minWidth: 1080,
        quality: imageQuality,
      );
      return result ;
    }
    return null;
  }
}