import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../sign_out.dart';
import '../../core/theme/theme_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/orders/presentation/pages/order_pages.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/profile/presentation/pages/help_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.onSelectTab});
  final ValueChanged<int> onSelectTab;
  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: GetBuilder<AuthController>(
              builder: (auth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Text(
                      (auth.user?.name ?? 'C').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.user?.name ?? 'Coffee Lover',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? 'Preview account',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          for (final entry in [
            (Icons.home_outlined, 'Home', 0),
            (Icons.favorite_border, 'Favorites', 1),
            (Icons.shopping_bag_outlined, 'Cart', 2),
            (Icons.notifications_outlined, 'Notifications', 3),
          ])
            ListTile(
              leading: Icon(entry.$1),
              title: Text(entry.$2),
              onTap: () {
                Navigator.pop(context);
                onSelectTab(entry.$3);
              },
            ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('My orders'),
            onTap: () => _open(context, const OrdersScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile & settings'),
            onTap: () => _open(context, const ProfileScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & about'),
            onTap: () => _open(context, const HelpScreen()),
          ),
          const Divider(),
          GetBuilder<ThemeController>(
            builder: (theme) => SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              value: theme.isDarkMode,
              onChanged: theme.toggleTheme,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              confirmSignOut(navigator.context);
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Made for your daily coffee moment.\nUI preview · 1.0',
              style: TextStyle(fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    ),
  );
  void _open(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
