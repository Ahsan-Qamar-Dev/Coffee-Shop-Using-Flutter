// ignore_for_file: file_names, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';
import 'package:my_coffee_shop/HomePage.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/Coffee_Cup.png",
              width: 200,
              height: 200,
            ),
          ),
           SizedBox(height: 25),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: Container(
              width: 300,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: BoldText(text: "Home Page", size: 28, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

