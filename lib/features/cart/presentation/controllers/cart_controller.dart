import 'package:get/get.dart';
import 'package:my_coffee_shop/features/cart/domain/cart_item.dart';
import 'package:my_coffee_shop/features/catalog/domain/coffee.dart';

class CartController extends GetxController {
  void Function()? onChanged;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCents => _items.fold(0, (sum, item) => sum + item.totalCents);

  /// Total price of all items in the cart
  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  /// Total number of individual items in the cart
  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  /// Adds a coffee to cart with a specific size ('S', 'M', 'L')
  void addItem(Coffee coffee, String size) {
    coffee.priceCentsFor(size);
    // Check if an item with the exact same coffee ID and size exists
    final existingIndex = _items.indexWhere(
      (item) => item.coffee.id == coffee.id && item.size == size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(coffee: coffee, size: size, quantity: 1));
    }
    update();
    onChanged?.call();
  }

  /// Increments quantity for a specific cart item
  void incrementQuantity(CartItem item) {
    if (!_items.contains(item)) return;
    item.quantity++;
    update();
    onChanged?.call();
  }

  /// Decrements quantity; if quantity reaches 0, removes the item
  void decrementQuantity(CartItem item) {
    if (!_items.contains(item)) return;
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    update();
    onChanged?.call();
  }

  /// Removes an item completely from cart
  void removeItem(CartItem item) {
    _items.remove(item);
    update();
    onChanged?.call();
  }

  void restoreItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (current) =>
          current.coffee.id == item.coffee.id && current.size == item.size,
    );
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    update();
    onChanged?.call();
  }

  /// Clears the entire cart (e.g. after payment)
  void clearCart() {
    _items.clear();
    update();
    onChanged?.call();
  }
}
