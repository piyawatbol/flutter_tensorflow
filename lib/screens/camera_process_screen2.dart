import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CameraProcessScreen2 extends StatefulWidget {
  const CameraProcessScreen2({Key? key}) : super(key: key);

  @override
  State<CameraProcessScreen2> createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<CameraProcessScreen2> {
  Interpreter? interpreter;
  List<String>? labels;
  final ImagePicker _picker = ImagePicker();
  // String modelPath = "assets/mobilenet_v1_1.0_224.tflite";
  // String modelPath = "assets/1.tflite";
  String modelPath = "assets/ssd_mobilenet.tflite";

  // String modelPath = "assets/mobilenet_v1_1.0_224_quant.tflite";
  // String labelPath = "assets/mobilenet_v1_1.0_224.txt";
  String labelPath = "assets/labelmap.txt";
  // String labelPath = "assets/labels_mobilenet_quant_v1_224.txt";
  // File? _image;

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // setState(() {
      //   _image = File(pickedFile.path);
      // });

      await processImage(pickedFile.path);
    }
  }

  Future<void> loadModel() async {
    print('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    // Use Metal Delegate
    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    print('Loading interpreter...');
    interpreter =
        await Interpreter.fromAsset("$modelPath", options: interpreterOptions);
    loadLabels();
  }

  /// Load Labels from assets
  Future<void> loadLabels() async {
    print('Loading labels...');
    final labelsRaw = await rootBundle.loadString("$labelPath");
    labels = labelsRaw.split('\n');
  }

  processImage(imagePath) {
    // Reading image bytes from file
    final imageData = File(imagePath!).readAsBytesSync();

// Decoding image
    final image = img.decodeImage(imageData);

// Resizing image fpr model, [300, 300]
    final imageInput = img.copyResize(
      image!,
      width: 300,
      height: 300,
    );

// Creating matrix representation, [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

// pass the imageMatrix to run on model
    final output = _runInference(imageMatrix);
    print('Processing outputs...');
// Location
    final locationsRaw = output.first.first as List<List<double>>;
    final locations = locationsRaw.map((list) {
      return list.map((value) => (value * 300).toInt()).toList();
    }).toList();
    print('Locations: $locations');

// Classes
    final classesRaw = output.elementAt(1).first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();
    print('Classes: $classes');

// Scores
    final scores = output.elementAt(2).first as List<double>;
    print('Scores: $scores');

// Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();
    print('Number of detections: $numberOfDetections');

    print('Classifying detected objects...');
    final List<String> classication = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classication.add(labels![classes[i]]);
    }
    print('Detected Classes:');
    for (var i = 0; i < numberOfDetections; i++) {
      if (scores[i] > 0.6) {
        print('${classication[i]}: ${scores[i]}');
      }
    }

    print('Outlining objects...');
    for (var i = 0; i < numberOfDetections; i++) {
      if (scores[i] > 0.6) {
        // Rectangle drawing
        img.drawRect(
          imageInput,
          x1: locations[i][1],
          y1: locations[i][0],
          x2: locations[i][3],
          y2: locations[i][2],
          color: img.ColorRgb8(255, 0, 0),
          thickness: 3,
        );

        // Label drawing
        img.drawString(
          imageInput,
          '${classication[i]} ${scores[i]}',
          font: img.arial14,
          x: locations[i][1] + 1,
          y: locations[i][0] + 1,
          color: img.ColorRgb8(255, 0, 0),
        );
      }
    }

    print('Done.');

    final outputImage = img.encodeJpg(imageInput);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Processed Image'),
          ),
          body: Center(
            child: Image.memory(outputImage),
          ),
        ),
      ),
    );

    // print(outputImage);
  }

  List<List<Object>> _runInference(
    List<List<List<num>>> imageMatrix,
  ) {
    print('Running inference...');

    // Set input tensor [1, 300, 300, 3]
    final input = [imageMatrix];

    // Set output tensor
    // Locations: [1, 10, 4]
    // Classes: [1, 10],
    // Scores: [1, 10],
    // Number of detections: [1]
    final output = {
      0: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      1: [List<num>.filled(10, 0)],
      2: [List<num>.filled(10, 0)],
      3: [0.0],
    };

    interpreter!.runForMultipleInputs([input], output);
    return output.values.toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Text("pickImg")),
        ),
      ),
    );
  }
}
