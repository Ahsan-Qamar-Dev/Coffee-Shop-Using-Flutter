import 'package:get/get.dart';

import '../core/theme/theme_controller.dart';
import '../features/cart/presentation/controllers/cart_controller.dart';
import '../features/favorites/presentation/controllers/favorite_controller.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/data/demo_auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
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
