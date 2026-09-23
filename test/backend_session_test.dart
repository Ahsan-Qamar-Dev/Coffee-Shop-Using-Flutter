import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_coffee_shop/app/app_binding.dart';
import 'package:my_coffee_shop/core/backend/customer_session.dart';
import 'package:my_coffee_shop/core/backend/supabase_customer_repository.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';
import 'package:my_coffee_shop/features/catalog/domain/coffee.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:my_coffee_shop/features/orders/data/supabase_order_repository.dart';
import 'package:my_coffee_shop/features/orders/domain/coffee_order.dart';
import 'package:my_coffee_shop/features/profile/domain/customer_preferences.dart';

const uid = '11111111-1111-4111-8111-111111111111';
Map<String, dynamic> authResponse() => {
  'access_token':
      '${base64Url.encode(utf8.encode('{}'))}.${base64Url.encode(utf8.encode(jsonEncode({'sub': uid, 'exp': 4102444800})))}.signature',
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'test-refresh',
  'user': {
    'id': uid,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'test@example.test',
    'created_at': '2026-09-23T00:00:00Z',
    'app_metadata': {},
    'user_metadata': {},
  },
};

class MemoryData extends SupabaseCustomerRepository {
  MemoryData(super.client);
  Map<String, dynamic> state = {};
  int writes = 0;
  bool fail = false;
  Completer<void>? held;
  @override
  Future<List<Coffee>> loadCatalog() async => sampleCoffees;
  @override
  Future<Map<String, dynamic>> loadState() async => state;
  @override
  Future<void> saveState(Map<String, dynamic> value) async {
    writes++;
    if (fail) throw StateError('offline');
    if (held != null) await held!.future;
    state = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  }
}

class MemoryOrders extends SupabaseOrderRepository {
  MemoryOrders(super.client);
  @override
  Future<List<CoffeeOrder>> load() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SupabaseClient client;
  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    AppBinding().dependencies();
    client = SupabaseClient(
      'https://test.supabase.co',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient(
        (r) async => http.Response(
          jsonEncode(authResponse()),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    await client.auth.signInWithPassword(
      email: 'test@example.test',
      password: 'test-only',
    );
  });
  tearDown(() async {
    Get.reset();
    await client.dispose();
  });

  test('restores saved cart at current menu prices and favorites', () async {
    final data = MemoryData(client)
      ..state = {
        'cart': [
          {'id': 'c1', 'size': 'M', 'quantity': 2},
        ],
        'favorites': ['c2'],
      };
    final session = Get.put(
      CustomerSession(client, data, MemoryOrders(client)),
    );
    await session.load();
    expect(Get.find<CartController>().totalCents, 940);
    expect(Get.find<FavoriteController>().favorites.single.id, 'c2');
    expect(data.writes, 0);
    session.clear();
    await session.flush();
    expect(data.writes, 0);
    expect(Get.find<CartController>().items, isEmpty);
  });
  test('failed writes keep dirty changes and recover on retry', () async {
    final data = MemoryData(client);
    final session = Get.put(
      CustomerSession(client, data, MemoryOrders(client)),
    );
    await session.load();
    data.fail = true;
    Get.find<CartController>().addItem(sampleCoffees.first, 'S');
    await expectLater(session.flush(), throwsStateError);
    expect(session.error, isNotNull);
    data.fail = false;
    await session.flush();
    expect(session.error, isNull);
    expect((data.state['cart'] as List).length, 1);
  });
  test(
    'overlapping saves serialize and include edits made during upload',
    () async {
      final data = MemoryData(client);
      final session = Get.put(
        CustomerSession(client, data, MemoryOrders(client)),
      );
      await session.load();
      data.held = Completer<void>();
      Get.find<CartController>().addItem(sampleCoffees.first, 'S');
      final first = session.flush();
      Get.find<CartController>().addItem(sampleCoffees[1], 'S');
      final second = session.flush();
      expect(data.writes, 1);
      data.held!.complete();
      await Future.wait([first, second]);
      expect(data.writes, 2);
      expect((data.state['cart'] as List).length, 2);
    },
  );
  test(
    'request ID survives repository restart after ambiguous timeout',
    () async {
      final requestIds = <String>[];
      final transport = MockClient((request) async {
        if (request.url.path.contains('/auth/')) {
          return http.Response(
            jsonEncode(authResponse()),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        requestIds.add(
          (jsonDecode(request.body) as Map)['p_request_id'] as String,
        );
        throw http.ClientException('timeout after server accepted request');
      });
      final remote = SupabaseClient(
        'https://test.supabase.co',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: transport,
      );
      await remote.auth.signInWithPassword(
        email: 'test@example.test',
        password: 'test-only',
      );
      final draft = OrderDraft(
        lines: [
          OrderLine(
            coffee: sampleCoffees.first,
            size: 'S',
            quantity: 1,
            unitPriceCents: 420,
          ),
        ],
        delivery: false,
        payment: PaymentChoice.cash,
        customerName: 'Test',
      );
      await expectLater(
        SupabaseOrderRepository(remote).place(draft),
        throwsA(anything),
      );
      await expectLater(
        SupabaseOrderRepository(remote).place(draft),
        throwsA(anything),
      );
      expect(requestIds.length, greaterThanOrEqualTo(2));
      expect(requestIds.toSet().length, 1);
      await remote.dispose();
    },
  );
}
