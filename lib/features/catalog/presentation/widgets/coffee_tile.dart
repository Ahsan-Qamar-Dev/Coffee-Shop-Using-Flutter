import 'package:my_coffee_shop/core/widgets/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/features/catalog/domain/coffee.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';
import 'package:my_coffee_shop/core/widgets/bold_text.dart';
import 'package:my_coffee_shop/core/widgets/light_text.dart';

class Tile extends StatelessWidget {
  final List<Coffee> coffees;

  const Tile({super.key, required this.coffees});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E222A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (coffees.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, color: Colors.grey, size: 40),
              const SizedBox(height: 8),
              LightText(
                text: "No coffee found matching your search",
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.maxFinite,
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: coffees.length,
        itemBuilder: (context, index) {
          final coffee = coffees[index];
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
              margin: const EdgeInsets.only(right: 15),
              height: 250,
              width: 150,
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
                              image: AssetImage(coffee.imagePath),
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
                                text: coffee.rating.toString(),
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
                        BoldText(text: coffee.name, size: 16, color: textColor),
                        LightText(
                          text: coffee.subtitle,
                          size: 12,
                          color: Colors.grey,
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
                                  text: coffee.price.toStringAsFixed(2),
                                  size: 16,
                                  color: textColor,
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.find<CartController>().addItem(coffee, 'M');
                                AppFeedback.show(
                                  context,
                                  'Added ${coffee.name} (M) to cart',
                                );
                              },
                              child: Container(
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
