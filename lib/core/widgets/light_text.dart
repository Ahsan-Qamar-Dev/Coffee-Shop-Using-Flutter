import 'package:flutter/material.dart';

class LightText extends StatelessWidget {
  final double size;
  final String text;
  final String font;
  final Color? color;
  final TextOverflow textOverflow;

  const LightText({
    super.key,
    this.textOverflow = TextOverflow.ellipsis,
    this.font = "font30",
    this.size = 20,
    this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey
        : Colors.grey.shade700;

    return Text(
      text,
      overflow: textOverflow,
      style: TextStyle(
        fontSize: size,
        color: color ?? defaultColor,
        fontFamily: font,
      ),
    );
  }
}
