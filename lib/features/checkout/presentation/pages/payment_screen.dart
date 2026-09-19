import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../orders/domain/coffee_order.dart';
import '../../../orders/presentation/controllers/order_controller.dart';
import '../../../orders/presentation/pages/order_pages.dart';
import '../../../profile/domain/customer_preferences.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/pages/account_pages.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _delivery = false;
  final _note = TextEditingController();
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    final orders = Get.find<OrderController>();
    if (orders.busy) return;
    final cart = Get.find<CartController>();
    final profile = Get.find<ProfileController>();
    if (cart.items.isEmpty) {
      AppFeedback.show(context, 'Your cart is empty.', error: true);
      return;
    }
    if (_delivery && profile.address == null) {
      AppFeedback.show(
        context,
        'Add a delivery address before placing your order.',
        error: true,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final draft = OrderDraft(
      lines: cart.items
          .map(
            (item) => OrderLine(
              coffee: item.coffee,
              size: item.size,
              quantity: item.quantity,
              unitPriceCents: item.unitPriceCents,
            ),
          )
          .toList(),
      delivery: _delivery,
      payment: profile.payment,
      customerName: Get.find<AuthController>().user?.name ?? 'Coffee Lover',
      address: _delivery ? profile.address : null,
      note: _note.text.trim(),
    );
    final order = await orders.place(draft);
    if (!mounted) return;
    if (order == null) {
      AppFeedback.show(
        context,
        orders.error ?? 'Please try again.',
        error: true,
      );
      return;
    }
    cart.clearCart();
    if (profile.orderAlerts) {
      Get.find<NotificationController>().addOrder(
        order.id,
        createdAt: order.createdAt,
      );
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailScreen(orderId: order.id, justPlaced: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GetBuilder<OrderController>(
    builder: (orders) => PopScope(
      canPop: !orders.busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: SafeArea(
          child: PageBody(
            maxWidth: 760,
            child: GetBuilder<CartController>(
              builder: (cart) => GetBuilder<ProfileController>(
                builder: (profile) => AbsorbPointer(
                  absorbing: orders.busy,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      if (cart.items.isEmpty)
                        EmptyState(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Nothing to check out',
                          message: 'Add your favorite coffee to get started.',
                          action: 'Explore coffees',
                          onAction: () => openShopTab(context, 0),
                        )
                      else ...[
                        const SectionTitle(
                          'One step closer to coffee',
                          subtitle: 'Review your details before confirming.',
                        ),
                        ShopCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'How would you like it?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Pickup'),
                                    avatar: const Icon(
                                      Icons.storefront_outlined,
                                    ),
                                    selected: !_delivery,
                                    onSelected: (_) =>
                                        setState(() => _delivery = false),
                                  ),
                                  ChoiceChip(
                                    key: const ValueKey('delivery-choice'),
                                    label: const Text('Delivery'),
                                    avatar: const Icon(Icons.delivery_dining),
                                    selected: _delivery,
                                    onSelected: (_) =>
                                        setState(() => _delivery = true),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (!_delivery)
                                const Text(
                                  'Collect from the coffee counter. Pickup is free in this preview.',
                                  style: TextStyle(height: 1.5),
                                )
                              else ...[
                                Text(
                                  profile.address == null
                                      ? 'Add an address for delivery.'
                                      : '${profile.address!.label}\n${profile.address!.summary}\n${profile.address!.phone}',
                                  style: const TextStyle(height: 1.6),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const AddressScreen(),
                                    ),
                                  ),
                                  icon: const Icon(Icons.location_on_outlined),
                                  label: Text(
                                    profile.address == null
                                        ? 'Add delivery address'
                                        : 'Edit address',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SectionTitle('Payment'),
                        ShopCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.payment.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No charge will be made for this preview order.',
                                style: TextStyle(height: 1.5),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const PaymentMethodsScreen(),
                                  ),
                                ),
                                child: const Text('Change payment preference'),
                              ),
                            ],
                          ),
                        ),
                        const SectionTitle('Order summary'),
                        ShopCard(
                          child: Column(
                            children: [
                              for (final item in cart.items)
                                PriceRow(
                                  '${item.quantity} × ${item.coffee.name} · ${item.size}',
                                  item.totalCents,
                                ),
                              const Divider(height: 28),
                              PriceRow('Subtotal', cart.totalCents),
                              PriceRow('Delivery', _delivery ? 150 : 0),
                              PriceRow(
                                'Total',
                                cart.totalCents + (_delivery ? 150 : 0),
                                emphasized: true,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'USD · Preview prices. No additional charges.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _note,
                          minLines: 2,
                          maxLines: 4,
                          maxLength: 200,
                          decoration: const InputDecoration(
                            labelText: 'Order note (optional)',
                            hintText: 'Anything else for your coffee break?',
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: const ValueKey('place-order'),
                          onPressed: orders.busy ? null : _place,
                          icon: orders.busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            orders.busy ? 'Confirming…' : 'Place preview order',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'This preview creates a receipt in My orders. It does not send an order to a shop.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
