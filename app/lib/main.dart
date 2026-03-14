import 'package:flutter/material.dart';
import 'package:app/floating_suits_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SuitsBackgroundWrapper(
        child: Stack(
          children: const [
            Center(
              child: Text(
                "Card Game Menu",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 36,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
