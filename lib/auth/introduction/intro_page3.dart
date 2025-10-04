import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPageThree extends StatelessWidget {
  const IntroPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 128, 62, 42),
      body: Center(
        child: SizedBox(
          height: 460,
          width: 460,
          child: Column(
            children: [
              Lottie.asset('assets/animations/video_calling.json'),
              const SizedBox(height: 10),
              const Text(
                'Video Call with your dear ones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
