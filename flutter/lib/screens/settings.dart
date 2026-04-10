import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_title.dart';

@RoutePage(name: 'Settings')
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(padding: .only(top: 10), child:AppTitle(text: 'Settings', style: AppTextStyles.pageTitle, strokeWidth: 1.5)),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(child: Text('Welcome to Screen 1')),
    );
  }
}
