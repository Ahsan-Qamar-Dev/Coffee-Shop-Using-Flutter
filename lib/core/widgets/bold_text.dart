import 'package:flutter/material.dart';

class BoldText extends StatelessWidget {
  final double size;
  final String font;
  final String text;
  final Color? color;
  final TextAlign? align;
  final TextOverflow textOverflow;

  const BoldText({
    super.key,
    this.size = 20,
    this.align,
    this.textOverflow = TextOverflow.ellipsis,
    this.font = 'Poppins',
    this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Text(
      text,
      overflow: textOverflow,
      textAlign: align,
      style: TextStyle(
        fontFamily: font,
        fontWeight: FontWeight.bold,
        fontSize: size,
        color: color ?? defaultColor,
      ),
    );
  }
}
