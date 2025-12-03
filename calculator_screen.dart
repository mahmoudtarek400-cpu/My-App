import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'widgets/buttons.dart';
import 'widgets/graph.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String display = "0"; // Display text
  double? firstValue;   // First number before operation
  String? operator;     // Current operation
  final List<double> history = []; // History for graph

  late AnimationController _controller; // Animation controller for graph

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  void inputNumber(String num) {
    HapticFeedback.selectionClick();
    setState(() {
      if (display == "0") display = num;
      else display += num;
    });
  }

  void inputDot() {
    if (!display.contains(".")) setState(() => display += ".");
  }

  void deleteLast() {
    HapticFeedback.lightImpact();
    setState(() {
      if (display.length > 1) display = display.substring(0, display.length - 1);
      else display = "0";
    });
  }

  void clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      display = "0";
      firstValue = null;
      operator = null;
    });
  }

  void setOperator(String op) {
    HapticFeedback.selectionClick();
    firstValue = double.tryParse(display);
    operator = op;
    display = "0"; // Start input for second number
  }

  void calculateResult() {
    HapticFeedback.heavyImpact();
    if (firstValue == null || operator == null) return;
    final secondValue = double.tryParse(display);
    if (secondValue == null) return;

    double result;
    switch (operator) {
      case '+':
        result = firstValue! + secondValue;
        break;
      case '-':
        result = firstValue! - secondValue;
        break;
      case '*':
        result = firstValue! * secondValue;
        break;
      case '/':
        if (secondValue == 0) {
          display = "Error";
          return;
        }
        result = firstValue! / secondValue;
        break;
      default:
        return;
    }

    setState(() {
      display = format(result);
      history.add(result);          
      _controller.forward(from: 0);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App title
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  "MAHMOUD CALC",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade400,
                    shadows: [
                      Shadow(
                        color: Colors.greenAccent.shade700,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Display screen
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Text(display,
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.greenAccent.shade400, blurRadius: 8),
                      ],
                    )),
              ),
              const SizedBox(height: 12),
              // History graph
              SizedBox(
                height: 150,
                child: CustomPaint(
                  painter: HistoryGraph(history: history, animation: _controller),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CustomButtons(
                      inputNumber: inputNumber,
                      inputDot: inputDot,
                      deleteLast: deleteLast,
                      clearAll: clearAll,
                      setOperator: setOperator,
                      calculateResult: calculateResult,
                    ),
                  ].expand((i) => i).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}