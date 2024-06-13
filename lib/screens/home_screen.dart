import 'package:flutter/material.dart';

// import 'camera_process_screen.dart';
import 'camera_process_screen2.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return CameraProcessScreen2();
                }));
              },
              child: Text("go"),
            ),
          ],
        ),
      ),
    );
  }
}
