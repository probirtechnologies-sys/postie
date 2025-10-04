import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:postie/auth/controller/auth_controller.dart';
import 'package:postie/common/utils/colours.dart';
import 'package:postie/common/widgets/custom_btn.dart';

class OTPScreen extends ConsumerWidget {
  static const routeName = '/otp-screen';
  final String phoneNumber;
  final String verificationId;
  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  void verifyOTP(
    WidgetRef ref,
    BuildContext context,
    String userOTP,
    String phoneNumber,
  ) {
    ref
        .read(authControllerProvider)
        .verifyOTP(context, verificationId, userOTP, phoneNumber);
  }

  // final phoneController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: 300,
                  padding: const EdgeInsets.all(20.09),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: tabColor,
                  ),
                  child: Image.asset('assets/images/login.png'),
                ),
                SizedBox(height: size.height * 0.02),
                const Text(
                  'Verification',
                  style: TextStyle(
                    color: tabColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Enter the OTP sent to your mobile number $phoneNumber to verify ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                SizedBox(height: size.height * 0.03),
                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: PinTheme(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: tabColor),
                    ),
                    textStyle: const TextStyle(color: textColor),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    if (val.length == 6) {
                      verifyOTP(ref, context, val.trim(), phoneNumber);
                    }
                  },
                ),
                SizedBox(height: size.height * 0.2),
                CustomBtn(text: 'Verify', width: 200, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
