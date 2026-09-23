import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/backend/backend_config.dart';
import '../core/backend/customer_session.dart';
import '../core/backend/supabase_customer_repository.dart';
import '../features/auth/data/supabase_auth_repository.dart';
import '../features/orders/data/supabase_order_repository.dart';

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
      Get.put<OrderRepository>(
        BackendConfig.live
            ? SupabaseOrderRepository(Supabase.instance.client)
            : DemoOrderRepository(),
        permanent: true,
      );
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
      Get.put<AuthRepository>(
        BackendConfig.live
            ? SupabaseAuthRepository(Supabase.instance.client)
            : DemoAuthRepository(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    }
    if (BackendConfig.live && !Get.isRegistered<CustomerSession>()) {
      Get.put(
        CustomerSession(
          Supabase.instance.client,
          SupabaseCustomerRepository(Supabase.instance.client),
          Get.find<OrderRepository>() as SupabaseOrderRepository,
        ),
        permanent: true,
      );
    }
  }
}
