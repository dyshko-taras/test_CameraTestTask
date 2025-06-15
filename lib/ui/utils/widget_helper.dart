import 'package:flutter/material.dart';

double getTopSafePadding(BuildContext context) {
  return MediaQuery.of(context).padding.top;
}

double getBottomSafePadding(BuildContext context) {
  return MediaQuery.of(context).padding.bottom;
}

Widget spacerHorizontal(double width) => SizedBox(width: width);

Widget spacerVertical(double height) => SizedBox(height: height);

Widget spacerAdaptive() => Expanded(child: Container());

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
