// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';
import 'package:my_coffee_shop/DetailPage.dart';
import 'LightText.dart';

class Tile extends StatelessWidget {
  final List<String> names;

  const Tile({super.key, required this.names});

  final List<String> coffeeImages = const [
    "assets/Cappacuino.png",
    "assets/latte-coffee-cup.jpg",
    "assets/Espresso.jpg",
    "assets/Americano.jfif",
    "assets/Mocha.jfif",
  ];

  // ☕ REAL SUBTITLES PER COFFEE
  final List<String> coffeeSubtitles = const [
    "With Steamed Milk",
    "With Creamy Foam",
    "Pure Double Shot",
    "Hot Water & Espresso",
    "With Dark Chocolate",
  ];

  // 📖 REAL DESCRIPTIONS PER COFFEE
  final List<String> coffeeDescriptions = const [
    "A cappuccino is an Italian coffee drink that is traditionally prepared with equal parts double espresso, steamed milk, and steamed milk foam on top.",
    "A latte is a classic espresso-based drink made with one or two shots of espresso, plenty of steamed milk, and a thin layer of light microfoam on top.",
    "Espresso is a concentrated form of coffee served in small, strong shots. It is brewed by forcing hot water under high pressure through finely-ground coffee beans.",
    "An Caffe Americano is prepared by diluting an espresso shot with hot water, giving it a similar strength to, but different flavor from, traditionally brewed coffee.",
    "A caffe mocha is a chocolate-flavored variant of a latte. Made with espresso, hot milk, and sweet dark chocolate syrup topped with velvety milk foam."
  ];

  final List<String> coffeePrices = const [
    "4.20",
    "3.80",
    "2.50",
    "3.00",
    "4.50",
  ];

  final List<String> coffeeRatings = const [
    "4.5",
    "4.2",
    "4.8",
    "4.0",
    "4.7",
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    title: names[index],
                    subtitle: coffeeSubtitles[index],
                    description: coffeeDescriptions[index],
                    imagePath: coffeeImages[index],
                    rating: coffeeRatings[index],
                    price: coffeePrices[index],
                  ),
                ),
              );
            },
            child: Container(
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
                        Container(
                          height: 160,
                          width: 140,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(coffeeImages[index]),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
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
                    padding: const EdgeInsets.only(
                      top: 170,
                      left: 10,
                      right: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BoldText(
                          text: names[index],
                          size: 16,
                          color: Colors.white,
                        ),
                        LightText(
                          text: coffeeSubtitles[index],
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
            ),
          );
        },
      ),
    );
  }
}