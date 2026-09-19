import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/app/shop_navigation.dart';
import 'package:my_coffee_shop/core/theme/app_theme.dart';
import 'package:my_coffee_shop/features/auth/domain/auth_user.dart';
import 'package:my_coffee_shop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/home_page.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';
import 'package:my_coffee_shop/features/checkout/presentation/pages/payment_screen.dart';
import 'package:my_coffee_shop/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:my_coffee_shop/features/orders/domain/coffee_order.dart';
import 'package:my_coffee_shop/features/orders/data/demo_order_repository.dart';
import 'package:my_coffee_shop/features/orders/presentation/controllers/order_controller.dart';
import 'package:my_coffee_shop/features/orders/presentation/pages/order_pages.dart';
import 'package:my_coffee_shop/features/profile/domain/customer_preferences.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/profile_screen.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/account_pages.dart';

void main() {
  if (!const bool.fromEnvironment('CAPTURE_UI')) return;
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader('Roboto')
          ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf')))
        .load();
    await (FontLoader(
      'Poppins',
    )..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'))).load();
  });
  setUp(() {
    Get.testMode = true;
    Get.put<OrderRepository>(
      DemoOrderRepository(now: () => DateTime(2026, 9, 20, 10, 30)),
      permanent: true,
    );
    AppBinding().dependencies();
  });
  tearDown(() => Get.reset());
  for (final brightness in Brightness.values) {
    for (final name in [
      'home',
      'detail',
      'cart',
      'checkout',
      'notifications',
      'profile',
      'address',
      'receipt',
    ]) {
      testWidgets('preview $name ${brightness.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Get.find<AuthController>().user = const AuthUser(
          name: 'Alex Johnson',
          email: 'alex@example.com',
        );
        final cart = Get.find<CartController>();
        cart.addItem(sampleCoffees.first, 'M');
        cart.addItem(sampleCoffees[4], 'S');
        final order = await tester.runAsync(
          () => Get.find<OrderController>().place(
            OrderDraft(
              lines: [
                OrderLine(
                  coffee: sampleCoffees.first,
                  size: 'M',
                  quantity: 1,
                  unitPriceCents: 470,
                ),
              ],
              delivery: false,
              payment: PaymentChoice.cash,
              customerName: 'Alex Johnson',
            ),
          ),
        );
        Get.find<NotificationController>().addOrder(order!.id);
        if (name == 'cart') Get.find<ShopNavigation>().select(2);
        if (name == 'notifications') Get.find<ShopNavigation>().select(3);
        final Widget page = switch (name) {
          'detail' => DetailsPage(coffee: sampleCoffees.first),
          'checkout' => const PaymentScreen(),
          'profile' => const ProfileScreen(),
          'address' => const AddressScreen(),
          'receipt' => OrderDetailScreen(orderId: order.id, justPlaced: true),
          _ => const HomePage(),
        };
        await tester.pumpWidget(
          GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.create(brightness),
            home: RepaintBoundary(key: const ValueKey('preview'), child: page),
          ),
        );
        await tester.runAsync(() async {
          final context = tester.element(find.byKey(const ValueKey('preview')));
          for (final coffee in sampleCoffees) {
            await precacheImage(AssetImage(coffee.imagePath), context);
          }
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const ValueKey('preview')),
          matchesGoldenFile('goldens/ui_${name}_${brightness.name}.png'),
        );
      });
    }
  }
}
