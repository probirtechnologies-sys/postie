import 'package:flutter/material.dart';
import 'package:postie/auth/boarding_screen.dart';
import 'package:postie/auth/screens/login_screen.dart';
import 'package:postie/auth/screens/otp_screen.dart';
import 'package:postie/auth/screens/user_information.dart';
// import 'package:postie/chat/screens/mobile_chat_screen.dart';
import 'package:postie/common/widgets/error.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case BoardingScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const BoardingScreen()));

    case LoginScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const LoginScreen()));
    case OTPScreen.routeName:
      // final verificationId = settings.arguments as String;
      final args = settings.arguments as Map<String, dynamic>;
      final verificationId = args['verificationId'];
      final phoneNumber = args['phoneNumber'];
      return MaterialPageRoute(
        builder: ((context) => OTPScreen(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
        )),
      );
    case UserInfoScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      final phoneNumber = args['phoneNumber'] as String;
      return MaterialPageRoute(
        builder: ((context) => UserInfoScreen(phoneNumber: phoneNumber)),
      );
    // case UserInfoScreen.routeName:
    //   return MaterialPageRoute(builder: (context) => const UserInfoScreen());
    // case SelectContactsScreen.routeName:
    //   return MaterialPageRoute(
    //     builder: (context) => const SelectContactsScreen(),
    //   );
    // case ChatScreen.routeName:
    //   final arguments = settings.arguments as Map<String, dynamic>;
    //   final name = arguments['name'];
    //   final uid = arguments['uid'];
    //   final profilePic = arguments['profilePic'];
    //   // final isGroupChat = arguments['isGroupChat'];
    //   return MaterialPageRoute(
    //     builder: (context) => ChatScreen(
    //       name: name,
    //       uid: uid,
    //       // isGroupChat: isGroupChat,
    //       profilePic: profilePic,
    //     ),
    //   );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: "This page does not exists."),
        ),
      );
  }
}
