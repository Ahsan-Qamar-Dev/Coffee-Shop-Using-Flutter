import 'package:flutter/material.dart';
import 'package:my_coffee_shop/models/coffee_model.dart';
import 'package:my_coffee_shop/views/detail_page.dart';
import 'package:my_coffee_shop/widgets/bold_text.dart';
import 'package:my_coffee_shop/widgets/light_text.dart';

class Tile2 extends StatelessWidget {
  final List<Coffee> specials;

  const Tile2({super.key, required this.specials});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF252525) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: specials.length,
      itemBuilder: (context, index) {
        final coffee = specials[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(coffee: coffee),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: 130,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                        image: AssetImage(coffee.imagePath),
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
                          text: coffee.name,
                          size: 15,
                          color: textColor,
                        ),
                        const SizedBox(height: 6),
                        LightText(
                          text: coffee.subtitle,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            BoldText(text: "\$", size: 14, color: Colors.orange),
                            const SizedBox(width: 2),
                            BoldText(
                              text: coffee.price.toStringAsFixed(2),
                              size: 14,
                              color: textColor,
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