import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final FontWeight fontWeight;
  const CustomText(
      {super.key,
      required this.text,
      required this.textColor,
      required this.textSize,
      required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: textColor,
          fontSize: textSize,
          fontWeight: fontWeight,
          fontFamily: 'Roboto'),
    );
  }
}
