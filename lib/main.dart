import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_coffee_shop/providers/cart_provider.dart';
import 'package:my_coffee_shop/providers/favorite_provider.dart';
import 'package:my_coffee_shop/providers/theme_provider.dart';
import 'package:my_coffee_shop/views/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          primary: Colors.orange,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1E222A),
          primary: Colors.orange,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}