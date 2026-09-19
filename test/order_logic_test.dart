import 'package:flutter_test/flutter_test.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/orders/data/demo_order_repository.dart';
import 'package:my_coffee_shop/features/orders/domain/coffee_order.dart';
import 'package:my_coffee_shop/features/orders/presentation/controllers/order_controller.dart';
import 'package:my_coffee_shop/features/profile/domain/customer_preferences.dart';

void main() {
  OrderDraft draft({bool delivery = false, bool empty = false}) => OrderDraft(
    lines: empty
        ? []
        : [
            OrderLine(
              coffee: sampleCoffees.first,
              size: 'L',
              quantity: 3,
              unitPriceCents: 520,
            ),
          ],
    delivery: delivery,
    payment: PaymentChoice.cash,
    customerName: 'Test',
  );
  test('prices use cents and include the selected size', () {
    final coffee = sampleCoffees.first;
    expect(coffee.priceCentsFor('S'), 420);
    expect(coffee.priceCentsFor('M'), 470);
    expect(coffee.priceCentsFor('L'), 520);
    expect(() => coffee.priceCentsFor('XL'), throwsArgumentError);
    expect(draft().totalCents, 1560);
    expect(draft(delivery: true).totalCents, 1710);
  });
  test(
    'duplicate checkout is ignored; immutable receipt survives cancellation',
    () async {
      final orders = OrderController(DemoOrderRepository());
      final pending = orders.place(draft());
      expect(await orders.place(draft()), isNull);
      final order = await pending;
      expect(orders.orders.length, 1);
      expect(() => order!.draft.lines.clear(), throwsUnsupportedError);
      expect(await orders.cancel(order!.id), isTrue);
      expect(orders.byId(order.id)!.cancelled, isTrue);
      expect(orders.byId(order.id)!.draft.totalCents, 1560);
    },
  );
  test('invalid checkout exposes retryable error and no order', () async {
    final orders = OrderController(DemoOrderRepository());
    expect(await orders.place(draft(empty: true)), isNull);
    expect(orders.error, isNotNull);
    expect(orders.busy, isFalse);
    expect(await orders.place(draft(delivery: true)), isNull);
    expect(orders.orders, isEmpty);
    expect(await orders.place(draft()), isNotNull);
    expect(orders.error, isNull);
  });
}
