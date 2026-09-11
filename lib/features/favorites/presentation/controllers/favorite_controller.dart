import 'package:get/get.dart';
import 'package:my_coffee_shop/features/catalog/domain/coffee.dart';

class FavoriteController extends GetxController {
  final List<Coffee> _favoriteCoffees = [];

  List<Coffee> get favorites => List.unmodifiable(_favoriteCoffees);

  void clear() {
    _favoriteCoffees.clear();
    update();
  }

  /// Checks if a coffee is in the favorites list
  bool isFavorite(Coffee coffee) {
    return _favoriteCoffees.any((item) => item.id == coffee.id);
  }

  /// Toggles favorite status for a coffee
  void toggleFavorite(Coffee coffee) {
    final exists = _favoriteCoffees.any((item) => item.id == coffee.id);
    if (exists) {
      _favoriteCoffees.removeWhere((item) => item.id == coffee.id);
    } else {
      _favoriteCoffees.add(coffee);
    }
    update();
  }
}
