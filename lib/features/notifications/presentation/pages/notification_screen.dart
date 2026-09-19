import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/shop_widgets.dart';
import '../../../orders/presentation/pages/order_pages.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  Widget build(BuildContext context) {
    final body = GetBuilder<NotificationController>(
      builder: (notifications) => PageBody(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            GetBuilder<ProfileController>(
              builder: (profile) => profile.orderAlerts
                  ? const SizedBox.shrink()
                  : ShopCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order alerts are turned off.'),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ProfileScreen(),
                              ),
                            ),
                            child: const Text('Manage preferences'),
                          ),
                        ],
                      ),
                    ),
            ),
            if (notifications.items.isEmpty)
              EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'All quiet for now',
                message: 'Your order updates will appear here. Place a preview order to try it out.',
                action: 'View orders',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
                ),
              )
            else ...[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: notifications.unreadCount == 0
                        ? null
                        : notifications.markAllRead,
                    child: const Text('Mark all read'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (await confirmAction(
                        context,
                        title: 'Clear notifications?',
                        message:
                            'Your orders will still be available in My orders.',
                        action: 'Clear all',
                      )) {
                        notifications.clear();
                      }
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              for (final item in notifications.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        notifications.markRead(item);
                        if (item.orderId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  OrderDetailScreen(orderId: item.orderId!),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Badge(
                              isLabelVisible: !item.read,
                              child: Icon(
                                Icons.local_cafe_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: item.read
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.body,
                                    style: TextStyle(
                                      height: 1.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    orderDate(item.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
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
          ],
        ),
      ),
    );
    return embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: const Text('Notifications')),
            body: SafeArea(child: body),
          );
  }
}
