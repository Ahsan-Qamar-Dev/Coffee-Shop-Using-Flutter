import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../../core/widgets/shop_motion.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/coffee.dart';
import '../pages/detail_page.dart';

class Tile extends StatelessWidget {
  const Tile({super.key, required this.coffees});
  final List<Coffee> coffees;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final columns = math.max(
        1,
        (constraints.maxWidth / (scale > 1.4 ? 290 : 165)).floor(),
      );
      final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final coffee in coffees)
            SizedBox(
              width: width,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DetailsPage(coffee: coffee),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: AspectRatio(
                                aspectRatio: 1.05,
                                child: Image.asset(
                                  coffee.imagePath,
                                  fit: BoxFit.cover,
                                  cacheWidth: 512,
                                  semanticLabel: coffee.name,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Color(0xFFFFBF8D),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${coffee.rating}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          coffee.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          coffee.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              money(coffee.priceCentsFor('S')),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            CompactActionButton(
                              key: ValueKey('quick-add-${coffee.id}'),
                              tooltip: 'Add small ${coffee.name}',
                              onPressed: () {
                                Get.find<CartController>().addItem(coffee, 'S');
                                AppFeedback.show(
                                  context,
                                  'Added ${coffee.name} (S) to cart',
                                  actionLabel: 'View cart',
                                  onAction: () => openShopTab(context, 2),
                                );
                              },
                              icon: Icons.add_rounded,
                              confirmAddition: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
