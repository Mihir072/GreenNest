import 'package:flutter/material.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GSizes.borderRadiusLg))),
        child: Text(text,
            style: TextStyle(
                color: white,
                fontSize: GSizes.fontSizeMd,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
