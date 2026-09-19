import 'package:my_coffee_shop/features/catalog/domain/coffee.dart';

class CartItem {
  final Coffee coffee;
  final String size; // 'S', 'M', or 'L'
  int quantity;

  CartItem({required this.coffee, required this.size, this.quantity = 1});

  int get unitPriceCents => coffee.priceCentsFor(size);
  int get totalCents => unitPriceCents * quantity;
  double get totalPrice => totalCents / 100;
}
