import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';

@RoutePage(name: 'Settings')
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Screen 1')),
      body: const Center(child: Text('Welcome to Screen 1')),
    );
  }
}
