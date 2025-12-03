import 'package:flutter/material.dart';
import 'calculator_screen.dart';

void main() => runApp(const MahmoudCalcApp());

class MahmoudCalcApp extends StatelessWidget {
  const MahmoudCalcApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}