import 'package:flutter/material.dart';

import '../../../../core/widgets/shop_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help & about')),
    body: SafeArea(
      child: PageBody(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const SectionTitle(
              'A better coffee break',
              subtitle: 'A few things to know before you order.',
            ),
            ShopCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in const [
                    (
                      'How do I order?',
                      'Choose a coffee, select its size and add it to your cart. Checkout lets you review your order, choose pickup or delivery, and select a payment preference.',
                    ),
                    (
                      'Is this a real order?',
                      'This is a UI preview. Orders and payments are simulated; no coffee is dispatched and no money is charged. Your preview orders are available in My orders during this session.',
                    ),
                    (
                      'Can I change or cancel an order?',
                      'Before checkout, change quantities or remove items in your cart. After placing a preview order, open My orders to view its receipt, cancel it or add the same coffees to your cart again.',
                    ),
                    (
                      'What about allergies?',
                      'Milk ingredients are shown on the coffee detail page. This preview cannot verify allergens, cross-contact or substitutions. Confirm dietary requirements with the shop before placing a real order.',
                    ),
                    (
                      'Where is my data saved?',
                      'The preview keeps account details, addresses, favorites and orders in memory. Restarting the app clears them. Signing out clears your shopping session. Use test details.',
                    ),
                    (
                      'How do notifications work?',
                      'Preview order confirmations appear in Alerts. You can mark them read or clear them. Turn order alerts on or off in Profile & settings. Push delivery will be connected with the backend.',
                    ),
                  ])
                    ExpansionTile(
                      title: Text(item.$1),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      children: [
                        Text(item.$2, style: const TextStyle(height: 1.6)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ShopCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_cafe_outlined, size: 32),
                  SizedBox(height: 14),
                  Text(
                    'Coffee Shop',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your daily coffee moment.\nVersion 1.0 · UI preview',
                    style: TextStyle(height: 1.6),
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
