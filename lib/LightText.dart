// ignore_for_file: file_names, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class LightText extends StatelessWidget {
  final double size;
  final String text;
  final String font;
  final Color color;
  final TextOverflow textOverflow;

  LightText({
    super.key,
    this.textOverflow = TextOverflow.ellipsis,
    this.font = "font30",
    this.size = 20,
    this.color = Colors.white,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: textOverflow,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontFamily: font,
      ),
    );
  }
}