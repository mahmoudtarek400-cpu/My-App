import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final ValueChanged<String> inputNumber;
  final VoidCallback inputDot;
  final VoidCallback deleteLast;
  final VoidCallback clearAll;
  final ValueChanged<String> setOperator;
  final VoidCallback calculateResult;

  const CustomButtons({
    super.key,
    required this.inputNumber,
    required this.inputDot,
    required this.deleteLast,
    required this.clearAll,
    required this.setOperator,
    required this.calculateResult,
  });

  static const double _radius = 24;
  static const EdgeInsets _padding = EdgeInsets.all(12);

  // Alpha helpers (avoid deprecated withOpacity)
  static int _alpha(double opacity) => (opacity * 255).round().clamp(0, 255);

  @override
  Widget build(BuildContext context) {
    // 4x4 grid (16 items) + bottom row (0 wide + .)
    final gridButtons = <Widget>[
      _actionButton(
        label: 'C',
        color: Colors.redAccent,
        onTap: clearAll,
        textColor: Colors.white,
      ),
      _opButton('/'),
      _opButton('*'),
      _iconButton(
        icon: Icons.backspace_outlined,
        color: Colors.purpleAccent,
        onTap: deleteLast,
      ),
      _numberButton('7'),
      _numberButton('8'),
      _numberButton('9'),
      _opButton('-'),
      _numberButton('4'),
      _numberButton('5'),
      _numberButton('6'),
      _opButton('+'),
      _numberButton('1'),
      _numberButton('2'),
      _numberButton('3'),
      _equalButton(),
    ];

    return Padding(
      padding: _padding,
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              children: gridButtons,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _numberButton('0'),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _dotButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------- Button Builders -----------------

  Widget _numberButton(String value) {
    return _tapTile(
      onTap: () => inputNumber(value),
      child: const Text(
        '', // will be replaced below via copyWith
      ).copyWithValue(value),
    );
  }

  Widget _dotButton() {
    return _tapTile(
      onTap: inputDot,
      child: const Text(
        '.',
        style: TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _opButton(String op) {
    return _tapTile(
      color: Colors.orangeAccent,
      onTap: () => setOperator(op),
      child: Text(
        op,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _equalButton() {
    return _tapTile(
      color: Colors.greenAccent,
      onTap: calculateResult,
      child: const Text(
        '=',
        style: TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return _tapTile(
      color: color,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 28,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _tapTile(
      color: color,
      onTap: onTap,
      child: const Icon(
        Icons.backspace_outlined, // will be replaced below via copyWith
      ).copyWithIcon(icon),
    );
  }

  // ----------------- Core Tile -----------------

  Widget _tapTile({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: _neonContainer(
          color: color,
          child: child,
        ),
      ),
    );
  }

  Widget _neonContainer({required Widget child, Color? color}) {
    final baseColor = color ?? Colors.cyanAccent;

    final glow70 = baseColor.withAlpha(_alpha(0.7));
    final glow50 = baseColor.withAlpha(_alpha(0.5));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        gradient: LinearGradient(
          colors: [glow70, baseColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: glow70,
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: glow50,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

/// Small helpers to keep code tidy without repeating styles.
extension _TextCopy on Text {
  Text copyWithValue(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 28,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

extension _IconCopy on Icon {
  Icon copyWithIcon(IconData iconData) {
    return Icon(
      iconData,
      color: Colors.white,
      size: 28,
    );
  }
}