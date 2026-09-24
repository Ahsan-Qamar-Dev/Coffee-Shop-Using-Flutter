import 'package:get/get.dart';

import '../../catalog/data/sample_catalog.dart';
import '../domain/coffee_order.dart';
import '../presentation/controllers/order_controller.dart';
import 'staff_order_repository.dart';

class DemoStaffRepository implements StaffOrderRepository {
  final List<Map<String, dynamic>> _menu = [
    for (final c in sampleCoffees)
      {
        'id': c.id,
        'name': c.name,
        'description': c.description,
        'price_cents': c.priceCentsFor('S'),
        'available': true,
      },
  ];
  final List<Map<String, dynamic>> _team = [
    {'email': 'demo@coffee.test', 'role': 'owner'},
  ];
  @override
  Future<bool> isOwner() async => true;
  @override
  Future<List<Map<String, dynamic>>> menu() async =>
      _menu.map((r) => Map<String, dynamic>.from(r)).toList();
  @override
  Future<List<Map<String, dynamic>>> team() async =>
      _team.map((r) => Map<String, dynamic>.from(r)).toList();
  @override
  Future<void> updateCoffee(Map<String, dynamic> values) async {
    final row = _menu.firstWhere((r) => r['id'] == values['p_id']);
    row.addAll({
      'name': values['p_name'],
      'description': values['p_description'],
      'price_cents': values['p_price'],
      'available': values['p_available'],
    });
  }

  @override
  Future<void> setStaff(String email, bool enabled) async {
    if (email == 'demo@coffee.test') throw StateError('Cannot change owner');
    _team.removeWhere((r) => r['email'] == email);
    if (enabled) _team.add({'email': email, 'role': 'staff'});
  }

  @override
  Future<List<CoffeeOrder>> load() async => Get.find<OrderController>().orders;
  @override
  Future<CoffeeOrder> setStatus(String id, String status) async {
    final controller = Get.find<OrderController>();
    final old = controller.byId(id)!;
    final next = CoffeeOrder(
      id: old.id,
      createdAt: old.createdAt,
      draft: old.draft,
      status: status,
      cancelled: status == 'cancelled',
    );
    controller.restore([
      for (final row in controller.orders) row.id == id ? next : row,
    ]);
    return next;
  }
}
