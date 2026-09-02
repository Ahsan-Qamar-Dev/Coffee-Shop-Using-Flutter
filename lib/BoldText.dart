
// ignore_for_file: file_names, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoldText extends StatelessWidget {
  final double size;
  final String font;
  final String text;
  final Color? color;
  final TextAlign? align;
  final TextOverflow textOverflow;

  BoldText({
    super.key,
    this.size = 20,
    this.align,
    this.textOverflow = TextOverflow.ellipsis,
    this.font = "font30",
    this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: size,
        color: color,
      ),
    );
  }
}