import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/core/theme/app_theme.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/orders/data/demo_staff_repository.dart';
import 'package:my_coffee_shop/features/orders/domain/coffee_order.dart';
import 'package:my_coffee_shop/features/orders/presentation/controllers/order_controller.dart';
import 'package:my_coffee_shop/features/orders/presentation/pages/staff_orders_screen.dart';
import 'package:my_coffee_shop/features/profile/domain/customer_preferences.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    AppBinding().dependencies();
    Get.find<OrderController>().restore([
      CoffeeOrder(
        id: 'test-order',
        createdAt: DateTime(2026, 9, 24, 10),
        draft: OrderDraft(
          lines: [
            OrderLine(
              coffee: sampleCoffees.first,
              size: 'S',
              quantity: 2,
              unitPriceCents: 420,
            ),
          ],
          delivery: false,
          payment: PaymentChoice.cash,
          customerName: 'Test customer',
        ),
      ),
    ]);
  });
  tearDown(Get.reset);
  testWidgets(
    'staff advances order and owner can edit menu and manage demo team',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.create(Brightness.light),
          home: StaffOrdersScreen(repository: DemoStaffRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 active'), findsOneWidget);
      await tester.tap(find.text('Start preparing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(Get.find<OrderController>().orders.single.status, 'preparing');
      expect(find.text('Mark ready'), findsOneWidget);
      await tester.tap(find.byTooltip('Owner tools'));
      await tester.pumpAndSettle();
      expect(find.text('Menu & availability'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit Cappuccino'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Small price (USD)'),
        '5.25',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.textContaining('\$5.25'), findsOneWidget);
      await tester.tap(find.text('Team'));
      await tester.pumpAndSettle();
      expect(find.text('demo@coffee.test'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  for (final size in [const Size(320, 700), const Size(1024, 768)]) {
    testWidgets('staff dashboard fits $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.create(Brightness.dark),
          home: StaffOrdersScreen(repository: DemoStaffRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
