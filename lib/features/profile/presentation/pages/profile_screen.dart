import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/sign_out.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../orders/presentation/pages/order_pages.dart';
import '../../domain/customer_preferences.dart';
import '../controllers/profile_controller.dart';
import 'account_pages.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile & settings')),
    body: SafeArea(
      child: PageBody(
        maxWidth: 720,
        child: GetBuilder<ProfileController>(
          builder: (profile) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              GetBuilder<AuthController>(
                builder: (auth) => ShopCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Text(
                          (auth.user?.name ?? 'C')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.user?.name ?? 'Coffee Lover',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        auth.user?.email ?? 'Preview account',
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _open(context, const PersonalDetailsScreen()),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SectionTitle('Your account'),
              ShopCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _link(
                      context,
                      Icons.receipt_long_outlined,
                      'My orders',
                      'Receipts and your recent coffee moments',
                      const OrdersScreen(),
                    ),
                    _link(
                      context,
                      Icons.person_outline,
                      'Personal details',
                      profile.phone.isEmpty
                          ? 'Add your contact details'
                          : profile.phone,
                      const PersonalDetailsScreen(),
                    ),
                    _link(
                      context,
                      Icons.location_on_outlined,
                      'Delivery address',
                      profile.address?.summary ?? 'Add an address for delivery',
                      const AddressScreen(),
                    ),
                    _link(
                      context,
                      Icons.payment_outlined,
                      'Payment preferences',
                      profile.payment.label,
                      const PaymentMethodsScreen(),
                    ),
                    _link(
                      context,
                      Icons.lock_outline,
                      'Security & password',
                      'Update your preview password',
                      const SecurityScreen(),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Make it yours'),
              ShopCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    GetBuilder<ThemeController>(
                      builder: (theme) => SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark mode'),
                        value: theme.isDarkMode,
                        onChanged: theme.toggleTheme,
                      ),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Order alerts'),
                      subtitle: const Text(
                        'In-app updates for your preview orders',
                      ),
                      value: profile.orderAlerts,
                      onChanged: profile.setAlerts,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _link(
                context,
                Icons.help_outline,
                'Help & about',
                'A few answers before your next cup',
                const HelpScreen(),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => confirmSignOut(context),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
              const SizedBox(height: 14),
              Text(
                'Preview settings last for this signed-in session.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _link(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => _open(context, page),
  );
  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
}
