import 'package:flutter/material.dart';

import '../utils/prefs.dart';
import '../utils/route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onLogOut() {
    Prefs.clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(ROUT_LOGIN_EMAIL, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text("SmartScan", style: TextStyle(fontSize: 24)),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _onLogOut();
                },
                child: Text("Log Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
