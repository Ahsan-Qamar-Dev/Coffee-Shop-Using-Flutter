import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/backend/backend_config.dart';
import 'core/backend/backend_gate.dart';

import 'app/app_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!const bool.fromEnvironment('DEMO_MODE')) {
    try {
      await Supabase.initialize(
        url: BackendConfig.url,
        publishableKey: BackendConfig.publishableKey,
      );
      BackendConfig.live = true;
    } catch (_) {
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not start Coffee Shop. Please retry.'),
                  FilledButton(onPressed: main, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }
  }
  AppBinding().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<ThemeController>(
    builder: (theme) => GetMaterialApp(
      title: 'My Coffee Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.create(Brightness.light),
      darkTheme: AppTheme.create(Brightness.dark),
      themeMode: theme.themeMode,
      builder: (context, child) =>
          BackendConfig.live ? BackendStatus(child: child!) : child!,
      home: BackendConfig.live ? const BackendGate() : const LoginPage(),
    ),
  );
}
