import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/backend/backend_config.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/cart/presentation/controllers/cart_controller.dart';
import '../features/favorites/presentation/controllers/favorite_controller.dart';
import '../core/widgets/app_feedback.dart';
import 'shop_navigation.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/notifications/presentation/controllers/notification_controller.dart';
import '../features/orders/presentation/controllers/order_controller.dart';

Future<void> signOut(BuildContext context) async {
  final ok = await Get.find<AuthController>().signOut();
  if (!context.mounted) return;
  if (!ok) {
    AppFeedback.show(
      context,
      'Could not sign out. Please try again.',
      error: true,
    );
    return;
  }
  Get.find<CartController>().clearCart();
  Get.find<FavoriteController>().clear();
  Get.find<ProfileController>().clear();
  Get.find<NotificationController>().clear();
  Get.find<OrderController>().clear();
  Get.find<ShopNavigation>().select(0);
  Get.offAll(() => const LoginPage());
}

Future<void> confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign out?'),
      content: Text(
        BackendConfig.live
            ? 'Your synced cart, favorites and orders will be available when you sign in again.'
            : 'Your cart, saved address and preview orders will be cleared for this session.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Stay signed in'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) await signOut(context);
}
