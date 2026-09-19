import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/core/theme/app_theme.dart';
import 'package:my_coffee_shop/features/auth/domain/auth_user.dart';
import 'package:my_coffee_shop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/home_page.dart';
import 'package:my_coffee_shop/features/cart/presentation/pages/cart_screen.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    try {
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    } catch (_) {}
    try {
      await (FontLoader('Roboto')
            ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
            ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf')))
          .load();
    } catch (_) {}
    try {
      await (FontLoader(
        'Poppins',
      )..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'))).load();
    } catch (_) {}
    try {
      await (FontLoader(
        'font30',
      )..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))).load();
    } catch (_) {}
  });

  setUp(() {
    Get.testMode = true;
    AppBinding().dependencies();
  });

  tearDown(() async {
    Get.reset();
  });

  Future<void> captureScreen(
    WidgetTester tester,
    Widget page,
    String fileName, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.create(Brightness.dark),
        debugShowCheckedModeBanner: false,
        home: Material(
          child: RepaintBoundary(
            key: const ValueKey('capture_root'),
            child: page,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byKey(const ValueKey('capture_root')),
      matchesGoldenFile('goldens/$fileName'),
    );
  }

  testWidgets('Capture Home Screen', (tester) async {
    final auth = Get.find<AuthController>();
    auth.user = const AuthUser(name: 'Alex Johnson', email: 'alex@example.com');
    await captureScreen(tester, const HomePage(), 'gig_home.png');
  });

  testWidgets('Capture Details Screen', (tester) async {
    await captureScreen(
      tester,
      DetailsPage(coffee: sampleCoffees.first),
      'gig_detail.png',
    );
  });

  testWidgets('Capture Cart Screen', (tester) async {
    final cart = Get.find<CartController>();
    cart.addItem(sampleCoffees[0], 'M');
    cart.addItem(sampleCoffees[1], 'S');
    await captureScreen(tester, const CartScreen(), 'gig_cart.png');
  });
}
