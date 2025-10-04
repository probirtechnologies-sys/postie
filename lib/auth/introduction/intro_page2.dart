import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPageTwo extends StatelessWidget {
  const IntroPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 141, 134, 75),
      body: Center(
        child: SizedBox(
          height: 460,
          width: 460,
          child: Column(
            children: [
              Lottie.asset('assets/animations/group.json'),
              const SizedBox(height: 10),
              const Text(
                'Connect with new people',
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
