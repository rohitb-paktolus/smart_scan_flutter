import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_text.dart';

class CustomToast extends StatelessWidget {
  const CustomToast({super.key, required this.text, this.freeWidth = 0});

  final String text;
  final double freeWidth;

  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE9F7E9),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/check_circle.svg',
              height: 20,
              width: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            CustomText(
              text: text,
              fontSize: 12,
              desiredLineHeight: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              color: const Color(0xFF318131),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
