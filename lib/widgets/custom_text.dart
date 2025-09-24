import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double desiredLineHeight;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;
  final TextAlign textAlign;
  final TextDecoration textDecoration;

  const CustomText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.desiredLineHeight,
    required this.fontFamily,
    required this.fontWeight,
    this.color = Colors.black, // Default color is black if not specified
    this.letterSpacing = 0, // Default letterSpacing is 0 if not specified
    this.textAlign = TextAlign.left,
    this.textDecoration = TextDecoration.none,
  });

  @override
  Widget build(BuildContext context) {
    double lineHeight = desiredLineHeight / fontSize;

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        height: lineHeight,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
        // Other properties like color, font weight, etc.
      ),
    );
  }
}
