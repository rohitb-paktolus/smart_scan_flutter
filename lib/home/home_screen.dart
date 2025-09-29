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
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: open filter options
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, ROUTE_SCAN);
          },
          child: const Icon(Icons.scanner),
        ),
      ),
    );
  }
}
