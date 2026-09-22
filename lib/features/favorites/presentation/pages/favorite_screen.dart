import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../catalog/presentation/pages/detail_page.dart';
import '../controllers/favorite_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  Widget build(BuildContext context) {
    final body = GetBuilder<FavoriteController>(
      builder: (favorites) => PageBody(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (favorites.favorites.isEmpty)
              EmptyState(
                icon: Icons.favorite_border,
                title: 'Save your favorites',
                message: 'Tap the heart on a coffee to keep it close.',
                action: 'Find a favorite',
                onAction: () => openShopTab(context, 0),
              )
            else ...[
              const SectionTitle(
                'Love at first sip',
                subtitle: 'Your favorites, all in one place.',
              ),
              for (final coffee in favorites.favorites)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).colorScheme.surface,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DetailsPage(coffee: coffee),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                coffee.imagePath,
                                height: 76,
                                width: 76,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
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
                                  const SizedBox(height: 4),
                                  Text(coffee.subtitle),
                                  const SizedBox(height: 8),
                                  Text(
                                    money(coffee.priceCentsFor('S')),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: ValueKey('favorite-add-${coffee.id}'),
                                  tooltip: 'Add small ${coffee.name} to cart',
                                  onPressed: () {
                                    Get.find<CartController>().addItem(
                                      coffee,
                                      'S',
                                    );
                                    AppFeedback.show(
                                      context,
                                      'Added ${coffee.name} (S) to cart',
                                      actionLabel: 'View cart',
                                      onAction: () => openShopTab(context, 2),
                                    );
                                  },
                                  icon: const Icon(Icons.add_shopping_cart),
                                ),
                                IconButton(
                                  tooltip: 'Unsave ${coffee.name}',
                                  onPressed: () {
                                    favorites.toggleFavorite(coffee);
                                    AppFeedback.show(
                                      context,
                                      'Removed ${coffee.name} from favorites',
                                      actionLabel: 'Undo',
                                      onAction: () =>
                                          favorites.toggleFavorite(coffee),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Color(0xFFE88376),
                                  ),
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
          ],
        ),
      ),
    );
    return embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: const Text('Favorites')),
            body: SafeArea(child: body),
          );
  }
}
