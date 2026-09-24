import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/cart/domain/cart_item.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/catalog/domain/coffee.dart';
import '../../features/favorites/presentation/controllers/favorite_controller.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
import '../../features/orders/data/supabase_order_repository.dart';
import '../../features/orders/presentation/controllers/order_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import 'backend_codec.dart';
import 'supabase_customer_repository.dart';

class CustomerSession extends GetxController with WidgetsBindingObserver {
  CustomerSession(this.client, this.data, this.orders);
  final SupabaseClient client;
  final SupabaseCustomerRepository data;
  final SupabaseOrderRepository orders;
  List<Coffee> catalog = [];
  String? error;
  String? orderRefreshError;
  bool isStaff = false;
  String? _owner;
  bool _hydrating = false, _dirty = false, _refreshing = false;
  Timer? _timer, _poll;
  Future<void>? _saving;
  int _revision = 0;
  CartController get cart => Get.find<CartController>();
  FavoriteController get favorites => Get.find<FavoriteController>();
  ProfileController get profile => Get.find<ProfileController>();
  NotificationController get notifications =>
      Get.find<NotificationController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    cart.onChanged = changed;
    favorites.onChanged = changed;
    profile.onChanged = changed;
    notifications.onChanged = changed;
    final auth = Get.find<AuthController>();
    auth.loadSession = load;
    auth.beforeSignOut = flush;
    auth.clearSession = clear;
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => refreshOrders());
  }

  Future<void> load() async {
    final owner = client.auth.currentUser?.id;
    if (owner == null) throw StateError('Sign in to load your account.');
    // Fetch everything before replacing visible state, so failed loads cannot
    // partially restore another customer's shopping session.
    final products = await data.loadCatalog();
    final state = await data.loadState();
    final history = await orders.load();
    final staff = await data.isStaff();
    if (client.auth.currentUser?.id != owner) return;
    clear();
    _hydrating = true;
    try {
      catalog = products;
      isStaff = staff;
      final byId = {for (final c in products) c.id: c};
      for (final row in (state['cart'] as List? ?? [])) {
        final coffee = byId[row['id']];
        final quantity = row['quantity'];
        if (coffee != null &&
            quantity is int &&
            quantity >= 1 &&
            quantity <= 999 &&
            ['S', 'M', 'L'].contains(row['size'])) {
          cart.restoreItem(
            CartItem(coffee: coffee, size: row['size'], quantity: quantity),
          );
        }
      }
      for (final id in (state['favorites'] as List? ?? [])) {
        final coffee = byId[id];
        if (coffee != null && !favorites.isFavorite(coffee)) {
          favorites.toggleFavorite(coffee);
        }
      }
      profile.savePhone(state['phone'] as String? ?? '');
      profile.saveAddress(addressFromRow(state['address']));
      profile.setAlerts(state['order_alerts'] as bool? ?? true);
      Get.find<OrderController>().restore(history);
      final read = (state['read_notifications'] as List? ?? []).toSet();
      final visible = (state['visible_notifications'] as List?)?.toSet();
      notifications.restore([
        for (final order in history)
          if (visible?.contains(order.id) ?? profile.orderAlerts)
            ShopNotification(
              id: order.id,
              title: 'Order ${order.status}',
              body: 'Open your order for details.',
              createdAt: order.createdAt,
              orderId: order.id,
            )..read = read.contains(order.id),
      ]);
      _owner = owner;
      error = null;
    } finally {
      _hydrating = false;
      update();
    }
  }

  Map<String, dynamic> snapshot() => {
    'version': 1,
    'cart': [
      for (final item in cart.items)
        {'id': item.coffee.id, 'size': item.size, 'quantity': item.quantity},
    ],
    'favorites': favorites.favorites.map((c) => c.id).toList(),
    'phone': profile.phone,
    'address': addressToRow(profile.address),
    'order_alerts': profile.orderAlerts,
    'visible_notifications': notifications.items
        .take(200)
        .map((n) => n.id)
        .toList(),
    'read_notifications': notifications.items
        .where((n) => n.read)
        .take(200)
        .map((n) => n.id)
        .toList(),
  };

  void changed() {
    if (_hydrating || _owner == null) return;
    _dirty = true;
    _revision++;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await flush();
      } catch (_) {
        /* Retain dirty state for retry. */
      }
    });
  }

  Future<void> flush() {
    _timer?.cancel();
    return _saving ??= _drain().whenComplete(() => _saving = null);
  }

  Future<void> _drain() async {
    while (_dirty && _owner != null) {
      final owner = _owner!;
      final revision = _revision;
      if (client.auth.currentUser?.id != owner) return;
      try {
        await data.saveState(snapshot());
        if (_owner != owner) return;
        if (_revision == revision) _dirty = false;
        error = null;
      } catch (_) {
        if (_owner != owner) return;
        error = 'Your changes are not synced. Check your connection and retry.';
        rethrow;
      } finally {
        update();
      }
    }
  }

  Future<void> refreshOrders() async {
    if (_owner == null || _refreshing || Get.find<OrderController>().busy) {
      return;
    }
    final owner = _owner;
    _refreshing = true;
    try {
      final history = await orders.load();
      if (_owner == owner && !Get.find<OrderController>().busy) {
        final oldStatuses = {
          for (final order in Get.find<OrderController>().orders)
            order.id: order.status,
        };
        Get.find<OrderController>().restore(history);
        if (profile.orderAlerts) {
          for (final order in history) {
            if (oldStatuses[order.id] != order.status) {
              notifications.addStatus(order.id, order.status);
            }
          }
        }
        orderRefreshError = null;
      }
    } catch (_) {
      if (_owner == owner) {
        orderRefreshError =
            'Could not refresh orders. Check your connection and retry.';
      }
    } finally {
      _refreshing = false;
      update();
    }
  }

  Future<void> refreshCatalog() async {
    final owner = _owner;
    if (owner == null) return;
    final products = await data.loadCatalog();
    if (_owner != owner) return;
    final items = cart.items;
    final saved = favorites.favorites;
    final byId = {for (final coffee in products) coffee.id: coffee};
    _hydrating = true;
    try {
      catalog = products;
      cart.clearCart();
      for (final item in items) {
        final coffee = byId[item.coffee.id];
        if (coffee != null) {
          cart.restoreItem(
            CartItem(coffee: coffee, size: item.size, quantity: item.quantity),
          );
        }
      }
      favorites.clear();
      for (final old in saved) {
        final coffee = byId[old.id];
        if (coffee != null) favorites.toggleFavorite(coffee);
      }
    } finally {
      _hydrating = false;
    }
    changed();
    update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _poll ??= Timer.periodic(
        const Duration(seconds: 30),
        (_) => refreshOrders(),
      );
      refreshOrders();
    } else {
      _poll?.cancel();
      _poll = null;
    }
    flush().catchError((Object _) {});
  }

  void clear() {
    _timer?.cancel();
    _owner = null;
    _dirty = false;
    _hydrating = true;
    cart.clearCart();
    favorites.clear();
    profile.clear();
    notifications.clear();
    Get.find<OrderController>().clear();
    catalog = [];
    isStaff = false;
    orderRefreshError = null;
    error = null;
    _hydrating = false;
    update();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    cart.onChanged = null;
    favorites.onChanged = null;
    profile.onChanged = null;
    notifications.onChanged = null;
    super.onClose();
  }
}
