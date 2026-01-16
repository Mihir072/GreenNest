import 'package:flutter/material.dart';

extension MediaQueryExtensions on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;

  double heightPct(double percent) => screenHeight * percent / 100;
  double widthPct(double percent) => screenWidth * percent / 100;
}








  // height: context.heightPct(25),
  // width: context.widthPct(80),
 
