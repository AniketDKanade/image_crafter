import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

enum CustomAspectRatio {
  square,
  ratio3x2,
  original,
  ratio4x3,
  ratio7x5,
  ratio16x9,
}

/// A utility class for working with images in Flutter, including selecting images from the gallery
/// or camera, cropping them, and compressing their size.
class ImageUtility {
  /// Selects an image from the device's gallery, crops it, and compresses it.
  ///
  /// The [imageQuality] parameter determines the quality of the compressed image.List<CustomAspectRatio> customAspectRatios,
  ///
  /// Returns a [File] representing the compressed image, or `null` if no image was selected.
  static Future<File?> imageFromGallery({required int imageQuality,required List<CustomAspectRatio> aspectRatioPresetsForAndroid,
    required List<CustomAspectRatio> aspectRatioPresetsForIos ,String? toolbarTitle,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
    bool? lockAspectRatio,}) {
    return selectAndCropImage(
      imageSource: ImageSource.gallery,
      imageQuality: imageQuality, aspectRatioPresetsForAndroid: aspectRatioPresetsForAndroid, aspectRatioPresetsForIos: aspectRatioPresetsForIos,

    );
  }

  /// Captures an image from the device's camera, crops it, and compresses it.
  ///
  /// The [imageQuality] parameter determines the quality of the compressed image.
  ///
  /// Returns a [File] representing the compressed image, or `null` if no image was captured.
  static Future<File?> imageFromCamera({required int imageQuality,required List<CustomAspectRatio> aspectRatioPresetsForAndroid,
    required List<CustomAspectRatio> aspectRatioPresetsForIos,String? toolbarTitle,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
    bool? lockAspectRatio,}) {
    return selectAndCropImage(
      imageSource: ImageSource.camera,
      imageQuality: imageQuality, aspectRatioPresetsForAndroid:aspectRatioPresetsForAndroid, aspectRatioPresetsForIos: aspectRatioPresetsForIos,
    );
  }

  /// Selects an image from either the gallery or camera, crops it, and compresses it.
  ///
  /// The [imageSource] parameter specifies whether to use the gallery or camera as the image source.
  /// The [imageQuality] parameter determines the quality of the compressed image.
  ///
  /// Returns a [File] representing the compressed image, or `null` if no image was selected or captured.
  static Future<File?> selectAndCropImage({
    String? toolbarTitle,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
    bool? lockAspectRatio,
    required ImageSource imageSource,
    required int imageQuality,
    required List<CustomAspectRatio> aspectRatioPresetsForAndroid,
    required List<CustomAspectRatio> aspectRatioPresetsForIos,
  }) async {
    var permissionStatus = await checkPermission();

    if (permissionStatus || Platform.isIOS) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: imageSource);

      if (pickedImage != null) {
        XFile? finalImage = await cropImage(
          toolbarColor: toolbarColor,
          toolbarWidgetColor:toolbarWidgetColor ,
          lockAspectRatio:lockAspectRatio ,
          toolbarTitle:toolbarTitle ,


          image: pickedImage,
          imageQuality: imageQuality, aspectRatioPresetsForAndroid: aspectRatioPresetsForAndroid, aspectRatioPresetsForIos: aspectRatioPresetsForIos,
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
    required List<CustomAspectRatio> aspectRatioPresetsForAndroid,
    required List<CustomAspectRatio> aspectRatioPresetsForIos,
    String? toolbarTitle,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
    bool? lockAspectRatio
  }) async {

    final finalAspectRatioPresetsForAndroid = aspectRatioPresetsForAndroid.map((customAspectRatio) {
      CropAspectRatioPreset? cropAspectRatioPreset;

      // Map the custom enum to the CropAspectRatioPreset
      switch (customAspectRatio) {
        case CustomAspectRatio.square:
          cropAspectRatioPreset = CropAspectRatioPreset.square;
          break;
        case CustomAspectRatio.ratio3x2:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio3x2;
          break;
        case CustomAspectRatio.original:
          cropAspectRatioPreset = CropAspectRatioPreset.original;
          break;
        case CustomAspectRatio.ratio4x3:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio4x3;
          break;
        case CustomAspectRatio.ratio7x5:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio7x5;
          break;
        case CustomAspectRatio.ratio16x9:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio16x9;
          break;
      }
      return cropAspectRatioPreset;
    }).toList();

    final finalAspectRatioPresetsForIos = aspectRatioPresetsForIos.map((customAspectRatio) {
      CropAspectRatioPreset? cropAspectRatioPreset;

      // Map the custom enum to the CropAspectRatioPreset
      switch (customAspectRatio) {
        case CustomAspectRatio.square:
          cropAspectRatioPreset = CropAspectRatioPreset.square;
          break;
        case CustomAspectRatio.ratio3x2:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio3x2;
          break;
        case CustomAspectRatio.original:
          cropAspectRatioPreset = CropAspectRatioPreset.original;
          break;
        case CustomAspectRatio.ratio4x3:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio4x3;
          break;
        case CustomAspectRatio.ratio7x5:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio7x5;
          break;
        case CustomAspectRatio.ratio16x9:
          cropAspectRatioPreset = CropAspectRatioPreset.ratio16x9;
          break;
      }

      return cropAspectRatioPreset;
    }).toList();


    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: Platform.isAndroid
          ? finalAspectRatioPresetsForAndroid
          : finalAspectRatioPresetsForIos,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: toolbarTitle?? 'Image Cropper',
          toolbarColor: toolbarColor??Colors.deepOrange,
          toolbarWidgetColor:toolbarWidgetColor?? Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: lockAspectRatio?? false,
        ),
        IOSUiSettings(
          title: toolbarTitle ?? 'Image Cropper',
          aspectRatioLockEnabled: lockAspectRatio ?? false
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
