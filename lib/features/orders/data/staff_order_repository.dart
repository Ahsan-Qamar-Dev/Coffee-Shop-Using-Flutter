import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/backend/backend_codec.dart';
import '../domain/coffee_order.dart';

abstract class StaffOrderRepository {
  factory StaffOrderRepository(SupabaseClient client) =
      SupabaseStaffOrderRepository;
  Future<bool> isOwner();
  Future<List<Map<String, dynamic>>> menu();
  Future<List<Map<String, dynamic>>> team();
  Future<void> updateCoffee(Map<String, dynamic> values);
  Future<void> setStaff(String email, bool enabled);
  Future<List<CoffeeOrder>> load();
  Future<CoffeeOrder> setStatus(String id, String status);
}

class SupabaseStaffOrderRepository implements StaffOrderRepository {
  SupabaseStaffOrderRepository(this.client);
  final SupabaseClient client;
  @override
  Future<bool> isOwner() async => await client.rpc('is_store_owner') == true;
  @override
  Future<List<Map<String, dynamic>>> menu() async =>
      (await client.rpc('owner_menu') as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
  @override
  Future<List<Map<String, dynamic>>> team() async =>
      (await client.rpc('owner_team') as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
  @override
  Future<void> updateCoffee(Map<String, dynamic> values) async {
    await client.rpc('owner_update_coffee', params: values);
  }

  @override
  Future<void> setStaff(String email, bool enabled) async {
    await client.rpc(
      'owner_set_staff',
      params: {'p_email': email, 'p_enabled': enabled},
    );
  }

  @override
  Future<List<CoffeeOrder>> load() async {
    final rows = await client.rpc('staff_orders') as List;
    return rows
        .map((row) => orderFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<CoffeeOrder> setStatus(String id, String status) async {
    final row = await client.rpc(
      'staff_set_order_status',
      params: {'p_order_id': id, 'p_status': status},
    );
    return orderFromRow(Map<String, dynamic>.from(row as Map));
  }
}
