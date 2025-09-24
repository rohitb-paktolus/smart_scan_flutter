import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonTap;

  const CustomAlert({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2986CC),
              ),
              child: TextButton(
                onPressed: onButtonTap,
                child: CustomText(
                    text: buttonText,
                    fontSize: 16,
                    desiredLineHeight: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
