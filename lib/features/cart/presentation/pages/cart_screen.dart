import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../../core/widgets/shop_motion.dart';
import '../../../catalog/presentation/pages/detail_page.dart';
import '../../../checkout/presentation/pages/payment_screen.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.embedded = false});
  final bool embedded;

  void _removeWithUndo(BuildContext context, CartController cart, item) {
    final quantity = item.quantity;
    cart.removeItem(item);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${item.coffee.name} from cart'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              item.quantity = quantity;
              cart.restoreItem(item);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final body = GetBuilder<CartController>(
      builder: (cart) => PageBody(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (cart.items.isEmpty)
              EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Your cart is empty',
                message: 'A good coffee is just a few taps away.',
                action: 'Explore coffees',
                onAction: () => openShopTab(context, 0),
              )
            else ...[
              SectionTitle(
                'Your coffee break',
                subtitle:
                    '${cart.itemCount} ${cart.itemCount == 1 ? 'cup' : 'cups'} of something good.',
              ),
              for (final item in cart.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ShopCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              button: true,
                              label: 'View ${item.coffee.name}',
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        DetailsPage(coffee: item.coffee),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    item.coffee.imagePath,
                                    height: 76,
                                    width: 76,
                                    fit: BoxFit.cover,
                                    cacheWidth: 256,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.coffee.name,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Size ${item.size} · ${money(item.unitPriceCents)} each',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove ${item.coffee.name}',
                              onPressed: () =>
                                  _removeWithUndo(context, cart, item),
                              icon: const Icon(Icons.close, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 20,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              money(item.totalCents),
                              semanticsLabel: money(item.totalCents),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CompactActionButton(
                                  filled: false,
                                  tooltip: 'Decrease ${item.coffee.name}',
                                  onPressed: () {
                                    if (item.quantity == 1) {
                                      _removeWithUndo(context, cart, item);
                                    } else {
                                      cart.decrementQuantity(item);
                                    }
                                  },
                                  icon: Icons.remove_rounded,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: AnimatedValue(
                                    value: item.quantity,
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                CompactActionButton(
                                  tooltip: 'Increase ${item.coffee.name}',
                                  onPressed: () => cart.incrementQuantity(item),
                                  icon: Icons.add_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              ShopCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PriceRow('Subtotal', cart.totalCents, emphasized: true),
                    Text(
                      'Delivery is calculated at checkout. Prices in USD.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const ValueKey('checkout'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PaymentScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Checkout'),
                    ),
                    TextButton(
                      onPressed: () => openShopTab(context, 0),
                      child: const Text('Add another coffee'),
                    ),
                  ],
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
            appBar: AppBar(title: const Text('Your cart')),
            body: SafeArea(child: body),
          );
  }
}
