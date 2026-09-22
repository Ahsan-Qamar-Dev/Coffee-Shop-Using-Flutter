import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../../core/widgets/shop_motion.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/coffee.dart';
import '../pages/detail_page.dart';

class Tile2 extends StatelessWidget {
  const Tile2({super.key, required this.specials});
  final List<Coffee> specials;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final coffee in specials)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        coffee.imagePath,
                        height: 88,
                        width: 88,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coffee.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            coffee.subtitle,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            money(coffee.priceCentsFor('S')),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CompactActionButton(
                            key: ValueKey('special-add-${coffee.id}'),
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
                            icon: Icons.add_shopping_cart,
                            confirmAddition: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
