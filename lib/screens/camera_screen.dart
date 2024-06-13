// import 'package:flutter/material.dart';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// import 'package:image_picker/image_picker.dart';

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   InputImage? inputImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> pickImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       final inputImage = InputImage.fromFilePath(pickedFile.path);
//       setState(() {
//         this.inputImage = inputImage;
//       });

//       processImage();
//     } else {
//       print("No image selected");
//     }
//   }

//   processImage() async {
//     if (inputImage == null) {
//       print("No input image");
//       return;
//     }

//     final options = LocalObjectDetectorOptions(
//       modelPath: "assets/mobilenet_v1_1.0_224.tflite",
//       mode: DetectionMode.stream,
//       classifyObjects: true,
//       multipleObjects: true,
//     );

//     final objectDetector = ObjectDetector(options: options);

//     final List<DetectedObject> objects =
//         await objectDetector.processImage(inputImage!);

//     if (objects.isEmpty) {
//       print("No objects detected");
//     }

//     for (DetectedObject detectedObject in objects) {
//       for (Label label in detectedObject.labels) {
//         print('Label: ${label.text}');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Container(
//         width: size.width,
//         height: size.height,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 pickImage();
//               },
//               child: Text("pick image"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
