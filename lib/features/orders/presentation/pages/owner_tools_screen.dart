import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/shop_widgets.dart';
import '../../data/staff_order_repository.dart';

class OwnerToolsScreen extends StatefulWidget {
  const OwnerToolsScreen({super.key, required this.repository});
  final StaffOrderRepository repository;
  @override
  State<OwnerToolsScreen> createState() => _OwnerToolsScreenState();
}

class _OwnerToolsScreenState extends State<OwnerToolsScreen> {
  List<Map<String, dynamic>> _menu = [], _team = [];
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save or load changes. Please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fetch() async {
    final menu = await widget.repository.menu();
    final team = await widget.repository.team();
    if (mounted) {
      setState(() {
        _menu = menu;
        _team = team;
      });
    }
  }

  Future<void> _reload() => _run(_fetch);
  Future<void> _edit(Map<String, dynamic> coffee) async {
    final name = TextEditingController(text: coffee['name'] as String);
    final description = TextEditingController(
      text: coffee['description'] as String,
    );
    final price = TextEditingController(
      text: ((coffee['price_cents'] as num) / 100).toStringAsFixed(2),
    );
    var available = coffee['available'] as bool;
    final form = GlobalKey<FormState>();
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, change) => AlertDialog(
          title: const Text('Edit coffee'),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    maxLength: 80,
                    validator: (v) =>
                        (v?.trim().length ?? 0) < 2 ? 'Enter a name' : null,
                  ),
                  TextFormField(
                    controller: price,
                    decoration: const InputDecoration(
                      labelText: 'Small price (USD)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final p = double.tryParse(v ?? '');
                      return p == null || !p.isFinite || p < 0.01 || p > 1000
                          ? 'Enter 0.01 to 1000.00'
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                    maxLength: 2000,
                    validator: (v) => (v?.trim().length ?? 0) < 10
                        ? 'Use at least 10 characters'
                        : null,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Available'),
                    value: available,
                    onChanged: (v) => change(() => available = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) {
                  Navigator.pop(context, {
                    'p_id': coffee['id'],
                    'p_name': name.text.trim(),
                    'p_description': description.text.trim(),
                    'p_price': (double.parse(price.text) * 100).round(),
                    'p_available': available,
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    // Controllers live until the dialog's closing animation completes.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    description.dispose();
    price.dispose();
    if (values != null && mounted) {
      await _run(() async {
        await widget.repository.updateCoffee(values);
        await _fetch();
      });
    }
  }

  Future<void> _addStaff() async {
    final input = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grant staff access'),
        content: TextField(
          controller: input,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Confirmed account email',
            helperText: 'Staff can see and manage all orders.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text.trim()),
            child: const Text('Grant access'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    input.dispose();
    if (email != null && email.isNotEmpty && mounted) {
      await _run(() async {
        await widget.repository.setStaff(email, true);
        await _fetch();
      });
    }
  }

  Future<void> _remove(Map<String, dynamic> member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove staff access?'),
        content: Text('${member['email']} will lose access to store orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove access'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(() async {
        await widget.repository.setStaff(member['email'] as String, false);
        await _fetch();
      });
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Owner tools'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Menu'),
            Tab(text: 'Team'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  PageBody(
                    maxWidth: 800,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'Menu & availability',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Medium adds \$0.50; large adds \$1.00. Existing receipts keep their original prices.',
                        ),
                        for (final coffee in _menu)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ShopCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(coffee['name'] as String),
                                subtitle: Text(
                                  '\$${((coffee['price_cents'] as num) / 100).toStringAsFixed(2)} · ${coffee['available'] == true ? "Available" : "Unavailable"}',
                                ),
                                trailing: IconButton(
                                  tooltip: 'Edit ${coffee['name']}',
                                  onPressed: _busy ? null : () => _edit(coffee),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PageBody(
                    maxWidth: 800,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        FilledButton.icon(
                          onPressed: _busy ? null : _addStaff,
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Add staff member'),
                        ),
                        const SizedBox(height: 16),
                        for (final member in _team)
                          ListTile(
                            title: Text(
                              member['email'] as String? ?? 'Account',
                            ),
                            subtitle: Text(member['role'] as String),
                            trailing: member['role'] == 'owner'
                                ? const Icon(Icons.verified_user_outlined)
                                : IconButton(
                                    tooltip: 'Remove access',
                                    onPressed: _busy
                                        ? null
                                        : () => _remove(member),
                                    icon: const Icon(
                                      Icons.person_remove_outlined,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
