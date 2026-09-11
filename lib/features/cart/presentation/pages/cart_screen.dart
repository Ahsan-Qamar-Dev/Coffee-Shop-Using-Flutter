import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/checkout/presentation/pages/payment_screen.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/profile_screen.dart';
import 'package:my_coffee_shop/core/widgets/bold_text.dart';
import 'package:my_coffee_shop/core/widgets/light_text.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (_) {
        final cart = Get.find<CartController>();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF1E222A) : Colors.white;
        final innerColor = isDark
            ? const Color(0xFF14181F)
            : Colors.grey.shade100;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  // Top Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.apps, color: Colors.orange),
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      BoldText(text: "Cart", size: 20, color: textColor),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/Ahsan.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dynamic Cart Items List or Empty View
                  Expanded(
                    child: cart.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                BoldText(
                                  text: "Your Cart is Empty",
                                  size: 20,
                                  color: textColor,
                                ),
                                const SizedBox(height: 8),
                                LightText(
                                  text: "Explore our delicious coffees and add items!",
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        item.coffee.imagePath,
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BoldText(
                                            text: item.coffee.name,
                                            size: 16,
                                            color: textColor,
                                          ),
                                          const SizedBox(height: 4),
                                          LightText(
                                            text: item.coffee.subtitle,
                                            size: 11,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: innerColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: BoldText(
                                                  text: item.size,
                                                  size: 12,
                                                  color: textColor,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  BoldText(
                                                    text: "\$",
                                                    size: 14,
                                                    color: Colors.orange,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  BoldText(
                                                    text: item.totalPrice
                                                        .toStringAsFixed(2),
                                                    size: 14,
                                                    color: textColor,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.find<CartController>()
                                                      .decrementQuantity(item);
                                                },
                                                child: Container(
                                                  height: 28,
                                                  width: 28,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFD97736,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 45,
                                                height: 28,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: innerColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.orange,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: BoldText(
                                                    text: "${item.quantity}",
                                                    size: 14,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.find<CartController>()
                                                      .incrementQuantity(item);
                                                },
                                                child: Container(
                                                  height: 28,
                                                  width: 28,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFD97736,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
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
                            },
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
                            LightText(
                              text: "Total Price",
                              size: 12,
                              color: Colors.grey,
                            ),
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
                                  text: cart.totalPrice.toStringAsFixed(2),
                                  size: 20,
                                  color: textColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: cart.items.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentScreen(
                                        totalAmount: cart.totalPrice,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97736),
                            disabledBackgroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: BoldText(
                            text: "Pay",
                            size: 16,
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
      },
    );
  }
}
