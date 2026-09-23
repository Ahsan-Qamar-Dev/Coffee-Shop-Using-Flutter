import 'package:flutter_test/flutter_test.dart';
import 'package:my_coffee_shop/core/backend/backend_codec.dart';

void main() {
  final coffee = <String, dynamic>{
    'id': 'c1',
    'name': 'Cappuccino',
    'subtitle': 'Milk',
    'description': 'Coffee',
    'price_cents': 420,
    'rating': 4.5,
    'image_path': 'assets/Cappacuino.png',
    'category': 'Cappuccino',
    'contains_milk': true,
    'is_iced': false,
  };
  test('database cents retain exact menu pricing and size increments', () {
    final product = coffeeFromRow(coffee);
    expect(product.priceCentsFor('S'), 420);
    expect(product.priceCentsFor('L'), 520);
  });
  test('receipt uses charged snapshot price and server delivery fee', () {
    final order = orderFromRow({
      'id': 'order-id',
      'created_at': '2026-09-23T10:00:00Z',
      'status': 'preparing',
      'payload': {
        'lines': [
          {
            'coffee': coffee,
            'size': 'M',
            'quantity': 2,
            'unit_price_cents': 450,
          },
        ],
        'delivery': true,
        'customer_name': 'Customer',
        'address': {
          'label': 'Home',
          'street': '123 Main Street',
          'city': 'Lahore',
          'phone': '123456789',
        },
        'note': '',
        'delivery_cents': 200,
        'total_cents': 1100,
      },
    });
    expect(order.draft.totalCents, 1100);
    expect(order.status, 'preparing');
    expect(order.cancelled, false);
    expect(addressToRow(order.draft.address)?['city'], 'Lahore');
  });
  test('pickup address can be absent', () {
    expect(addressFromRow(null), isNull);
    expect(addressToRow(null), isNull);
  });
}
