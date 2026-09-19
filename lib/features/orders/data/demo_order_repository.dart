import '../domain/coffee_order.dart';

/// Session-only preview adapter. Replace with server-validated ordering.
class DemoOrderRepository implements OrderRepository {
  DemoOrderRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  int _sequence = 1000;
  @override
  Future<CoffeeOrder> place(OrderDraft draft) async {
    if (draft.lines.isEmpty || draft.lines.any((line) => line.quantity <= 0)) {
      throw StateError('Add a coffee to your cart first.');
    }
    if (draft.delivery && draft.address == null) {
      throw StateError('Add a delivery address.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return CoffeeOrder(
      id: 'CF-${++_sequence}',
      createdAt: _now(),
      draft: draft,
    );
  }

  @override
  Future<CoffeeOrder> cancel(CoffeeOrder order) async => order.cancel();
}
