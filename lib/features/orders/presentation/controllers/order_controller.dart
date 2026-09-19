import 'package:get/get.dart';

import '../../domain/coffee_order.dart';

class OrderController extends GetxController {
  OrderController(this.repository);
  final OrderRepository repository;
  final List<CoffeeOrder> _orders = [];
  bool busy = false;
  String? error;
  List<CoffeeOrder> get orders => List.unmodifiable(_orders);
  CoffeeOrder? byId(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<CoffeeOrder?> place(OrderDraft draft) async {
    if (busy) return null;
    busy = true;
    error = null;
    update();
    try {
      final order = await repository.place(draft);
      _orders.insert(0, order);
      return order;
    } catch (_) {
      error = 'We could not create your order. Your cart is safe; please try again.';
      return null;
    } finally {
      busy = false;
      update();
    }
  }

  Future<bool> cancel(String id) async {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0 || busy) return false;
    busy = true;
    error = null;
    update();
    try {
      _orders[index] = await repository.cancel(_orders[index]);
      return true;
    } catch (_) {
      error = 'Could not cancel the order. Please try again.';
      return false;
    } finally {
      busy = false;
      update();
    }
  }

  void clear() {
    _orders.clear();
    error = null;
    update();
  }
}
