import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/core/theme/app_theme.dart';
import 'package:my_coffee_shop/features/auth/presentation/pages/login_page.dart';
import 'package:my_coffee_shop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/home_page.dart';
import 'package:my_coffee_shop/features/cart/presentation/pages/cart_screen.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';
import 'package:my_coffee_shop/main.dart';

void main() {
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
    AppBinding().dependencies();
  });
  tearDown(() async {
    Get.reset();
  });
  Future<void> host(
    WidgetTester tester,
    Widget page, {
    Size size = const Size(390, 844),
    double scale = 1,
    Brightness brightness = Brightness.dark,
    bool keyboard = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.create(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard ? 220 : 0),
          ),
          child: child!,
        ),
        home: page,
      ),
    );
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/Coffee_Cup.png'),
        tester.element(find.byType(Scaffold).first),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final mode in AuthPageMode.values) {
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(844, 390),
      const Size(1024, 768),
    ]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('auth layout $mode $size text $scale', (tester) async {
          await host(
            tester,
            AuthPage(mode: mode),
            size: size,
            scale: scale,
          );
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('keyboard and validation remain usable on small phone', (
    tester,
  ) async {
    await host(
      tester,
      const LoginPage(),
      size: const Size(320, 568),
      keyboard: true,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('register and recovery navigation', (tester) async {
    await host(tester, const LoginPage());
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);
    await tester.ensureVisible(find.text('Back to Sign In'));
    await tester.tap(find.text('Back to Sign In'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Forgot Password?'));
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('Email address')),
      'test@example.com',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining('Recovery preview complete.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('invalid credentials stay on sign in and show feedback', (
    tester,
  ) async {
    await host(tester, const LoginPage());
    await tester.enterText(
      find.byKey(const ValueKey('Email address')),
      'nobody@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('Password')),
      'wrongpassword',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Email or password is incorrect.'),
      findsOneWidget,
    );
    expect(find.byType(HomePage), findsNothing);
  });
  testWidgets('demo login reaches existing home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Try demo account'));
    await tester.tap(find.text('Try demo account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(Get.find<AuthController>().user?.email, 'demo@coffee.test');
    expect(tester.takeException(), isNull);
  });
  testWidgets('GetX cart view rebuilds after quantity changes', (tester) async {
    final cart = Get.find<CartController>();
    cart.addItem(sampleCoffees.first, 'S');
    await host(tester, const CartScreen());
    cart.incrementQuantity(cart.items.first);
    await tester.pumpAndSettle();
    expect(cart.itemCount, 2);
    expect(find.text('8.40'), findsWidgets);
    cart.clearCart();
    await tester.pumpAndSettle();
    expect(cart.items, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('detail favorite button updates through GetX', (tester) async {
    await host(tester, DetailsPage(coffee: sampleCoffees.first));
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();
    expect(
      Get.find<FavoriteController>().isFavorite(sampleCoffees.first),
      isTrue,
    );
    expect(find.byIcon(Icons.favorite), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('light auth preview', (tester) async {
    await host(tester, const LoginPage(), brightness: Brightness.light);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('detail layout on narrow phone at text $scale', (tester) async {
      await host(
        tester,
        DetailsPage(coffee: sampleCoffees.first),
        size: const Size(320, 568),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Size'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('signup confirms password and opens home', (tester) async {
    await host(tester, const AuthPage(mode: AuthPageMode.signUp));
    await tester.enterText(find.byKey(const ValueKey('Full name')), 'Alex');
    await tester.enterText(
      find.byKey(const ValueKey('Email address')),
      'alex@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('Password')),
      'preview123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('Confirm password')),
      'different',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('Confirm password')),
      'preview123',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(Get.find<AuthController>().user?.name, 'Alex');
    expect(tester.takeException(), isNull);
  });
  if (const bool.fromEnvironment('CAPTURE_DAY1')) {
    for (final mode in AuthPageMode.values) {
      testWidgets('preview image $mode', (tester) async {
        await host(
          tester,
          RepaintBoundary(
            key: const ValueKey('capture'),
            child: AuthPage(mode: mode),
          ),
          size: const Size(390, 1000),
        );
        await expectLater(
          find.byKey(const ValueKey('capture')),
          matchesGoldenFile('goldens/${mode.name}.png'),
        );
      });
    }
    testWidgets('light preview image', (tester) async {
      await host(
        tester,
        RepaintBoundary(
          key: const ValueKey('capture'),
          child: const LoginPage(),
        ),
        brightness: Brightness.light,
        size: const Size(390, 1000),
      );
      await expectLater(
        find.byKey(const ValueKey('capture')),
        matchesGoldenFile('goldens/login_light.png'),
      );
    });
  }
}
