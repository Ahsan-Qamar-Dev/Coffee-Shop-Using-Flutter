import 'coffee_model.dart';

class CartItem {
  final Coffee coffee;
  final String size; // 'S', 'M', or 'L'
  int quantity;

  CartItem({
    required this.coffee,
    required this.size,
    this.quantity = 1,
  });

  /// Calculates total price considering size multiplier & quantity
  double get totalPrice {
    double sizeExtra = 0.0;
    if (size == 'M') sizeExtra = 0.50;
    if (size == 'L') sizeExtra = 1.00;
    return (coffee.price + sizeExtra) * quantity;
  }
}
