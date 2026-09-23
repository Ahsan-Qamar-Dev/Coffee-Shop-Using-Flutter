import 'dart:convert';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/domain/customer_preferences.dart';
import '../../../../core/backend/backend_codec.dart';
import '../domain/coffee_order.dart';

class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository(this.client);
  final SupabaseClient client;
  String? _requestId, _fingerprint;
  String _uuid() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<List<CoffeeOrder>> load() async {
    final rows = await client
        .from('orders')
        .select()
        .order('created_at', ascending: false)
        .limit(200);
    return rows.map(orderFromRow).toList();
  }

  void resetRequest() {
    _requestId = null;
    _fingerprint = null;
  }

  @override
  Future<CoffeeOrder> place(OrderDraft draft) async {
    if (draft.payment != PaymentChoice.cash) {
      throw const OrderFailure('Choose cash on collection or delivery.');
    }
    final params = <String, dynamic>{
      'p_lines': [
        for (final line in draft.lines)
          {
            'coffee_id': line.coffee.id,
            'size': line.size,
            'quantity': line.quantity,
          },
      ],
      'p_delivery': draft.delivery,
      'p_customer_name': draft.customerName,
      'p_address': addressToRow(draft.address),
      'p_note': draft.note,
      'p_expected_total': draft.totalCents,
    };
    final fingerprint = '${client.auth.currentUser?.id}:${jsonEncode(params)}';
    if (_fingerprint != fingerprint) {
      _fingerprint = fingerprint;
      _requestId = _uuid();
    }
    params['p_request_id'] = _requestId;
    try {
      final row = await client.rpc('place_order', params: params);
      final order = orderFromRow(Map<String, dynamic>.from(row as Map));
      resetRequest();
      return order;
    } on PostgrestException catch (e) {
      throw OrderFailure(e.message);
    }
  }

  @override
  Future<CoffeeOrder> cancel(CoffeeOrder order) async {
    try {
      final row = await client.rpc(
        'cancel_order',
        params: {'p_order_id': order.id},
      );
      return orderFromRow(Map<String, dynamic>.from(row as Map));
    } on PostgrestException catch (e) {
      throw OrderFailure(e.message);
    }
  }
}
