// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';
import 'package:my_coffee_shop/LightText.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentIndex = 0; // 0: Credit Card, 1: Wallet, 2: Google Pay, 3: Apple Pay, 4: Amazon Pay

  final List<String> _paymentTitles = [
    "Pay from Credit Card",
    "Pay from Wallet",
    "Pay from Google Pay",
    "Pay from Apple Pay",
    "Pay from Amazon Pay",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF212429),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.grey, size: 16),
            ),
          ),
        ),
        title: BoldText(text: "Payment", size: 20, color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Credit Card Option
                    GestureDetector(
                      onTap: () => setState(() => _selectedPaymentIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E222A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedPaymentIndex == 0 ? Colors.orange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BoldText(text: "Credit Card", size: 14, color: Colors.white),
                            const SizedBox(height: 12),
                            
                            // Virtual Credit Card Widget
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF262B33), Color(0xFF111315)],
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
                                      const Icon(Icons.credit_card, color: Colors.orange, size: 30),
                                      BoldText(text: "VISA", size: 22, color: Colors.white),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("3 8 9 7", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                      Text("8 9 2 3", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                      Text("6 7 4 5", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                      Text("4 6 3 8", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          LightText(text: "Card Holder Name", size: 10, color: Colors.grey),
                                          const SizedBox(height: 2),
                                          BoldText(text: "Ahsan Qamar", size: 14, color: Colors.white),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          LightText(text: "Expiry Date", size: 10, color: Colors.grey),
                                          const SizedBox(height: 2),
                                          BoldText(text: "02/27", size: 14, color: Colors.white),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Wallet Option
                    _buildPaymentOption(
                      index: 1,
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.orange,
                      title: "Wallet",
                      trailingText: "\$ 100.50",
                    ),
                    const SizedBox(height: 15),

                    // Google Pay Option
                    _buildPaymentOption(
                      index: 2,
                      icon: Icons.g_mobiledata,
                      iconColor: Colors.blue,
                      title: "Google Pay",
                    ),
                    const SizedBox(height: 15),

                    // Apple Pay Option
                    _buildPaymentOption(
                      index: 3,
                      icon: Icons.apple,
                      iconColor: Colors.white,
                      title: "Apple Pay",
                    ),
                    const SizedBox(height: 15),

                    // Amazon Pay Option
                    _buildPaymentOption(
                      index: 4,
                      icon: Icons.shopping_bag,
                      iconColor: Colors.orangeAccent,
                      title: "Amazon Pay",
                    ),
                  ],
                ),
              ),

              // Bottom Pay Bar
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
                            BoldText(text: "\$", size: 20, color: Colors.orange),
                            const SizedBox(width: 4),
                            BoldText(text: "5.00", size: 20, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97736),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
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
    String? trailingText,
  }) {
    bool isSelected = _selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222A),
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
            BoldText(text: title, size: 15, color: Colors.white),
            const Spacer(),
            if (trailingText != null)
              BoldText(text: trailingText, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}