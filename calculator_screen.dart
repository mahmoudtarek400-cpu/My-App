import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/buttons.dart';
import 'widgets/graph.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxHistory = 50;

  String display = '0';
  double? firstValue;
  String? operator;
  final List<double> history = [];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetIfError() {
    if (display == 'Error') display = '0';
  }

  double? _tryParseDisplay() {
    if (display == 'Error') return null;
    return double.tryParse(display);
  }

  String _format(double value) {
    // removes -0.0
    if (value.abs() < 1e-12) value = 0;

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    final s = value.toStringAsPrecision(12);
    return s
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void inputNumber(String num) {
    HapticFeedback.selectionClick();
    setState(() {
      _resetIfError();
      display = (display == '0') ? num : (display + num);
    });
  }

  void inputDot() {
    HapticFeedback.selectionClick();
    setState(() {
      _resetIfError();
      if (!display.contains('.')) display += '.';
    });
  }

  void deleteLast() {
    HapticFeedback.lightImpact();
    setState(() {
      if (display == 'Error') {
        display = '0';
        return;
      }

      if (display.length > 1) {
        display = display.substring(0, display.length - 1);
      } else {
        display = '0';
      }
    });
  }

  void clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      display = '0';
      firstValue = null;
      operator = null;

      // لو عايز زرار C يمسح الجراف كمان فعّل السطر ده:
      // history.clear();
    });
  }

  void setOperator(String op) {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _tryParseDisplay();
      if (current == null) return;

      firstValue = current;
      operator = op;
      display = '0';
    });
  }

  void calculateResult() {
    HapticFeedback.heavyImpact();

    final a = firstValue;
    final op = operator;
    if (a == null || op == null) return;

    final b = _tryParseDisplay();
    if (b == null) return;

    double result;

    switch (op) {
      case '+':
        result = a + b;
        break;
      case '-':
        result = a - b;
        break;
      case '*':
        result = a * b;
        break;
      case '/':
        if (b == 0) {
          setState(() => display = 'Error');
          return;
        }
        result = a / b;
        break;
      default:
        return;
    }

    setState(() {
      display = _format(result);

      history.add(result);
      if (history.length > _maxHistory) {
        history.removeAt(0);
      }

      _controller.forward(from: 0);
    });
  }

  @override
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
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'MAHMOUD CALC',
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

              // Display
              Container(
                alignment: Alignment.centerRight,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.greenAccent.shade400,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Graph
              SizedBox(
                height: 150,
                child: CustomPaint(
                  painter: HistoryGraph(
                    history: history,
                    animation: _controller,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons (CustomButtons handles its own layout)
              Expanded(
                child: CustomButtons(
                  inputNumber: inputNumber,
                  inputDot: inputDot,
                  deleteLast: deleteLast,
                  clearAll: clearAll,
                  setOperator: setOperator,
                  calculateResult: calculateResult,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}