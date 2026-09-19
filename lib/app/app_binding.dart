import 'package:get/get.dart';

import 'shop_navigation.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/notifications/presentation/controllers/notification_controller.dart';
import '../features/orders/domain/coffee_order.dart';
import '../features/orders/data/demo_order_repository.dart';
import '../features/orders/presentation/controllers/order_controller.dart';

import '../core/theme/theme_controller.dart';
import '../features/cart/presentation/controllers/cart_controller.dart';
import '../features/favorites/presentation/controllers/favorite_controller.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/data/demo_auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ShopNavigation>()) {
      Get.put(ShopNavigation(), permanent: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.put<OrderRepository>(DemoOrderRepository(), permanent: true);
    }
    if (!Get.isRegistered<OrderController>()) {
      Get.put(OrderController(Get.find<OrderRepository>()), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController(), permanent: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(DemoAuthRepository(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    }
  }
}
