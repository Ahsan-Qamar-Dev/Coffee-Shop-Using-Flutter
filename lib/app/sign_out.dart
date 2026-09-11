import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/cart/presentation/controllers/cart_controller.dart';
import '../features/favorites/presentation/controllers/favorite_controller.dart';
import '../core/widgets/app_feedback.dart';

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
  Get.offAll(() => const LoginPage());
}
