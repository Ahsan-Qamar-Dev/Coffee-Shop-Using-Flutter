// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';
import 'package:my_coffee_shop/DetailPage.dart';
import 'package:my_coffee_shop/LightText.dart';

class Tile2 extends StatelessWidget {
  final List<String> names;

  const Tile2({super.key, required this.names});

  // ===========================================================================
  // CURATED SPECIAL CARDS / ARTICLES
  // ===========================================================================

  final List<String> promoImages = const [
    "assets/Cappacuino.png",
    "assets/Espresso.jpg",
  ];

  final List<String> promoTitles = const [
    "5 Coffee Beans You Must Try!",
    "Best Way to Brew Dark Espresso",
  ];

  final List<String> promoSubtitles = const [
    "Hand-picked beans for top flavor",
    "Barista tips for maximum crema",
  ];

  final List<String> promoDescriptions = const [
    "Discover 5 premium coffee beans hand-picked for exceptional aroma, smooth finish, and balanced roast profile.",
    "Master the art of grinding, tamping, and extracting rich dark espresso right from your home machine.",
  ];

  final List<String> promoPrices = const [
    "10.50",
    "8.20",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: promoTitles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  title: promoTitles[index],
                  subtitle: promoSubtitles[index],
                  description: promoDescriptions[index],
                  imagePath: promoImages[index],
                  rating: "4.9",
                  price: promoPrices[index],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: 130,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Promo Image
                  Container(
                    height: 105,
                    width: 105,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(promoImages[index]),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Text Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BoldText(
                          text: promoTitles[index],
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        LightText(
                          text: promoSubtitles[index],
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            BoldText(text: "\$", size: 14, color: Colors.orange),
                            const SizedBox(width: 2),
                            BoldText(
                              text: promoPrices[index],
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}