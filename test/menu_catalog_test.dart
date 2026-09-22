import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/core/theme/app_theme.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/home_page.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/favorites/presentation/controllers/favorite_controller.dart';

void main() {
  test('catalog has distinct assets and IDs, with correct milk labels', () {
    expect(sampleCoffees.length, 11);
    expect(sampleCoffees.map((c) => c.id).toSet().length, 11);
    expect(sampleCoffees.map((c) => c.imagePath).toSet().length, 11);
    for (final coffee in sampleCoffees) {
      expect(File(coffee.imagePath).existsSync(), isTrue);
      expect(coffee.priceCentsFor('L'), coffee.priceCentsFor('S') + 100);
    }
    expect(sampleCoffees.where((c) => !c.containsMilk).map((c) => c.name), [
      'Espresso',
      'Americano',
      'Cold Brew',
    ]);
  });
  setUp(() {
    Get.testMode = true;
    AppBinding().dependencies();
  });
  tearDown(() => Get.reset());

  testWidgets('iced filter and search find a new drink and quick add it', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.create(Brightness.dark),
        home: const HomePage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Iced'));
    await tester.pumpAndSettle();
    expect(find.text('2 coffees found'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('coffee-search')),
      'cold brew',
    );
    await tester.pumpAndSettle();
    expect(find.text('1 coffee found'), findsOneWidget);
    final add = find.byKey(const ValueKey('quick-add-c9'));
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(Get.find<CartController>().items.single.coffee.id, 'c9');
    expect(tester.takeException(), isNull);
  });

  for (final coffee in sampleCoffees.skip(5)) {
    testWidgets('${coffee.name} details render on a narrow screen', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 740);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.create(Brightness.dark),
          home: DetailsPage(coffee: coffee),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(coffee.name), findsOneWidget);
      expect(tester.takeException(), isNull);
      final favorites = Get.find<FavoriteController>();
      favorites.toggleFavorite(coffee);
      expect(favorites.favorites.single.id, coffee.id);
      final cart = Get.find<CartController>();
      cart.addItem(coffee, 'M');
      expect(cart.totalCents, coffee.priceCentsFor('M'));
    });
  }
}
