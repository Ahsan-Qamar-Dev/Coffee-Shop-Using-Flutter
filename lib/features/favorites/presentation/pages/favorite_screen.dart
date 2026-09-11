import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_coffee_shop/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:my_coffee_shop/features/catalog/presentation/pages/detail_page.dart';
import 'package:my_coffee_shop/features/profile/presentation/pages/profile_screen.dart';
import 'package:my_coffee_shop/core/widgets/bold_text.dart';
import 'package:my_coffee_shop/core/widgets/light_text.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoriteController>(
      builder: (_) {
        final favProvider = Get.find<FavoriteController>();
        final favorites = favProvider.favorites;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      BoldText(
                        text: "Favorites",
                        size: 20,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.white,
                      ),
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
                            color: Colors.white.withValues(alpha: 0.1),
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

                  // Dynamic Favorites List or Empty State
                  Expanded(
                    child: favorites.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 80,
                                  color: Colors.grey.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                BoldText(
                                  text: "No Favorites Yet",
                                  size: 20,
                                  color:
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color ??
                                      Colors.white,
                                ),
                                const SizedBox(height: 8),
                                LightText(
                                  text: "Tap the heart icon on any coffee to save it here!",
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final coffee = favorites[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(coffee: coffee),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          coffee.imagePath,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            BoldText(
                                              text: coffee.name,
                                              size: 16,
                                              color:
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color ??
                                                  Colors.white,
                                            ),
                                            const SizedBox(height: 4),
                                            LightText(
                                              text: coffee.subtitle,
                                              size: 12,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                BoldText(
                                                  text: "\$",
                                                  size: 14,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 2),
                                                BoldText(
                                                  text: coffee.price
                                                      .toStringAsFixed(2),
                                                  size: 14,
                                                  color:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color ??
                                                      Colors.white,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          favProvider.toggleFavorite(coffee);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
