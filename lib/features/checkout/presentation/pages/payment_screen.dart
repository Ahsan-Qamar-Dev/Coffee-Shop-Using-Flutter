import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/core/widgets/bold_text.dart';
import 'package:my_coffee_shop/core/widgets/light_text.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, this.totalAmount = 0.0});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentIndex = 0;

  final List<String> _paymentTitles = [
    "Pay from Credit Card",
    "Pay from Wallet",
    "Pay from Google Pay",
    "Pay from Apple Pay",
    "Pay from Amazon Pay",
  ];

  @override
  Widget build(BuildContext context) {
    final formattedPrice = widget.totalAmount.toStringAsFixed(2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E222A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor,
                        size: 18,
                      ),
                    ),
                  ),
                  BoldText(text: "Payment", size: 20, color: textColor),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    // Credit Card Display Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.orange, width: 2),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF262B36),
                                  const Color(0xFF14181F),
                                ]
                              : [
                                  Colors.orange.shade800,
                                  Colors.deepOrange.shade600,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.contactless,
                                color: Colors.white,
                                size: 30,
                              ),
                              BoldText(
                                text: "VISA",
                                size: 22,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          BoldText(
                            text: "3897  ••••  ••••  8923",
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LightText(
                                    text: "Card Holder Name",
                                    size: 10,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 4),
                                  BoldText(
                                    text: "Ahsan Raza",
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LightText(
                                    text: "Expires",
                                    size: 10,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 4),
                                  BoldText(
                                    text: "02/30",
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Payment Options List
                    _buildPaymentOption(
                      index: 0,
                      icon: Icons.credit_card,
                      iconColor: Colors.orange,
                      title: "Credit Card",
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      index: 1,
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.orange,
                      title: "Coffee Wallet",
                      trailingText: "\$ 100.50",
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      index: 2,
                      icon: Icons.g_mobiledata,
                      iconColor: isDark ? Colors.white : Colors.black87,
                      title: "Google Pay",
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      index: 3,
                      icon: Icons.apple,
                      iconColor: isDark ? Colors.white : Colors.black87,
                      title: "Apple Pay",
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),

              // Bottom Total Price & Pay Button Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LightText(text: "Price", size: 12, color: Colors.grey),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            BoldText(
                              text: "\$",
                              size: 20,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            BoldText(
                              text: formattedPrice,
                              size: 20,
                              color: textColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.orange,
                                    size: 60,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                BoldText(
                                  text: "Order Placed Successfully!",
                                  size: 18,
                                  color: textColor,
                                ),
                                const SizedBox(height: 8),
                                LightText(
                                  text:
                                      "Paid \$$formattedPrice. Your order is being freshly prepared!",
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.find<CartController>().clearCart();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD97736),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: BoldText(
                                    text: "Back to Home",
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97736),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: BoldText(
                        text: _paymentTitles[_selectedPaymentIndex],
                        size: 14,
                        color: Colors.white,
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

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color cardColor,
    required Color textColor,
    String? trailingText,
  }) {
    bool isSelected = _selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 15),
            BoldText(text: title, size: 15, color: textColor),
            const Spacer(),
            if (trailingText != null)
              BoldText(text: trailingText, size: 14, color: textColor),
          ],
        ),
      ),
    );
  }
}
