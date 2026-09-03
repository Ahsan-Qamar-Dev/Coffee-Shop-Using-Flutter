import 'package:flutter/material.dart';
import 'package:my_coffee_shop/models/coffee_model.dart';
import 'package:my_coffee_shop/models/dummy_data.dart';
import 'package:my_coffee_shop/views/cart_screen.dart';
import 'package:my_coffee_shop/views/favorite_screen.dart';
import 'package:my_coffee_shop/views/notification_screen.dart';
import 'package:my_coffee_shop/views/profile_screen.dart';
import 'package:my_coffee_shop/widgets/bold_text.dart';
import 'package:my_coffee_shop/widgets/coffee_tile.dart';
import 'package:my_coffee_shop/widgets/custom_drawer.dart';
import 'package:my_coffee_shop/widgets/special_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = const [
    "All",
    "Cappuccino",
    "Latte",
    "Espresso",
    "Americano",
    "Mocha",
  ];

  List<Coffee> get filteredCoffees {
    final query = _searchQuery.trim().toLowerCase();
    return sampleCoffees.where((coffee) {
      final matchesCategory = _selectedCategoryIndex == 0 ||
          coffee.name.toLowerCase() == categories[_selectedCategoryIndex].toLowerCase();
      final matchesSearch = query.isEmpty ||
          coffee.name.toLowerCase().contains(query) ||
          coffee.subtitle.toLowerCase().contains(query) ||
          coffee.description.toLowerCase().contains(query);

      if (query.isNotEmpty) {
        return matchesSearch;
      }
      return matchesCategory;
    }).toList();
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return const FavoriteScreen();
      case 2:
        return const CartScreen();
      case 3:
        return const NotificationScreen();
      default:
        return _buildHomeBody();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: CustomDrawer(
        onSelectTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorite"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notification"),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Open Navigation Drawer Button
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.apps, color: Colors.orange),
                        ),
                      ),
                    ),

                    // Navigate to Profile Screen Button
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/Ahsan.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BoldText(
                  text: "Find the best\nCoffee for you",
                  size: 35,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              // Interactive Search Bar
              Container(
                width: double.maxFinite,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: TextStyle(
                            color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color ??
                                Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: "Find your coffee...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = "";
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Row
              const SizedBox(height: 30),
              SizedBox(
                height: 35,
                width: double.maxFinite,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.orange, width: 1)
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BoldText(
                                text: categories[index],
                                size: 15,
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),

              // Filtered Coffee Tile List
              Tile(coffees: filteredCoffees),

              const SizedBox(height: 30),

              BoldText(
                text: "Special for you, Ahsan!",
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
              ),

              const SizedBox(height: 12),

              Tile2(specials: sampleCoffees.take(2).toList()),
            ],
          ),
        ),
      ),
    );
  }
}