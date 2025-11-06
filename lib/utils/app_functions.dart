import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

import '../main.dart';

Future<void> showExitConfirmationDialog(BuildContext context, String alertMsg,
    String info, String navigationRout, bool isWithParam) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      surfaceTintColor: Colors.white,
      title: Text(alertMsg),
      content: Text(info),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (navigationRout == 'close') {
              Navigator.of(context).pop();
              SystemNavigator.pop();
              Future.delayed(
                const Duration(seconds: 1),
                () => exit(0),
              );
            } else {
              rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                navigationRout,
                (route) => false,
              );
            }
          },
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('No'),
        ),
      ],
    ),
  );
}

Future<String> getCurrentTimezoneName() async{
  final TimezoneInfo currentTimezoneInfo = await FlutterTimezone.getLocalTimezone();
  return currentTimezoneInfo.identifier;
}

String capitalize(String s) => s
    .split(RegExp(r'(?=[A-Z])'))
    .map((word) => word[0].toUpperCase() + word.substring(1))
    .join(' ');

String formatDateForDisplay(DateTime date) {
  final day = date.day;
  String suffix;

  // Handle 11th, 12th, 13th explicitly as they end in 'th'
  if (day >= 11 && day <= 13) {
    suffix = 'th';
  } else {
    switch (day % 10) {
      case 1:
        suffix = 'st';
        break;
      case 2:
        suffix = 'nd';
        break;
      case 3:
        suffix = 'rd';
        break;
      default:
        suffix = 'th';
        break;
    }
  }

  // UPDATED: Format the rest of the date using 'MMM' for abbreviated month name (e.g., Jun, Nov)
  final monthYear = DateFormat('MMM yyyy').format(date);

  // Combine day, suffix, month, and year
  return '$day$suffix $monthYear';
}