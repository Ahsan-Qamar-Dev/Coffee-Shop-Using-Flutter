// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';
import 'package:my_coffee_shop/LightText.dart';

class Tile2 extends StatelessWidget {
  final List<String> names;

  const Tile2({super.key, required this.names});

  // ===========================================================================
  // DATA LISTS (CUSTOMIZE ITEMS FOR "SPECIAL FOR YOU")
  // ===========================================================================

  // 📸 CHANGE IMAGES HERE
  final List<String> specialImages = const [
    "assets/Cappacuino.png", // Image for Cappucino
    "assets/latte-coffee-cup.jpg", // Image for Latte
    "assets/Espresso.jpg", // Image for Espresso
    "assets/Americano.jfif", // Image for Americano
    "assets/Mocha.jfif", // Image for Mocha
  ];

  // 📝 CHANGE TITLES HERE
  final List<String> specialTitles = const [
    "5 Coffee Beans You\n Must Try!",
    "Creamy Latte\n Perfect Brew!",
    "Dark Espresso\n Energy Booster!",
    "Classic Americano\n Pure Taste!",
    "Rich Chocolate\n Mocha Special!",
  ];

  // 💬 CHANGE SUBTITLES HERE
  final List<String> specialSubtitles = const [
    "Rich & aromatic blend",
    "Smooth & velvety foam",
    "Strong double shot",
    "Hot water & espresso",
    "Espresso with cocoa",
  ];

  // 💵 CHANGE PRICES HERE
  final List<String> specialPrices = const [
    "4.20", // Price 1
    "5.10", // Price 2
    "3.90", // Price 3
    "4.75", // Price 4
    "6.00", // Price 5
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: names.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          height: 150,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 51, 48, 48),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Coffee Image Container
                Container(
                  height: 125,
                  width: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
           
                      image: AssetImage(specialImages[index]),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 15),

                // Right Side: Title + Subtitle + Price
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📝 TITLE LOADED DYNAMICALLY
                      BoldText(
                        text: specialTitles[index],
                        size: 15,
                        color: Colors.white,
                      ),
                      // 💬 SUBTITLE LOADED DYNAMICALLY
                      LightText(
                        text: specialSubtitles[index],
                        size: 11,
                        color: Colors.grey,
                      ),
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
                              // 💵 PRICE LOADED DYNAMICALLY
                              BoldText(
                                text: specialPrices[index],
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
    );
  }
}