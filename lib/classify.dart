import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Classification extends StatefulWidget {
  const Classification({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClassificationState createState() => _ClassificationState();
}

class _ClassificationState extends State<Classification> {
  File? _image;
  List _results = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_image != null)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      "Classification Result",
                      style: TextStyle(
                        color: Colors.brown,
                        fontFamily: "Inter-Bold",
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.all(10), child: Image.file(_image!)),
                  Column(
                    children: _results != null
                        ? _results.map((result) {
                            return Column(
                              children: <Widget>[
                                SizedBox(
                                  width: 350,
                                  height: 70,
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${result["label"]} -  ${(result["confidence"] * 100).toStringAsFixed(1)}%",
                                        style: const TextStyle(
                                            letterSpacing: 3.0,
                                            fontSize: 20.0,
                                            color: Colors.black,
                                            fontFamily: "Inter-Bold",
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList()
                        : [],
                  ),
                 
                ],
              )
            else
              Column(
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 155,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFC8A18F),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                          ),
                          onPressed: () async {
                            final File? image =
                                await pickAnImage(ImageSource.gallery);
                            if (image == null) return;

                            imageClassification(image);
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Gallery",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 3.0,
                                    fontSize: 25.0,
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: "Inter-Regular"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                        height: 150,
                      ),
                      SizedBox(
                        width: 155,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFC8A18F),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                          ),
                          onPressed: () async {
                            final File? image =
                                await pickAnImage(ImageSource.camera);
                            if (image == null) return;

                            imageClassification(image);
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Camera",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 3.0,
                                    fontSize: 25.0,
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: "Inter-Regular"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(40),
                    child: const Opacity(
                      opacity: 0.6,
                      child: Center(
                        child: Text(
                          'No Image Selected!',
                          style: TextStyle(
                            letterSpacing: 3.0,
                            fontSize: 25.0,
                            color: Colors.grey,
                            fontFamily: "Inter-Regular",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              width: 200.0,
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }

  Future loadModel() async {
    Tflite.close();
    String? res;
    res = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
    print(res);
  }

  Future pickAnImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);

    if (image == null) return;
    return File(image.path);
  }

  Future imageClassification(File image) async {
    // Run tensorflowlite image classification model on the image
    final List? results = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = results!;
      _image = image;
    });
  }
}
