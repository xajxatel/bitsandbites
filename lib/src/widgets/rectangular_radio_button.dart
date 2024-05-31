import 'package:flutter/material.dart';

class RectangularRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const RectangularRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : inactiveColor,
            width: 2,
          ),
          color: isSelected ? activeColor : Colors.transparent,
        ),
      ),
    );
  }
}
