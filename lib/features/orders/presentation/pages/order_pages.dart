import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/backend/backend_config.dart';
import '../../../../core/backend/customer_session.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../profile/domain/customer_preferences.dart';
import '../widgets/receipt_download_button.dart';
import '../controllers/order_controller.dart';

String orderDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} · ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('My orders'),
      actions: [
        if (BackendConfig.live)
          IconButton(
            tooltip: 'Refresh orders',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final session = Get.find<CustomerSession>();
              await session.refreshOrders();
              if (context.mounted && session.orderRefreshError != null) {
                AppFeedback.show(
                  context,
                  session.orderRefreshError!,
                  error: true,
                );
              }
            },
          ),
      ],
    ),
    body: SafeArea(
      child: PageBody(
        maxWidth: 760,
        child: GetBuilder<OrderController>(
          builder: (orders) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              if (orders.orders.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Your first cup awaits',
                  message: 'Your receipts will appear here after checkout.',
                  action: 'Explore coffees',
                  onAction: () => openShopTab(context, 0),
                )
              else ...[
                SectionTitle(
                  'Your coffee moments',
                  subtitle: BackendConfig.live
                      ? 'Your saved test orders.'
                      : 'Receipts from this preview session.',
                ),
                for (final order in orders.orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).colorScheme.surface,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                OrderDetailScreen(orderId: order.id),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    order.id,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      order.cancelled
                                          ? 'Cancelled'
                                          : (BackendConfig.live
                                                ? order.status
                                                : 'Preview confirmed'),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                orderDate(order.createdAt),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                order.draft.lines
                                    .map(
                                      (line) =>
                                          '${line.quantity} × ${line.coffee.name} (${line.size})',
                                    )
                                    .join('\n'),
                                style: const TextStyle(height: 1.6),
                              ),
                              const SizedBox(height: 12),
                              PriceRow(
                                order.draft.delivery ? 'Delivery' : 'Pickup',
                                order.draft.totalCents,
                                emphasized: true,
                              ),
                              const Text('View receipt →'),
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
      ),
    ),
  );
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.justPlaced = false,
  });
  final String orderId;
  final bool justPlaced;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Order details')),
    body: SafeArea(
      child: PageBody(
        maxWidth: 760,
        child: GetBuilder<OrderController>(
          builder: (orders) {
            final order = orders.byId(orderId);
            if (order == null) {
              return ListView(
                children: [
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order unavailable',
                    message: 'This preview order is no longer in your session.',
                    action: 'Explore coffees',
                    onAction: () => openShopTab(context, 0),
                  ),
                ],
              );
            }
            final draft = order.draft;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                ShopCard(
                  child: Column(
                    children: [
                      Icon(
                        order.cancelled
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        order.cancelled
                            ? 'Order cancelled'
                            : justPlaced
                            ? 'A good choice, brewed for you.'
                            : (BackendConfig.live
                                  ? 'Order ${order.status}'
                                  : 'Preview order confirmed'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${order.id}\n${orderDate(order.createdAt)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        BackendConfig.live
                            ? 'Saved for private testing · No payment or coffee dispatch.'
                            : 'Preview only · No payment was taken and no order was sent to a shop.',
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Your receipt'),
                ShopCard(
                  child: Column(
                    children: [
                      for (final line in draft.lines)
                        PriceRow(
                          '${line.quantity} × ${line.coffee.name} · ${line.size}',
                          line.totalCents,
                        ),
                      const Divider(height: 28),
                      PriceRow('Subtotal', draft.subtotalCents),
                      PriceRow('Delivery', draft.deliveryCents),
                      PriceRow('Total', draft.totalCents, emphasized: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ReceiptDownloadButton(order: order),
                SectionTitle(
                  draft.delivery ? 'Delivery details' : 'Pickup details',
                ),
                ShopCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        draft.delivery
                            ? '${draft.address!.label}\n${draft.address!.summary}\n${draft.address!.phone}'
                            : 'Collect at the coffee counter.\nStore location and pickup times will be available for live orders.',
                        style: const TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      Text('Payment: ${draft.payment.label}'),
                      if (draft.note.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text('Order note: ${draft.note}'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    final cart = Get.find<CartController>();
                    for (final line in draft.lines) {
                      final matches = BackendConfig.live
                          ? Get.find<CustomerSession>().catalog.where(
                              (c) => c.id == line.coffee.id,
                            )
                          : [line.coffee];
                      if (matches.isEmpty) continue;
                      for (var i = 0; i < line.quantity; i++) {
                        cart.addItem(matches.first, line.size);
                      }
                    }
                    openShopTab(context, 2);
                    AppFeedback.show(
                      context,
                      'Your coffees were added to the cart',
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Order these again'),
                ),
                TextButton(
                  onPressed: () => openShopTab(context, 0),
                  child: const Text('Continue shopping'),
                ),
                if (!order.cancelled &&
                    (!BackendConfig.live || order.status == 'confirmed'))
                  TextButton(
                    onPressed: orders.busy
                        ? null
                        : () async {
                            if (!await confirmAction(
                              context,
                              title: BackendConfig.live
                                  ? 'Cancel this order?'
                                  : 'Cancel this preview order?',
                              message: 'The receipt will stay in your order history.',
                              action: 'Cancel order',
                            )) {
                              return;
                            }
                            final ok = await orders.cancel(orderId);
                            if (!context.mounted) return;
                            AppFeedback.show(
                              context,
                              ok
                                  ? (BackendConfig.live
                                        ? 'Order cancelled'
                                        : 'Preview order cancelled')
                                  : orders.error!,
                              error: !ok,
                            );
                          },
                    child: Text(
                      orders.busy
                          ? 'Cancelling…'
                          : (BackendConfig.live
                                ? 'Cancel order'
                                : 'Cancel preview order'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
