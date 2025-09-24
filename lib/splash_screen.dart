import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/utils/pref_key.dart';
import 'package:smart_scan_flutter/utils/prefs.dart';

import '../../utils/route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      if (Prefs.getBool(LOGIN_FLAG)) {
        Navigator.pushReplacementNamed(context, ROUTE_HOME);
      } else {
        Navigator.pushReplacementNamed(context, ROUT_LOGIN_EMAIL);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/splash_screen.png',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
