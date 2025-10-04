import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postie/auth/controller/auth_controller.dart';
import 'package:postie/common/utils/colours.dart';
import 'package:postie/common/utils/utils.dart';
import 'package:postie/common/widgets/custom_btn.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(
            context,
            '+${selectedCountry.phoneCode}$phoneNumber',
          );
    } else {
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  height: 200,
                  width: 200,
                  padding: const EdgeInsets.all(20.09),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: tabColor,
                  ),
                  child: Image.asset('assets/images/login.png'),
                ),
                // SizedBox(
                //   height: size.width * 0.009,
                // ),
                const Text(
                  'Register',
                  style: TextStyle(
                    color: tabColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.width / 100),
                const Text(
                  'Postie will need to verify your phone number to create an account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                SizedBox(height: size.width / 100),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  style: const TextStyle(color: textColor, fontSize: 18),
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.white12),
                    hintText: 'Enter your phone number',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            countryListTheme: const CountryListThemeData(
                              backgroundColor: Colors.grey,
                              bottomSheetHeight: 500,
                            ),
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = country;
                              });
                            },
                          );
                        },
                        child: Text(
                          "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? const Icon(Icons.done, color: tabColor)
                        : null,
                  ),
                  cursorColor: tabColor,
                ),
                SizedBox(height: size.height / 100),
                CustomBtn(
                  text: 'Continue',
                  width: 200,
                  onPressed: sendPhoneNumber,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
