
# image_crafter
[![Pub Version](https://img.shields.io/pub/v/image_crafter)](https://pub.dev/packages/image_crafter)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

# Introduction
A Dart package that provides utility functions for selecting, cropping, and processing images, 
along with an example usage in a Flutter app.

## Supported platforms
- Android
- iOS

## Features

- Select images from the gallery or capture from the camera.
- Crop selected images to desired aspect ratios.
- Process and compress images while maintaining quality.

## Example
Check out the [example](https://github.com/AniketDKanade/image_crafter.git)


## Configuration

### iOS

Starting with version **0.8.1** the iOS implementation uses PHPicker to pick
(multiple) images on iOS 14 or higher.
As a result of implementing PHPicker it becomes impossible to pick HEIC images
on the iOS simulator in iOS 14+. This is a known issue. Please test this on a
real device, or test with non-HEIC images until Apple solves this issue.
[63426347 - Apple known issue](https://www.google.com/search?q=63426347+apple&sxsrf=ALeKk01YnTMid5S0PYvhL8GbgXJ40ZS[…]t=gws-wiz&ved=0ahUKEwjKh8XH_5HwAhWL_rsIHUmHDN8Q4dUDCA8&uact=5)

Add the following keys to your _Info.plist_ file, located in
`<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for
  the photo library. This is called _Privacy - Photo Library Usage Description_ in
  the visual editor.
    * This permission will not be requested if you always pass `false` for
      `requestFullMetadata`, but App Store policy requires including the plist
      entry.
* `NSCameraUsageDescription` - describe why your app needs access to the camera.
  This is called _Privacy - Camera Usage Description_ in the visual editor.

### Android

- Add UCropActivity into your AndroidManifest.xml

````xml

<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>

````
### Add permissions for Android
In the **android/app/src/main/AndroidManifest.xml** add:
```xml

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="true" />

```

* Make sure you set the compileSdkVersion in your "android/app/build.gradle" file to 33:

`````gradle
* android {
  compileSdkVersion 33
  ...
  }
`````

## Usage
### You can check permission status 


```dart
var permissionStatus = await ImageUtility.checkPermission();
 if(permissionStatus ){
 //
 }else{
 //Navigate to setting 
 }
```



```dart

File? image = await ImageUtility.imageFromGallery(imageQuality: 60);

File? image= await ImageUtility.imageFromCamera(imageQuality: 60 );

```
## Contributor
- Aniket kanade ([ZingWorks LLP](https://zingworks.in/))
