// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:my_coffee_shop/BoldText.dart';
import 'package:my_coffee_shop/LightText.dart';
import 'package:my_coffee_shop/PaymentScreen.dart'; // 👈 IMPORT PAYMENT SCREEN

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Sample Cart Items State
  int qtyS = 1;
  int qtyM = 1;
  int qtyL = 1;
  int qtyCappuccinoM = 1;
  int qtyRobusta = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              // Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apps, color: Colors.grey),
                  ),
                  BoldText(text: "Cart", size: 20, color: Colors.white),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset("assets/Ahsan.png", fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cart Items List
              Expanded(
                child: ListView(
                  children: [
                    // Multi-Size Item Card (Top Card)
                    _buildMultiSizeCard(),

                    const SizedBox(height: 15),

                    // Single Size Item Card (Cappuccino M)
                    _buildSingleSizeCard(
                      title: "Cappuccino",
                      subtitle: "With Steamed Milk",
                      size: "M",
                      price: "6.20",
                      imagePath: "assets/Cappacuino.png",
                      quantity: qtyCappuccinoM,
                      onAdd: () => setState(() => qtyCappuccinoM++),
                      onRemove: () {
                        if (qtyCappuccinoM > 1) {
                          setState(() => qtyCappuccinoM--);
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // Single Size Item Card (Robusta Beans)
                    _buildSingleSizeCard(
                      title: "Robusta Beans",
                      subtitle: "From Africa",
                      size: "250gm",
                      price: "6.20",
                      imagePath: "assets/Espresso.jpg",
                      quantity: qtyRobusta,
                      onAdd: () => setState(() => qtyRobusta++),
                      onRemove: () {
                        if (qtyRobusta > 1) {
                          setState(() => qtyRobusta--);
                        }
                      },
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
                        LightText(text: "Total Price", size: 12, color: Colors.grey),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            BoldText(text: "\$", size: 20, color: Colors.orange),
                            const SizedBox(width: 4),
                            BoldText(text: "10.40", size: 20, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      // 💳 ROUTE TO PAYMENT SCREEN ON TAP
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97736),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: BoldText(text: "Pay", size: 16, color: Colors.white),
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

  // Multi-Size Item Container
  Widget _buildMultiSizeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/Cappacuino.png",
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BoldText(text: "Cappuccino", size: 16, color: Colors.white),
                    const SizedBox(height: 4),
                    LightText(text: "With Steamed Milk", size: 11, color: Colors.grey),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14181F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LightText(text: "Medium Roasted", size: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSizeRow("S", "4.20", qtyS, () => setState(() => qtyS++), () {
            if (qtyS > 1) setState(() => qtyS--);
          }),
          const SizedBox(height: 8),
          _buildSizeRow("M", "4.20", qtyM, () => setState(() => qtyM++), () {
            if (qtyM > 1) setState(() => qtyM--);
          }),
          const SizedBox(height: 8),
          _buildSizeRow("L", "4.20", qtyL, () => setState(() => qtyL++), () {
            if (qtyL > 1) setState(() => qtyL--);
          }),
        ],
      ),
    );
  }

  Widget _buildSizeRow(
      String size, String price, int qty, VoidCallback onAdd, VoidCallback onRemove) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 35,
          width: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF14181F),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: BoldText(text: size, size: 14, color: Colors.white)),
        ),
        Row(
          children: [
            BoldText(text: "\$", size: 14, color: Colors.orange),
            const SizedBox(width: 2),
            BoldText(text: price, size: 14, color: Colors.white),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onRemove,
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97736),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove, color: Colors.white, size: 16),
              ),
            ),
            Container(
              width: 45,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF14181F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Center(child: BoldText(text: "$qty", size: 14, color: Colors.white)),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97736),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Single Size Card Widget
  Widget _buildSingleSizeCard({
    required String title,
    required String subtitle,
    required String size,
    required String price,
    required String imagePath,
    required int quantity,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(imagePath, height: 90, width: 90, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoldText(text: title, size: 16, color: Colors.white),
                const SizedBox(height: 4),
                LightText(text: subtitle, size: 11, color: Colors.grey),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14181F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: BoldText(text: size, size: 12, color: Colors.white),
                    ),
                    Row(
                      children: [
                        BoldText(text: "\$", size: 14, color: Colors.orange),
                        const SizedBox(width: 2),
                        BoldText(text: price, size: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97736),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.remove, color: Colors.white, size: 16),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14181F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Center(
                        child: BoldText(text: "$quantity", size: 14, color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97736),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}