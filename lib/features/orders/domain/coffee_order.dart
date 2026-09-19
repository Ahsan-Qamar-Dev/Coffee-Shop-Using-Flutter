import '../../catalog/domain/coffee.dart';
import '../../profile/domain/customer_preferences.dart';

class OrderLine {
  const OrderLine({
    required this.coffee,
    required this.size,
    required this.quantity,
    required this.unitPriceCents,
  });
  final Coffee coffee;
  final String size;
  final int quantity, unitPriceCents;
  int get totalCents => quantity * unitPriceCents;
}

class OrderDraft {
  OrderDraft({
    required List<OrderLine> lines,
    required this.delivery,
    required this.payment,
    required this.customerName,
    this.address,
    this.note = '',
  }) : lines = List.unmodifiable(lines);
  final List<OrderLine> lines;
  final bool delivery;
  final PaymentChoice payment;
  final String customerName, note;
  final DeliveryAddress? address;
  int get subtotalCents =>
      lines.fold(0, (total, line) => total + line.totalCents);
  int get deliveryCents => delivery ? 150 : 0;
  int get totalCents => subtotalCents + deliveryCents;
}

class CoffeeOrder {
  const CoffeeOrder({
    required this.id,
    required this.createdAt,
    required this.draft,
    this.cancelled = false,
  });
  final String id;
  final DateTime createdAt;
  final OrderDraft draft;
  final bool cancelled;
  CoffeeOrder cancel() =>
      CoffeeOrder(id: id, createdAt: createdAt, draft: draft, cancelled: true);
}

abstract class OrderRepository {
  Future<CoffeeOrder> place(OrderDraft draft);
  Future<CoffeeOrder> cancel(CoffeeOrder order);
}
