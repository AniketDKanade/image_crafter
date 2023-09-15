import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

/// A utility class for working with images in Flutter, including selecting images from the gallery
/// or camera, cropping them, and compressing their size.
class ImageUtility {
  /// Selects an image from the device's gallery, crops it, and compresses it.
  ///
  /// The [imageQuality] parameter determines the quality of the compressed image.
  ///
  /// Returns a [File] representing the compressed image, or `null` if no image was selected.
  static Future<File?> imageFromGallery({required int imageQuality}) {
    return selectAndCropImage(
      imageSource: ImageSource.gallery,
      imageQuality: imageQuality,
    );
  }

  /// Captures an image from the device's camera, crops it, and compresses it.
  ///
  /// The [imageQuality] parameter determines the quality of the compressed image.
  ///
  /// Returns a [File] representing the compressed image, or `null` if no image was captured.
  static Future<File?> imageFromCamera({required int imageQuality}) {
    return selectAndCropImage(
      imageSource: ImageSource.camera,
      imageQuality: imageQuality,
    );
  }

  /// Selects an image from either the gallery or camera, crops it, and compresses it.
  ///
  /// The [imageSource] parameter specifies whether to use the gallery or camera as the image source.
  /// The [imageQuality] parameter determines the quality of the compressed image.
  ///
  /// Returns a [File] representing the compressed image, or `null` if no image was selected or captured.
  static Future<File?> selectAndCropImage({
    required ImageSource imageSource,
    required int imageQuality,
  }) async {
    var permissionStatus = await checkPermission();

    if (permissionStatus || Platform.isIOS) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: imageSource);

      if (pickedImage != null) {
        XFile? finalImage = await cropImage(
          image: pickedImage,
          imageQuality: imageQuality,
        );
        return File(finalImage!.path);
      }
    } else {
      openAppSettings();
      debugPrint('No permission provided');
    }

    return null;
  }

  /// Checks if the app has permission to access the device's camera.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> checkPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();

    return statuses[Permission.camera]?.isGranted ?? false;
  }

  /// Crops the selected image to a specified aspect ratio and quality.
  ///
  /// Returns a [File] representing the cropped image.
  static Future<XFile?> cropImage({
    required XFile image,
    required int imageQuality,
  }) async {
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
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Image Cropper',
        ),
      ],
    );

    final mb = await getSizeOfImageInMB(image: XFile(croppedFile!.path));
    if (kDebugMode) {
      print('Original image size: $mb');
    }

    final result = await compressSizeOfImage(
      croppedFile: croppedFile,
      imageQuality: imageQuality,
    );

    final newMB = await getSizeOfImageInMB(image: result);
    if (kDebugMode) {
      print('Reduced image size: $newMB');
    }

    if (result != null) {
      return XFile(result.path);
    }

    return null;
  }

  /// Calculates and returns the size of an image in megabytes (MB).
  ///
  /// Returns the size of the image in MB or `null` if the image is not provided.
  static Future<double?> getSizeOfImageInMB({required XFile? image}) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      final kb = bytes.length / 1024;
      final mb = kb / 1024;
      return mb;
    }
    return null;
  }

  /// Compresses the size of an image while maintaining a minimum width and height.
  ///
  /// Returns a [File] representing the compressed image.
  static Future<XFile?> compressSizeOfImage({
    required CroppedFile? croppedFile,
    required int imageQuality,
  }) async {
    final dir = await path_provider.getTemporaryDirectory();
    final uniqueFileName =
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (croppedFile != null) {
      final result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        '${dir.absolute.path}/$uniqueFileName',
        minHeight: 1080,
        minWidth: 1080,
        quality: imageQuality,
      );
      return result;
    }
    return null;
  }
}
