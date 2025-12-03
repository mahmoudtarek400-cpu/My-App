import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final Function(String) inputNumber;
  final VoidCallback inputDot, deleteLast, clearAll, calculateResult;
  final Function(String) setOperator;

  const CustomButtons({
    super.key,
    required this.inputNumber,
    required this.inputDot,
    required this.deleteLast,
    required this.clearAll,
    required this.setOperator,
    required this.calculateResult,
  });

  Widget build(BuildContext context) {
    // All buttons in GridView
    List<Widget> buttons = [
      clearButton(),
      opButton('/'),
      opButton('*'),
      delButton(),
      button('7'),
      button('8'),
      button('9'),
      opButton('-'),
      button('4'),
      button('5'),
      button('6'),
      opButton('+'),
      button('1'),
      button('2'),
      button('3'),
      equalButton(),
      button('0', flex: 2),
      dotButton(),
    ];

    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(12),
      children: buttons,
    );
  }

  // ----------------- Neon Buttons -----------------

  Widget button(String value, {int flex = 1}) => GestureDetector(
        onTap: () => inputNumber(value),
        child: neonContainer(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget dotButton() => GestureDetector(
        onTap: inputDot,
        child: neonContainer(
          child: const Text(
            '.',
            style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget delButton() => GestureDetector(
        onTap: deleteLast,
        child: neonContainer(
          color: Colors.purpleAccent,
          child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 28),
        ),
      );

  Widget clearButton() => GestureDetector(
        onTap: clearAll,
        child: neonContainer(
          color: Colors.redAccent,
          child: const Text('C', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );

  Widget equalButton() => GestureDetector(
        onTap: calculateResult,
        child: neonContainer(
          color: Colors.greenAccent,
          child: const Text('=', style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );

  Widget opButton(String op) => GestureDetector(
        onTap: () => setOperator(op),
        child: neonContainer(
          color: Colors.orangeAccent,
          child: Text(op, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );

  // ----------------- Neon Container -----------------
  Widget neonContainer({required Widget child, Color? color}) {
    final baseColor = color ?? Colors.cyanAccent;
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [baseColor.withOpacity(0.7), baseColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.7),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: baseColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}