import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/shop_navigation.dart';
import '../../../../app/widgets/custom_drawer.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../../core/widgets/shop_motion.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../favorites/presentation/pages/favorite_screen.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../notifications/presentation/pages/notification_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../data/sample_catalog.dart';
import '../widgets/coffee_tile.dart';
import '../widgets/special_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();
  String _category = 'All';
  static const _titles = [
    'Coffee Shop',
    'Favorites',
    'Your cart',
    'Notifications',
  ];
  static const _categories = [
    'All',
    'Iced',
    'Cappuccino',
    'Latte',
    'Espresso',
    'Americano',
    'Mocha',
    'Cold Brew',
  ];
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<ShopNavigation>(
    builder: (navigation) => PopScope(
      canPop: navigation.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) navigation.select(0);
      },
      child: Scaffold(
        key: _scaffold,
        drawer: CustomDrawer(onSelectTab: navigation.select),
        appBar: AppBar(
          leading: IconButton(
            key: const ValueKey('open-menu'),
            tooltip: 'Open menu',
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () => _scaffold.currentState!.openDrawer(),
          ),
          title: Text(_titles[navigation.index]),
          actions: [
            IconButton(
              tooltip: 'Profile & settings',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              ),
              icon: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: MotionTabStack(
            index: navigation.index,
            children: [
              _catalog(),
              const FavoriteScreen(embedded: true),
              const CartScreen(embedded: true),
              const NotificationScreen(embedded: true),
            ],
          ),
        ),
        bottomNavigationBar: GetBuilder<CartController>(
          builder: (cart) => GetBuilder<NotificationController>(
            builder: (notifications) => NavigationBar(
              selectedIndex: navigation.index,
              onDestinationSelected: (index) {
                FocusManager.instance.primaryFocus?.unfocus();
                navigation.select(index);
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cart.itemCount > 0,
                    label: Text('${cart.itemCount}'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  label: 'Cart',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: notifications.unreadCount > 0,
                    label: Text('${notifications.unreadCount}'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  label: 'Alerts',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _catalog() {
    final query = _search.text.trim().toLowerCase();
    final coffees = sampleCoffees
        .where(
          (coffee) =>
              (_category == 'All' ||
                  (_category == 'Iced'
                      ? coffee.isIced
                      : coffee.category == _category)) &&
              (query.isEmpty ||
                  '${coffee.name} ${coffee.subtitle} ${coffee.description}'
                      .toLowerCase()
                      .contains(query)),
        )
        .toList();
    final filtered = query.isNotEmpty || _category != 'All';
    return PageBody(
      child: ListView(
        key: const PageStorageKey('catalog-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          GetBuilder<AuthController>(
            builder: (auth) => Text(
              'Good coffee, ${auth.user?.name.split(' ').first ?? 'good company'}.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find your daily\ncoffee moment.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            key: const ValueKey('coffee-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Find your coffee...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_search.clear),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in _categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: category == _category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
              ],
            ),
          ),
          SectionTitle(
            filtered ? 'Your selection' : 'Made for your mood',
            subtitle: filtered
                ? '${coffees.length} ${coffees.length == 1 ? 'coffee' : 'coffees'} found'
                : '${sampleCoffees.length} coffees, from warm classics to iced favorites.',
          ),
          if (coffees.isEmpty)
            EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No coffee found',
              message: 'Try another search or explore all our coffees.',
              action: 'Clear filters',
              onAction: () => setState(() {
                _search.clear();
                _category = 'All';
              }),
            )
          else
            Tile(coffees: coffees),
          if (!filtered) ...[
            const SectionTitle(
              'A little extra comfort',
              subtitle: 'Slow down with our house favorites.',
            ),
            Tile2(specials: [sampleCoffees[4], sampleCoffees[1]]),
          ],
        ],
      ),
    );
  }
}
