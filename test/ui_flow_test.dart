import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/app/shop_navigation.dart';
import 'package:my_coffee_shop/core/theme/app_theme.dart';
import 'package:my_coffee_shop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/cart/presentation/pages/cart_screen.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/home_page.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';
import 'package:my_coffee_shop/features/checkout/presentation/pages/payment_screen.dart';
import 'package:my_coffee_shop/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:my_coffee_shop/features/favorites/presentation/pages/favorite_screen.dart';
import 'package:my_coffee_shop/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:my_coffee_shop/features/notifications/presentation/pages/notification_screen.dart';
import 'package:my_coffee_shop/features/orders/domain/coffee_order.dart';
import 'package:my_coffee_shop/features/orders/presentation/controllers/order_controller.dart';
import 'package:my_coffee_shop/features/orders/presentation/pages/order_pages.dart';
import 'package:my_coffee_shop/features/profile/domain/customer_preferences.dart';
import 'package:my_coffee_shop/features/profile/presentation/controllers/profile_controller.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/profile_screen.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/account_pages.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/help_screen.dart';
import 'package:my_coffee_shop/main.dart';
import 'package:my_coffee_shop/core/theme/theme_controller.dart';

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
  tearDown(() => Get.reset());

  Future<void> host(
    WidgetTester tester,
    Widget page, {
    Size size = const Size(390, 844),
    double scale = 1,
    Brightness brightness = Brightness.dark,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.create(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: page,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      final scroll = find
          .byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          )
          .first;
      await tester.drag(scroll, const Offset(0, 5000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(finder, 220, scrollable: scroll);
    }
    await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  OrderDraft draft() => OrderDraft(
    lines: [
      OrderLine(
        coffee: sampleCoffees.first,
        size: 'M',
        quantity: 2,
        unitPriceCents: 470,
      ),
    ],
    delivery: false,
    payment: PaymentChoice.cash,
    customerName: 'Coffee Lover',
  );

  testWidgets(
    'every main tab opens the shared drawer and all drawer links navigate',
    (tester) async {
      await host(tester, const HomePage());
      for (var index = 0; index < 4; index++) {
        Get.find<ShopNavigation>().select(index);
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const ValueKey('open-menu')));
        expect(find.byType(Drawer), findsOneWidget);
        final tile = find.descendant(
          of: find.byType(Drawer),
          matching: find.widgetWithText(ListTile, 'Home'),
        );
        await tap(tester, tile);
        expect(Get.find<ShopNavigation>().index, 0);
        expect(tester.takeException(), isNull);
      }
      for (final link in ['My orders', 'Profile & settings', 'Help & about']) {
        await tap(tester, find.byKey(const ValueKey('open-menu')));
        await tap(
          tester,
          find.descendant(
            of: find.byType(Drawer),
            matching: find.widgetWithText(ListTile, link),
          ),
        );
        expect(find.text(link), findsWidgets);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'category and search combine, and clearing filters restores coffees',
    (tester) async {
      await host(tester, const HomePage());
      await tap(tester, find.widgetWithText(ChoiceChip, 'Cappuccino'));
      await tester.enterText(
        find.byKey(const ValueKey('coffee-search')),
        'Espresso',
      );
      await tester.pumpAndSettle();
      // Cappuccino's description includes espresso; a nonmatching query must still respect category.
      await tester.enterText(
        find.byKey(const ValueKey('coffee-search')),
        'chocolate',
      );
      await tester.pumpAndSettle();
      expect(find.text('No coffee found'), findsOneWidget);
      await tap(tester, find.text('Clear filters'));
      expect(find.byKey(const ValueKey('quick-add-c1')), findsOneWidget);
      expect(find.text('No coffee found'), findsNothing);
    },
  );

  testWidgets('quick add charges the displayed small price', (tester) async {
    await host(tester, const HomePage());
    await tap(tester, find.byKey(const ValueKey('quick-add-c1')));
    final item = Get.find<CartController>().items.single;
    expect(item.size, 'S');
    expect(item.totalCents, 420);
    expect(find.byType(DetailsPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'checkout creates one receipt, clears cart, opens matching alert and reorders',
    (tester) async {
      Get.find<CartController>().addItem(sampleCoffees.first, 'M');
      await host(tester, const HomePage());
      Get.find<ShopNavigation>().select(2);
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const ValueKey('checkout')));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('place-order')),
        220,
      );
      await tester.tap(find.byKey(const ValueKey('place-order')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      final orders = Get.find<OrderController>();
      expect(orders.orders.length, 1);
      expect(orders.orders.single.draft.totalCents, 470);
      expect(Get.find<CartController>().items, isEmpty);
      expect(find.byType(OrderDetailScreen), findsOneWidget);
      await tap(tester, find.text('Continue shopping'));
      expect(Get.find<ShopNavigation>().index, 0);
      Get.find<ShopNavigation>().select(3);
      await tester.pumpAndSettle();
      await tap(tester, find.text('Your preview order is confirmed'));
      expect(Get.find<NotificationController>().unreadCount, 0);
      expect(find.byType(OrderDetailScreen), findsOneWidget);
      await tap(tester, find.text('Order these again'));
      expect(Get.find<ShopNavigation>().index, 2);
      expect(Get.find<CartController>().items.single.totalCents, 470);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'delivery blocks missing address and recalculates total after address entry',
    (tester) async {
      Get.find<CartController>().addItem(sampleCoffees.first, 'S');
      await host(tester, const PaymentScreen());
      await tap(tester, find.byKey(const ValueKey('delivery-choice')));
      await tap(tester, find.byKey(const ValueKey('place-order')));
      expect(Get.find<OrderController>().orders, isEmpty);
      await tap(tester, find.text('Add delivery address'));
      await tap(tester, find.text('Save address'));
      expect(find.text('Enter your complete street address.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('address-street')),
        '12 Test Street',
      );
      await tester.enterText(
        find.byKey(const ValueKey('address-city')),
        'Lahore',
      );
      await tester.enterText(
        find.byKey(const ValueKey('address-phone')),
        '+92 300 1234567',
      );
      await tap(tester, find.text('Save address'));
      expect(find.textContaining('12 Test Street'), findsOneWidget);
      expect(find.text('\$5.70'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('place-order')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(Get.find<OrderController>().orders.single.draft.totalCents, 570);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'profile details save, password changes and disabled alerts are respected',
    (tester) async {
      await tester.runAsync(
        () =>
            Get.find<AuthController>().signIn('demo@coffee.test', 'Coffee123!'),
      );
      await host(tester, const ProfileScreen());
      await tap(tester, find.text('Edit profile'));
      await tester.enterText(
        find.byKey(const ValueKey('profile-name')),
        'Taylor',
      );
      await tap(tester, find.text('Save details'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Taylor'), findsOneWidget);
      await tap(tester, find.text('Security & password'));
      await tester.enterText(
        find.byKey(const ValueKey('Current password')),
        'Coffee123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('New password')),
        'Coffee456!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('Confirm new password')),
        'Coffee456!',
      );
      await tap(tester, find.text('Update password'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(
          () => Get.find<AuthController>().signIn(
            'demo@coffee.test',
            'Coffee456!',
          ),
        ),
        isTrue,
      );
      Get.find<ProfileController>().setAlerts(false);
      Get.find<CartController>().addItem(sampleCoffees.first, 'S');
      await host(tester, const PaymentScreen());
      await tap(tester, find.byKey(const ValueKey('place-order')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(Get.find<NotificationController>().items, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'payment preference, theme and sign out work through the actual app',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tap(tester, find.text('Try demo account'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      Get.find<CartController>().addItem(sampleCoffees.first, 'M');
      Get.find<FavoriteController>().toggleFavorite(sampleCoffees.first);
      final order = await tester.runAsync(
        () => Get.find<OrderController>().place(draft()),
      );
      Get.find<NotificationController>().addOrder(order!.id);
      await tap(tester, find.byTooltip('Profile & settings'));
      await tap(tester, find.text('Payment preferences'));
      await tap(tester, find.byKey(const ValueKey('payment-demoCard')));
      await tap(tester, find.text('Done'));
      expect(Get.find<ProfileController>().payment, PaymentChoice.demoCard);
      await tap(tester, find.text('Dark mode'));
      expect(Get.find<ThemeController>().isDarkMode, isFalse);
      expect(
        Theme.of(tester.element(find.byType(ProfileScreen))).brightness,
        Brightness.light,
      );
      await tap(tester, find.widgetWithText(OutlinedButton, 'Sign out'));
      await tap(tester, find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();
      expect(Get.find<AuthController>().user, isNull);
      expect(Get.find<CartController>().items, isEmpty);
      expect(Get.find<FavoriteController>().favorites, isEmpty);
      expect(Get.find<OrderController>().orders, isEmpty);
      expect(Get.find<NotificationController>().items, isEmpty);
      expect(Get.find<ProfileController>().payment, PaymentChoice.cash);
      expect(find.text('Try demo account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  final pages = <String, Widget Function()>{
    'home': () => const HomePage(),
    'detail': () => DetailsPage(coffee: sampleCoffees.first),
    'cart': () => const CartScreen(),
    'favorites': () => const FavoriteScreen(),
    'notifications': () => const NotificationScreen(),
    'checkout': () => const PaymentScreen(),
    'profile': () => const ProfileScreen(),
    'personal': () => const PersonalDetailsScreen(),
    'address': () => const AddressScreen(),
    'payment': () => const PaymentMethodsScreen(),
    'security': () => const SecurityScreen(),
    'help': () => const HelpScreen(),
    'orders': () => const OrdersScreen(),
    'receipt': () => const OrderDetailScreen(orderId: 'CF-1001'),
  };
  for (final entry in pages.entries) {
    for (final scenario in [
      (const Size(320, 568), 2.0, Brightness.dark),
      (const Size(844, 390), 2.0, Brightness.light),
      (const Size(1024, 768), 1.0, Brightness.light),
    ]) {
      testWidgets(
        '${entry.key} layout ${scenario.$1} scale ${scenario.$2} ${scenario.$3}',
        (tester) async {
          Get.find<CartController>().addItem(sampleCoffees.first, 'L');
          Get.find<FavoriteController>().toggleFavorite(sampleCoffees.first);
          final order = await tester.runAsync(
            () => Get.find<OrderController>().place(draft()),
          );
          Get.find<NotificationController>().addOrder(order!.id);
          await host(
            tester,
            entry.value(),
            size: scenario.$1,
            scale: scenario.$2,
            brightness: scenario.$3,
          );
          expect(tester.takeException(), isNull);
          final list = find.byType(Scrollable).first;
          await tester.drag(list, const Offset(0, -1000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
