import 'package:flutter/material.dart';

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/backend/backend_config.dart';
import '../../data/demo_staff_repository.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../data/staff_order_repository.dart';
import '../../domain/coffee_order.dart';
import 'order_pages.dart';
import 'owner_tools_screen.dart';

class StaffOrdersScreen extends StatefulWidget {
  const StaffOrdersScreen({super.key, this.repository});
  final StaffOrderRepository? repository;
  @override
  State<StaffOrdersScreen> createState() => _StaffOrdersScreenState();
}

class _StaffOrdersScreenState extends State<StaffOrdersScreen>
    with WidgetsBindingObserver {
  late final StaffOrderRepository _repository =
      widget.repository ??
      (BackendConfig.live
          ? StaffOrderRepository(Supabase.instance.client)
          : DemoStaffRepository());
  Timer? _poll;
  bool _owner = false;
  List<CoffeeOrder> _orders = [];
  bool _busy = false;
  String? _error;
  String _filter = 'Active';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startPolling();
  }

  void _startPolling() {
    _poll ??= Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _load();
    } else {
      _poll?.cancel();
      _poll = null;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final orders = await _repository.load();
      final owner = await _repository.isOwner();
      if (mounted) {
        setState(() {
          _orders = orders;
          _owner = owner;
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load orders. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _change(CoffeeOrder order, String status) async {
    if (_busy) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark order $status?'),
        content: Text('This updates ${order.draft.customerName}\'s order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await _repository.setStatus(order.id, status);
      if (mounted) {
        setState(
          () => _orders = [
            for (final row in _orders) row.id == order.id ? updated : row,
          ],
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not update order. Refresh before retrying.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _orders
        .where(
          (o) =>
              _filter == 'All' ||
              !['completed', 'cancelled'].contains(o.status),
        )
        .toList();
    final active = _orders
        .where((o) => !['completed', 'cancelled'].contains(o.status))
        .length;
    final completed = _orders.where((o) => o.status == 'completed').length;
    final value = _orders
        .where((o) => o.status == 'completed')
        .fold<int>(0, (sum, o) => sum + o.draft.totalCents);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store orders'),
        actions: [
          if (_owner)
            IconButton(
              tooltip: 'Owner tools',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => OwnerToolsScreen(repository: _repository),
                ),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          IconButton(
            tooltip: 'Refresh orders',
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: PageBody(
          maxWidth: 760,
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Text(
                  'Private test orders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (!BackendConfig.live)
                  const Text(
                    'Offline dashboard demo. Create an order in the customer flow to manage it here.',
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Chip(label: Text('$active active')),
                    Chip(label: Text('$completed completed')),
                    Chip(
                      label: Text(
                        'Completed value: \$${(value / 100).toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Summary covers the 200 most recent orders; order value is not verified payment revenue.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final filter in ['Active', 'All'])
                      ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                  ],
                ),
                if (_busy) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (!_busy && _error == null && visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No orders to show.'),
                  ),
                for (final order in visible)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ShopCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.draft.customerName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${orderDate(order.createdAt)} · ${order.status}',
                          ),
                          Text(
                            'Order ${order.id}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Divider(),
                          for (final line in order.draft.lines)
                            Text(
                              '${line.quantity} × ${line.coffee.name} · ${line.size}',
                            ),
                          PriceRow(
                            'Total',
                            order.draft.totalCents,
                            emphasized: true,
                          ),
                          Text(
                            order.draft.delivery
                                ? 'Delivery: ${order.draft.address?.summary ?? "Address unavailable"}'
                                : 'Pickup',
                          ),
                          if (order.draft.address != null)
                            Text(order.draft.address!.phone),
                          if (order.draft.note.isNotEmpty)
                            Text('Note: ${order.draft.note}'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (order.status == 'confirmed')
                                FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _change(order, 'preparing'),
                                  child: const Text('Start preparing'),
                                ),
                              if (order.status == 'preparing')
                                FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _change(order, 'ready'),
                                  child: const Text('Mark ready'),
                                ),
                              if (order.status == 'ready')
                                FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _change(order, 'completed'),
                                  child: const Text('Complete'),
                                ),
                              if (![
                                'completed',
                                'cancelled',
                              ].contains(order.status))
                                TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _change(order, 'cancelled'),
                                  child: const Text('Cancel order'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
