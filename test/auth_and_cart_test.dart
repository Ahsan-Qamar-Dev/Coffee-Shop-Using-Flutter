import 'package:flutter_test/flutter_test.dart';
import 'package:my_coffee_shop/features/auth/data/demo_auth_repository.dart';
import 'package:my_coffee_shop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_coffee_shop/features/auth/domain/auth_validators.dart';
import 'package:my_coffee_shop/features/cart/presentation/controllers/cart_controller.dart';
import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';

void main() {
  test(
    'preview registration, sign out, sign in and duplicate handling',
    () async {
      final auth = AuthController(DemoAuthRepository());
      expect(
        await auth.signUp('Alex', ' ALEX@example.com ', 'preview123'),
        isTrue,
      );
      expect(auth.user?.email, 'alex@example.com');
      expect(await auth.signOut(), isTrue);
      expect(auth.user, isNull);
      expect(await auth.signIn('alex@example.com', 'badpassword'), isFalse);
      expect(await auth.signIn('alex@example.com', 'preview123'), isTrue);
      expect(
        await auth.signUp('Alex', 'alex@example.com', 'preview123'),
        isFalse,
      );
      expect(auth.error, isNotNull);
      expect(auth.busy, isFalse);
    },
  );
  test('repeated submission is ignored while request is pending', () async {
    final auth = AuthController(DemoAuthRepository());
    final first = auth.signIn('demo@coffee.test', 'Coffee123!');
    expect(await auth.signIn('demo@coffee.test', 'Coffee123!'), isFalse);
    expect(await first, isTrue);
  });
  test('email and password rules', () {
    expect(AuthValidators.email('person@example.com'), isNull);
    expect(AuthValidators.email('person@'), isNotNull);
    expect(AuthValidators.password('short'), isNotNull);
  });
  test('cart keeps sizes separate and removes last quantity', () {
    final cart = CartController();
    final coffee = sampleCoffees.first;
    cart.addItem(coffee, 'S');
    cart.addItem(coffee, 'S');
    cart.addItem(coffee, 'L');
    expect(cart.items.length, 2);
    expect(cart.itemCount, 3);
    expect(cart.totalPrice, closeTo(13.6, .001));
    cart.decrementQuantity(cart.items.first);
    cart.decrementQuantity(cart.items.first);
    expect(cart.items.length, 1);
    expect(cart.items.first.size, 'L');
    cart.clearCart();
    expect(cart.totalPrice, 0);
  });
}
