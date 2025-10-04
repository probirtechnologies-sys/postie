import 'package:flutter/material.dart';
import 'package:postie/common/utils/colours.dart';

class CustomBtn extends StatelessWidget {
  final String text;
  final double width;
  final VoidCallback onPressed;
  const CustomBtn({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(textColor),
          backgroundColor: WidgetStateProperty.all(tabColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: textColor, fontSize: 20),
        ),
      ),
    );
  }
}
