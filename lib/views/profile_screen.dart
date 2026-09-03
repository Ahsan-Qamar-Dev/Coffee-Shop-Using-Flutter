import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_coffee_shop/providers/theme_provider.dart';
import 'package:my_coffee_shop/views/login_page.dart';
import 'package:my_coffee_shop/widgets/bold_text.dart';
import 'package:my_coffee_shop/widgets/light_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1E222A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: BoldText(text: "Profile & Settings", size: 20, color: textColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Avatar Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/Ahsan.png"),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    BoldText(text: "Ahsan Qamar", size: 20, color: textColor),
                    const SizedBox(height: 4),
                    LightText(
                      text: "ahsan.qamar@coffeeshop.com",
                      size: 13,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Settings Sections
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                      child: BoldText(
                          text: "Account Settings",
                          size: 14,
                          color: Colors.orange),
                    ),
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: "Personal Details",
                      subtitle: "Ahsan Qamar • +92306xxxxxxx",
                      textColor: textColor,
                    ),
                    _buildSettingItem(
                      icon: Icons.location_on_outlined,
                      title: "Delivery Address",
                      subtitle: "Paragon City, Lahore, Pakistan",
                      textColor: textColor,
                    ),
                    _buildSettingItem(
                      icon: Icons.credit_card_outlined,
                      title: "Payment Methods",
                      subtitle: "VISA ending in 8923",
                      textColor: textColor,
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                      child: BoldText(
                          text: "App Preferences",
                          size: 14,
                          color: Colors.orange),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.orange,
                      ),
                      title: BoldText(
                        text: isDark ? "Dark Theme" : "Light Theme",
                        size: 15,
                        color: textColor,
                      ),
                      value: isDark,
                      activeTrackColor: Colors.orange,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined,
                          color: Colors.orange),
                      title: BoldText(
                        text: "Push Notifications",
                        size: 15,
                        color: textColor,
                      ),
                      value: notificationsEnabled,
                      activeTrackColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: "Security & Password",
                      subtitle: "Change account password",
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Logout Button
              SizedBox(
                width: double.maxFinite,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: BoldText(text: "Logout", size: 16, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: BoldText(text: title, size: 15, color: textColor),
      subtitle: LightText(text: subtitle, size: 12, color: Colors.grey),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: BoldText(text: "Logout Confirmation", size: 18, color: Colors.white),
        content: LightText(
          text: "Are you sure you want to logout?",
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
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: BoldText(text: "Logout", size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
