import 'package:get/get.dart';

import '../../../../core/backend/backend_config.dart';

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
  void Function()? onChanged;
  final List<ShopNotification> _items = [];
  List<ShopNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.read).length;
  void addStatus(String orderId, String status) {
    _items.removeWhere((item) => item.orderId == orderId);
    _items.insert(
      0,
      ShopNotification(
        id: orderId,
        title: 'Your order is $status',
        body: 'Open your order for the latest details.',
        createdAt: DateTime.now(),
        orderId: orderId,
      ),
    );
    if (_items.length > 200) _items.removeRange(200, _items.length);
    update();
    onChanged?.call();
  }

  void addOrder(String orderId, {DateTime? createdAt}) {
    _items.insert(
      0,
      ShopNotification(
        id: orderId,
        title: BackendConfig.live
            ? 'Your test order is confirmed'
            : 'Your preview order is confirmed',
        body: 'Open your order to see the receipt and collection or delivery details.',
        createdAt: createdAt ?? DateTime.now(),
        orderId: orderId,
      ),
    );
    update();
    onChanged?.call();
  }

  void markRead(ShopNotification item) {
    item.read = true;
    update();
    onChanged?.call();
  }

  void markAllRead() {
    for (final item in _items) {
      item.read = true;
    }
    update();
    onChanged?.call();
  }

  void clear() {
    _items.clear();
    update();
    onChanged?.call();
  }

  void restore(List<ShopNotification> items) {
    _items
      ..clear()
      ..addAll(items);
    update();
    onChanged?.call();
  }
}
