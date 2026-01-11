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

  String display = "0";
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

  double? _tryParseDisplay() {
    if (display == "Error") return null;
    return double.tryParse(display);
  }

  void _resetIfError() {
    if (display == "Error") display = "0";
  }

  String format(double value) {
    // remove -0.0 look
    if (value.abs() < 1e-12) value = 0;

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    // nicer formatting than fixed(4) in many cases
    final s = value.toStringAsPrecision(12);
    return s
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void inputNumber(String num) {
    HapticFeedback.selectionClick();
    setState(() {
      _resetIfError();
      if (display == "0") {
        display = num;
      } else {
        display += num;
      }
    });
  }

  void inputDot() {
    HapticFeedback.selectionClick();
    setState(() {
      _resetIfError();
      if (!display.contains(".")) display += ".";
    });
  }

  void deleteLast() {
    HapticFeedback.lightImpact();
    setState(() {
      if (display == "Error") {
        display = "0";
        return;
      }

      if (display.length > 1) {
        display = display.substring(0, display.length - 1);
      } else {
        display = "0";
      }
    });
  }

  void clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      display = "0";
      firstValue = null;
      operator = null;
      // لو عايز تمسح الجراف كمان:
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
      display = "0";
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
          setState(() => display = "Error");
          return;
        }
        result = a / b;
        break;
      default:
        return;
    }

    setState(() {
      display = format(result);

      history.add(result);
      if (history.length > _maxHistory) {
        history.removeAt(0);
      }

      _controller.forward(from: 0);
    });
  }

  List<Widget> _buildButtons() {
    // عشان يشتغل سواء CustomButtons بيرجع List/Iterable أو Widget
    final dynamic buttons = CustomButtons(
      inputNumber: inputNumber,
      inputDot: inputDot,
      deleteLast: deleteLast,
      clearAll: clearAll,
      setOperator: setOperator,
      calculateResult: calculateResult,
    );

    if (buttons is List<Widget>) return buttons;
    if (buttons is Iterable<Widget>) return buttons.toList();
    if (buttons is Widget) return [buttons];

    return const <Widget>[];
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

              // Buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _buildButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}