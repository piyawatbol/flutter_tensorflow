// import 'dart:developer';

// import 'package:app/util/face_detector_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'camera_view.dart';

// import 'util/face_detector_painter.dart';

class CameraProcessScreen extends StatefulWidget {
  const CameraProcessScreen({Key? key}) : super(key: key);

  @override
  State<CameraProcessScreen> createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<CameraProcessScreen> {
  final options = ObjectDetectorOptions(
    mode: DetectionMode.stream,
    classifyObjects: true,
    multipleObjects: true,
  );

  bool _canProcess = true;
  bool _isBusy = false;

  ObjectDetector? objectDetector;

  @override
  void initState() {
    super.initState();
    objectDetector = ObjectDetector(options: options);
  }

  processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    final List<DetectedObject> objects =
        await objectDetector!.processImage(inputImage);

    if (objects.isEmpty) {
      print("No objects detected");
    }
    for (DetectedObject detectedObject in objects) {
      for (Label label in detectedObject.labels) {
        print('Label: ${label.text}');
      }
    }
  }

  @override
  void dispose() {
    _canProcess = false;
    objectDetector!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }
}
