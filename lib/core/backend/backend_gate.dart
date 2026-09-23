import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/supabase_auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/catalog/presentation/pages/home_page.dart';
import 'customer_session.dart';

class BackendGate extends StatefulWidget {
  const BackendGate({super.key});
  @override
  State<BackendGate> createState() => _BackendGateState();
}

class _BackendGateState extends State<BackendGate> {
  late Future<void> _loading;
  Future<void> _restore() async {
    final user = SupabaseAuthRepository(Supabase.instance.client).currentUser;
    if (user != null) {
      await Get.find<CustomerSession>().load();
      Get.find<AuthController>().user = user;
    }
  }

  @override
  void initState() {
    super.initState();
    _loading = _restore();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _loading,
    builder: (context, state) {
      if (state.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (state.hasError) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your account could not be loaded. Check your connection.',
                  ),
                  FilledButton(
                    onPressed: () => setState(() => _loading = _restore()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Get.find<AuthController>().user == null
          ? const LoginPage()
          : const HomePage();
    },
  );
}

class BackendStatus extends StatefulWidget {
  const BackendStatus({super.key, required this.child});
  final Widget child;
  @override
  State<BackendStatus> createState() => _BackendStatusState();
}

class _BackendStatusState extends State<BackendStatus> {
  StreamSubscription<AuthState>? _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      state,
    ) {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        Get.offAll(() => const RecoveryPasswordPage());
      } else if (state.event == AuthChangeEvent.signedIn &&
          Get.find<AuthController>().user == null &&
          !Get.find<AuthController>().busy) {
        Get.offAll(() => const BackendGate());
      } else if (state.event == AuthChangeEvent.signedOut) {
        Get.find<CustomerSession>().clear();
        Get.find<AuthController>().user = null;
        Get.offAll(() => const LoginPage());
      }
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: widget.child),
      GetBuilder<CustomerSession>(
        builder: (session) => session.error == null
            ? const SizedBox.shrink()
            : Material(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: Text(session.error!)),
                        TextButton(
                          onPressed: () async {
                            try {
                              await session.flush();
                            } catch (_) {
                              /* banner remains */
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ],
  );
}

class RecoveryPasswordPage extends StatefulWidget {
  const RecoveryPasswordPage({super.key});
  @override
  State<RecoveryPasswordPage> createState() => _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends State<RecoveryPasswordPage> {
  final _password = TextEditingController(),
      _confirmation = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 8 || _password.text != _confirmation.text) {
      setState(
        () => _error = 'Use at least 8 characters and matching passwords.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _password.text),
      );
      if (mounted) Get.offAll(() => const BackendGate());
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not reset password. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New password')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _password,
                obscureText: true,
                enabled: !_busy,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmation,
                obscureText: true,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Saving…' : 'Save password'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
