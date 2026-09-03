import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_coffee_shop/models/coffee_model.dart';
import 'package:my_coffee_shop/providers/cart_provider.dart';
import 'package:my_coffee_shop/providers/favorite_provider.dart';
import 'package:my_coffee_shop/widgets/bold_text.dart';
import 'package:my_coffee_shop/widgets/light_text.dart';

class DetailsPage extends StatefulWidget {
  final Coffee coffee;

  const DetailsPage({
    super.key,
    required this.coffee,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int selectedSizeIndex = 0;

  final List<String> sizes = const ["S", "M", "L"];

  String get dynamicPrice {
    double basePrice = widget.coffee.price;
    if (selectedSizeIndex == 1) {
      basePrice += 0.50;
    } else if (selectedSizeIndex == 2) {
      basePrice += 1.00;
    }
    return basePrice.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final chipColor = isDark ? const Color(0xFF252525) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image & Overlay Stack
            Stack(
              children: [
                Container(
                  height: 420,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    image: DecorationImage(
                      image: AssetImage(widget.coffee.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        Consumer<FavoriteProvider>(
                          builder: (context, favProvider, child) {
                            final isFav = favProvider.isFavorite(widget.coffee);
                            return GestureDetector(
                              onTap: () {
                                favProvider.toggleFavorite(widget.coffee);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: isFav
                                        ? Colors.grey.shade800
                                        : Colors.red.shade800,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      isFav
                                          ? 'Removed ${widget.coffee.name} from Favorites'
                                          : 'Added ${widget.coffee.name} to Favorites ❤️',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BoldText(
                                text: widget.coffee.name,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              LightText(
                                text: widget.coffee.subtitle,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  BoldText(
                                    text: widget.coffee.rating.toString(),
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  LightText(
                                    text: "(6,879)",
                                    size: 10,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            _buildIconTag(Icons.local_cafe, "Coffee"),
                            const SizedBox(width: 8),
                            _buildIconTag(Icons.water_drop, "Milk"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Description & Sizes Body
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoldText(
                    text: "Description",
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.coffee.description,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  BoldText(
                    text: "Size",
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      sizes.length,
                      (index) => _buildSizeChip(
                        sizes[index],
                        index: index,
                        isSelected: selectedSizeIndex == index,
                        chipColor: chipColor,
                        textColor: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: cardColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LightText(text: "Price", size: 12, color: Colors.grey),
                Row(
                  children: [
                    BoldText(text: "\$", size: 20, color: Colors.orange),
                    const SizedBox(width: 2),
                    BoldText(
                      text: dynamicPrice,
                      size: 20,
                      color: textColor,
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final selectedSize = sizes[selectedSizeIndex];
                context.read<CartProvider>().addItem(widget.coffee, selectedSize);

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFD97736),
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Added ${widget.coffee.name} ($selectedSize) to Cart!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: BoldText(
                text: "Add to Cart",
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange, size: 18),
          const SizedBox(height: 4),
          LightText(text: text, size: 10, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSizeChip(
    String size, {
    required int index,
    required bool isSelected,
    required Color chipColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSizeIndex = index;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withValues(alpha: 0.2) : chipColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: BoldText(
            text: size,
            size: 14,
            color: isSelected ? Colors.orange : textColor,
          ),
        ),
      ),
    );
  }
}