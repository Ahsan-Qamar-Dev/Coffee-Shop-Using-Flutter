import 'package:my_coffee_shop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:my_coffee_shop/core/theme/theme_controller.dart';
import 'package:my_coffee_shop/app/sign_out.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/profile_screen.dart';
import 'package:my_coffee_shop/core/widgets/bold_text.dart';
import 'package:my_coffee_shop/core/widgets/light_text.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int)? onSelectTab;

  const CustomDrawer({super.key, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (_) {
        return GetBuilder<CartController>(
          builder: (_) {
            return GetBuilder<FavoriteController>(
              builder: (_) {
                final themeProvider = Get.find<ThemeController>();
                final cartProvider = Get.find<CartController>();
                final favProvider = Get.find<FavoriteController>();
                final isDark = themeProvider.isDarkMode;

                final bgColor = isDark ? const Color(0xFF1E222A) : Colors.white;
                final textColor = isDark ? Colors.white : Colors.black87;

                return Drawer(
                  backgroundColor: bgColor,
                  child: Column(
                    children: [
                      // User Profile Drawer Header
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF14181F)
                              : Colors.orange.shade800,
                        ),
                        currentAccountPicture: CircleAvatar(
                          radius: 35,
                          backgroundImage: const AssetImage('assets/Ahsan.png'),
                        ),
                        accountName: BoldText(
                          text:
                              Get.find<AuthController>().user?.name ??
                              'Coffee Lover',
                          size: 18,
                          color: Colors.white,
                        ),
                        accountEmail: LightText(
                          text:
                              Get.find<AuthController>().user?.email ??
                              'Preview account',
                          size: 13,
                          color: Colors.white70,
                        ),
                      ),

                      // Drawer Links List
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.home,
                                color: Colors.orange,
                              ),
                              title: BoldText(
                                text: "Home",
                                size: 15,
                                color: textColor,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                if (onSelectTab != null) onSelectTab!(0);
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              title: BoldText(
                                text: "Favorites",
                                size: 15,
                                color: textColor,
                              ),
                              trailing: favProvider.favorites.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${favProvider.favorites.length}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                if (onSelectTab != null) onSelectTab!(1);
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.shopping_cart,
                                color: Colors.orange,
                              ),
                              title: BoldText(
                                text: "Cart",
                                size: 15,
                                color: textColor,
                              ),
                              trailing: cartProvider.itemCount > 0
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${cartProvider.itemCount}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                if (onSelectTab != null) onSelectTab!(2);
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.orange,
                              ),
                              title: BoldText(
                                text: "Profile & Settings",
                                size: 15,
                                color: textColor,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(),

                            // Dark / Light Mode Switch
                            SwitchListTile(
                              secondary: Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: isDark
                                    ? Colors.orange
                                    : Colors.amber.shade700,
                              ),
                              title: BoldText(
                                text: isDark ? "Dark Mode" : "Light Mode",
                                size: 15,
                                color: textColor,
                              ),
                              value: isDark,
                              activeTrackColor: Colors.orange,
                              onChanged: (value) {
                                themeProvider.toggleTheme(value);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Logout Button at Bottom
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tileColor: Colors.red.withValues(alpha: 0.15),
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: BoldText(
                            text: "Logout",
                            size: 15,
                            color: Colors.red,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showLogoutDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: BoldText(
          text: "Logout Confirmation",
          size: 18,
          color: Colors.white,
        ),
        content: LightText(
          text: "Are you sure you want to logout from My Coffee Shop?",
          size: 14,
          color: Colors.grey,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: LightText(text: "Cancel", size: 14, color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              signOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: BoldText(text: "Logout", size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
