import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/orders/data/receipt_pdf.dart';
import 'package:my_coffee_shop/features/orders/domain/coffee_order.dart';
import 'package:my_coffee_shop/features/profile/domain/customer_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a complete styled receipt PDF', () async {
    final order = CoffeeOrder(
      id: 'CF-2048',
      createdAt: DateTime(2026, 9, 22, 14, 30),
      draft: OrderDraft(
        lines: [
          OrderLine(
            coffee: sampleCoffees.first,
            size: 'M',
            quantity: 2,
            unitPriceCents: 470,
          ),
        ],
        delivery: true,
        payment: PaymentChoice.demoCard,
        customerName: 'Coffee Lover',
        address: const DeliveryAddress(
          label: 'Home',
          street: '12 Test Street',
          city: 'Lahore',
          phone: '+92 300 1234567',
        ),
        note: 'Extra hot',
      ),
    );

    final bytes = await ReceiptPdf.build(order);

    if (const bool.fromEnvironment('EXPORT_PDF_FIXTURES')) {
      await File('../../outputs/receipt-preview.pdf').writeAsBytes(bytes);
    }
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
  test('large orders paginate without losing line items', () async {
    final order = CoffeeOrder(
      id: 'CF-LARGE',
      createdAt: DateTime(2026, 9, 22),
      draft: OrderDraft(
        lines: [
          for (final coffee in sampleCoffees)
            for (final size in ['S', 'M', 'L'])
              OrderLine(
                coffee: coffee,
                size: size,
                quantity: 2,
                unitPriceCents: coffee.priceCentsFor(size),
              ),
        ],
        delivery: false,
        payment: PaymentChoice.cash,
        customerName: 'Coffee Lover',
      ),
    );
    final bytes = await ReceiptPdf.build(order);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    if (const bool.fromEnvironment('EXPORT_PDF_FIXTURES')) {
      await File('../../outputs/receipt-large-preview.pdf').writeAsBytes(bytes);
    }
  });
}
