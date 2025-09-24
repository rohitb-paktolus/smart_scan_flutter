import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

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