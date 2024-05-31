import 'package:flutter/material.dart';

class RectangularSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RectangularSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? Colors.blue.shade900 : Colors.grey.shade300,
            width: 2,
          ),
          color: value ? Colors.blue.shade900 : Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? 20 : 0,
              right: value ? 0 : 20,
              top: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
