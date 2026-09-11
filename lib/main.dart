import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const LoginPage(),
    ),
  );
}
