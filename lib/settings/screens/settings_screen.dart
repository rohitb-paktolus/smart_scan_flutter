import 'package:flutter/material.dart';

import '../../utils/prefs.dart';
import '../../utils/route.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _onLogOut(BuildContext context) {
    Prefs.clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(ROUT_LOGIN_EMAIL, (route) => false);
  }

  AppBar _buildAppBar() {
    return AppBar(title: Text("Settings"));
  }

  Widget _buildSettingsUI(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Log Out"),
          onTap: () {
            Navigator.pop(context);
            _onLogOut(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildSettingsUI(context));
  }
}
