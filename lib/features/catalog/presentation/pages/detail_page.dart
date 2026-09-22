import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../../core/widgets/shop_motion.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../favorites/presentation/controllers/favorite_controller.dart';
import '../../domain/coffee.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.coffee});
  final Coffee coffee;
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String _size = 'S';
  @override
  Widget build(BuildContext context) {
    final coffee = widget.coffee;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee details'),
        actions: [
          GetBuilder<CartController>(
            builder: (cart) => IconButton(
              tooltip: 'View cart',
              onPressed: () => openShopTab(context, 2),
              icon: Badge(
                isLabelVisible: cart.itemCount > 0,
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          GetBuilder<FavoriteController>(
            builder: (favorites) {
              final saved = favorites.isFavorite(coffee);
              return IconButton(
                tooltip: saved ? 'Remove from favorites' : 'Save to favorites',
                icon: AnimatedValue(
                  value: saved,
                  child: Icon(
                    saved ? Icons.favorite : Icons.favorite_border,
                    color: saved ? const Color(0xFFE88376) : null,
                  ),
                ),
                onPressed: () {
                  favorites.toggleFavorite(coffee);
                  AppFeedback.show(
                    context,
                    saved
                        ? 'Removed ${coffee.name} from favorites'
                        : 'Added ${coffee.name} to favorites',
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageBody(
          maxWidth: 900,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 390),
                  child: AspectRatio(
                    aspectRatio: 1.12,
                    child: Image.asset(
                      coffee.imagePath,
                      fit: BoxFit.cover,
                      cacheWidth: 1400,
                      semanticLabel: coffee.name,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                coffee.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                coffee.subtitle,
                style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.star_rounded, size: 18),
                    label: Text('${coffee.rating} · Menu rating'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.local_cafe_outlined, size: 18),
                    label: Text(
                      coffee.containsMilk ? 'Contains milk' : 'Black coffee',
                    ),
                  ),
                ],
              ),
              if (coffee.isIced)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(Icons.ac_unit_rounded, size: 18),
                    label: Text('Served over ice'),
                  ),
                ),
              const SectionTitle('Description'),
              Text(
                coffee.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SectionTitle('Size', subtitle: 'Choose your perfect cup.'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final size in ['S', 'M', 'L'])
                    ChoiceChip(
                      key: ValueKey('size-$size'),
                      label: Text(
                        '$size · ${money(coffee.priceCentsFor(size))}',
                      ),
                      selected: _size == size,
                      onSelected: (_) => setState(() => _size = size),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                coffee.containsMilk
                    ? 'Made with dairy milk. Please confirm any dietary requirements with the shop.'
                    : 'Made without milk. Please confirm any dietary requirements with the shop.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: PageBody(
            maxWidth: 860,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size $_size · Price',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    AnimatedValue(
                      value: _size,
                      child: Text(
                        money(coffee.priceCentsFor(_size)),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {
                    Get.find<CartController>().addItem(coffee, _size);
                    AppFeedback.show(
                      context,
                      'Added ${coffee.name} ($_size) to cart',
                      actionLabel: 'View cart',
                      onAction: () => openShopTab(context, 2),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
