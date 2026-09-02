// ignore_for_file: file_names, prefer_const_constructors_in_immutables


import 'package:flutter/material.dart';
import 'package:my_coffee_shop/IntroPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: const IntroPage(),
    );
  }
}