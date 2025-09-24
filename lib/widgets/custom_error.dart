import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_text.dart';

class CustomError extends StatelessWidget {
  const CustomError({super.key, required this.errorText});

  final String errorText;
  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEEBEB),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/report.svg',
              height: 20,
              width: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: CustomText(
                text: errorText,
                fontSize: 12,
                desiredLineHeight: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: const Color(0xFFF85A5A),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
