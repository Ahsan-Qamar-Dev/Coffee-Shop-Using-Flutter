import 'package:flutter/material.dart';
import 'package:my_coffee_shop/views/home_page.dart';
import 'package:my_coffee_shop/widgets/bold_text.dart';
import 'package:my_coffee_shop/widgets/light_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E222A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Logo Container
                Center(
                  child: Container(
                    height: 140,
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/Coffee_Cup.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Welcome Header
                Center(
                  child: Column(
                    children: [
                      BoldText(
                        text: "Welcome Back!",
                        size: 28,
                        color: textColor,
                      ),
                      const SizedBox(height: 8),
                      LightText(
                        text: "Login to order your favorite coffee",
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input Field
                BoldText(text: "Email Address", size: 14, color: textColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.orange),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input Field
                BoldText(text: "Password", size: 14, color: textColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.orange),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: LightText(
                    text: "Forgot Password?",
                    size: 12,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 35),

                // Sign In Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 55,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97736),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: BoldText(
                        text: "Sign In",
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Footer Register Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LightText(
                      text: "Don't have an account? ",
                      size: 13,
                      color: Colors.grey,
                    ),
                    BoldText(
                      text: "Register",
                      size: 13,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}