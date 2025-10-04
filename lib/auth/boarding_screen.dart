import 'package:flutter/material.dart';
import 'package:postie/auth/introduction/intro_page1.dart';
import 'package:postie/auth/introduction/intro_page2.dart';
import 'package:postie/auth/introduction/intro_page3.dart';
import 'package:postie/auth/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BoardingScreen extends StatefulWidget {
  static const routeName = '/';
  const BoardingScreen({super.key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  bool onLastPage = false;
  void navigateToLoginScreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [IntroPageOne(), IntroPageTwo(), IntroPageThree()],
          ),
          Container(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.jumpToPage(2);
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SmoothPageIndicator(controller: controller, count: 3),
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          navigateToLoginScreen(context);
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
