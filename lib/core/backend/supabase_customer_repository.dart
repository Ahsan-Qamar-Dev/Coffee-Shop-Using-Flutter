import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/catalog/domain/coffee.dart';
import 'backend_codec.dart';

/// Customer-scoped data. Database RLS is the authority for account isolation.
class SupabaseCustomerRepository {
  SupabaseCustomerRepository(this.client);
  final SupabaseClient client;

  Future<bool> isStaff() async {
    try {
      return await client.rpc('is_store_staff') == true;
    } catch (_) {
      return false;
    } // Missing/revoked staff access never blocks customers.
  }

  String get _userId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw StateError('Sign in before accessing customer data.');
    return id;
  }

  Future<List<Coffee>> loadCatalog() async {
    final rows = await client
        .from('coffees')
        .select()
        .eq('available', true)
        .order('sort_order')
        .order('id');
    return rows.map(coffeeFromRow).toList(growable: false);
  }

  Future<Map<String, dynamic>> loadState() async {
    final row = await client
        .from('customer_state')
        .select('state')
        .eq('user_id', _userId)
        .maybeSingle();
    return row == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(row['state'] as Map);
  }

  Future<void> saveState(Map<String, dynamic> state) async {
    await client.from('customer_state').upsert({
      'user_id': _userId,
      'state': state,
    });
  }
}
