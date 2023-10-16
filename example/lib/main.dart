import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_crafter/image_crafter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.a
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  @override
  Widget build(BuildContext context) {
    debugPrint("is image load to this3");
    return Scaffold(
      backgroundColor: _image != null ? Colors.black12 : null,
      appBar: AppBar(
        title: const Text("Select Image and Crop"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ClipRRect(
            //     borderRadius: BorderRadius.circular(150.0),
            //     child: Image.file(File(_image!.path), height: 300.0, width: 300.0, fit: BoxFit.fill,)
            // ),
            const SizedBox(
              height: 20.0,
            ),
            _image == null
                ? const Text("Select Image")
                : CircleAvatar(
                    radius: 100, // Adjust the radius as needed
                    backgroundColor:
                        Colors.grey, // Background color of the avatar
                    child: ClipOval(
                        child: Image.file(
                      _image!,
                      height: 300.0,
                      width: 300.0,
                      fit: BoxFit.fill,
                    )),
                  ),
            const SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                onPressed: () async {
                  File? image = await ImageUtility.imageFromGallery(
                    imageQuality: 60, aspectRatioPresetsForAndroid: [
                      CustomAspectRatio.square,
                      CustomAspectRatio.ratio7x5

                  ], aspectRatioPresetsForIos: [
                    CustomAspectRatio.square,
                    CustomAspectRatio.ratio7x5
                  ],
                  );
                  setState(() {
                    debugPrint("is image load to this1 ");
                    _image = image;
                  });
                  if (kDebugMode) {
                    if (_image != null) {
                      print("Gallery path ${_image!.path}");
                    }
                  }
                },
                child: const Text('Pick Image from Gallery')),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () async {
                  File? image =
                      await ImageUtility.imageFromCamera(imageQuality: 60, aspectRatioPresetsForAndroid: [
                        CustomAspectRatio.square,
                        CustomAspectRatio.ratio3x2
                      ], aspectRatioPresetsForIos: [
                        CustomAspectRatio.square,
                        CustomAspectRatio.ratio3x2
                      ]);
                  setState(() {
                    debugPrint("is image load to this2 ");
                    _image = image;
                  });
                  if (kDebugMode) {
                    if (_image != null) {
                      print("Camera path ${_image!.path}");
                    }
                  }
                },
                child: const Text('Pick Image from Camera'))
          ],
        ),
      ),
    );
  }
}
