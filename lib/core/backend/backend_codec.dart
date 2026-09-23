import '../../features/catalog/domain/coffee.dart';
import '../../features/orders/domain/coffee_order.dart';
import '../../features/profile/domain/customer_preferences.dart';

Coffee coffeeFromRow(Map<String, dynamic> row) => Coffee(
  id: row['id'] as String,
  name: row['name'] as String,
  subtitle: row['subtitle'] as String,
  description: row['description'] as String,
  price: (row['price_cents'] as num).toDouble() / 100,
  rating: (row['rating'] as num).toDouble(),
  imagePath: row['image_path'] as String,
  category: row['category'] as String,
  containsMilk: row['contains_milk'] as bool,
  isIced: row['is_iced'] as bool,
);
Map<String, dynamic>? addressToRow(DeliveryAddress? a) => a == null
    ? null
    : {'label': a.label, 'street': a.street, 'city': a.city, 'phone': a.phone};
DeliveryAddress? addressFromRow(dynamic value) {
  if (value is! Map) return null;
  return DeliveryAddress(
    label: value['label'] as String,
    street: value['street'] as String,
    city: value['city'] as String,
    phone: value['phone'] as String,
  );
}

CoffeeOrder orderFromRow(Map<String, dynamic> row) {
  final payload = Map<String, dynamic>.from(row['payload'] as Map);
  return CoffeeOrder(
    id: row['id'] as String,
    createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    cancelled: row['status'] == 'cancelled',
    status: row['status'] as String,
    draft: OrderDraft(
      lines: [
        for (final dynamic value in payload['lines'] as List)
          OrderLine(
            coffee: coffeeFromRow(
              Map<String, dynamic>.from(value['coffee'] as Map),
            ),
            size: value['size'] as String,
            quantity: value['quantity'] as int,
            unitPriceCents: value['unit_price_cents'] as int,
          ),
      ],
      delivery: payload['delivery'] as bool,
      payment: PaymentChoice.cash,
      customerName: payload['customer_name'] as String,
      address: addressFromRow(payload['address']),
      note: payload['note'] as String,
      deliveryFeeCents: payload['delivery_cents'] as int,
    ),
  );
}
