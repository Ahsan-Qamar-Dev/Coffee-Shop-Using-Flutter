import 'package:get/get.dart';

class ShopNotification {
  ShopNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.orderId,
  });
  final String id, title, body;
  final DateTime createdAt;
  final String? orderId;
  bool read = false;
}

class NotificationController extends GetxController {
  final List<ShopNotification> _items = [];
  List<ShopNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.read).length;
  void addOrder(String orderId, {DateTime? createdAt}) {
    _items.insert(
      0,
      ShopNotification(
        id: orderId,
        title: 'Your preview order is confirmed',
        body: 'Open your order to see the receipt and collection or delivery details.',
        createdAt: createdAt ?? DateTime.now(),
        orderId: orderId,
      ),
    );
    update();
  }

  void markRead(ShopNotification item) {
    item.read = true;
    update();
  }

  void markAllRead() {
    for (final item in _items) {
      item.read = true;
    }
    update();
  }

  void clear() {
    _items.clear();
    update();
  }

  void restore(List<ShopNotification> items) {
    _items
      ..clear()
      ..addAll(items);
    update();
  }
}
