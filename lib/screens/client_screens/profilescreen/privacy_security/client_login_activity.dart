import 'package:flutter/material.dart';

class LoginActivityScreen extends StatelessWidget {
  const LoginActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Activity")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text("Samsung Device"),
            subtitle: Text("Pakistan • Today"),
          ),
          ListTile(
            leading: Icon(Icons.computer),
            title: Text("Windows Laptop"),
            subtitle: Text("Yesterday"),
          ),
        ],
      ),
    );
  }
}
