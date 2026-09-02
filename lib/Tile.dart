// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';

import 'LightText.dart';

class Tile extends StatelessWidget {
  final List<String> names;

  const Tile({super.key, required this.names});

  // ===========================================================================
  // DATA LISTS (CUSTOMIZE ITEMS PER COFFEE)
  // ===========================================================================

  // 📸 CHANGE IMAGES HERE (Must match names list order)
  final List<String> coffeeImages = const [
    "assets/Cappacuino.png", // Image for Cappucino
    "assets/latte-coffee-cup.jpg", // Image for Latte (Replace with your asset path)
    "assets/Espresso.jpg", // Image for Espresso
    "assets/Americano.jfif", // Image for Americano
    "assets/Mocha.jfif", // Image for Mocha
  ];

  // 💵 CHANGE PRICES HERE
  final List<String> coffeePrices = const [
    "4.20", // Price for Cappucino
    "3.80", // Price for Latte
    "2.50", // Price for Espresso
    "3.00", // Price for Americano
    "4.50", // Price for Mocha
  ];

  // ⭐ CHANGE RATINGS HERE
  final List<String> coffeeRatings = const [
    "4.5", // Rating for Cappucino
    "4.2", // Rating for Latte
    "4.8", // Rating for Espresso
    "4.0", // Rating for Americano
    "4.7", // Rating for Mocha
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 15),
            height: 250,
            width: 150,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 51, 48, 48),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      // Coffee Image
                      Container(
                        height: 160,
                        width: 140,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // 📸 IMAGE PATH IS DYNAMICALLY LOADED HERE
                            image: AssetImage(coffeeImages[index]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Rating Tag
                      Container(
                        margin: const EdgeInsets.only(left: 80),
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            // ⭐ RATING TEXT IS DYNAMICALLY LOADED HERE
                            BoldText(
                              text: coffeeRatings[index],
                              size: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 170, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BoldText(
                        text: names[index],
                        size: 16,
                        color: Colors.white,
                      ),
                      LightText(
                        text: "With Oat Milk",
                        size: 12,
                        color: const Color.fromARGB(
                          255,
                          205,
                          199,
                          199,
                        ).withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              BoldText(
                                text: "\$",
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 2),
                              // 💵 PRICE TEXT IS DYNAMICALLY LOADED HERE
                              BoldText(
                                text: coffeePrices[index],
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
