import 'package:my_coffee_shop/features/catalog/domain/coffee.dart';

final List<Coffee> sampleCoffees = [
  const Coffee(
    id: 'c1',
    name: 'Cappuccino',
    subtitle: 'With Steamed Milk',
    description: 'A cappuccino is an Italian coffee drink that is traditionally prepared with equal parts double espresso, steamed milk, and steamed milk foam on top.',
    price: 4.20,
    rating: 4.5,
    imagePath: 'assets/Cappacuino.png',
  ),
  const Coffee(
    id: 'c2',
    name: 'Latte',
    subtitle: 'With Creamy Foam',
    description: 'A latte is a classic espresso-based drink made with one or two shots of espresso, plenty of steamed milk, and a thin layer of light microfoam on top.',
    price: 3.80,
    rating: 4.2,
    imagePath: 'assets/latte-coffee-cup.jpg',
  ),
  const Coffee(
    id: 'c3',
    name: 'Espresso',
    subtitle: 'Pure Double Shot',
    description: 'Espresso is a concentrated form of coffee served in small, strong shots. It is brewed by forcing hot water under high pressure through finely-ground coffee beans.',
    price: 2.50,
    rating: 4.8,
    imagePath: 'assets/Espresso.jpg',
  ),
  const Coffee(
    id: 'c4',
    name: 'Americano',
    subtitle: 'Hot Water & Espresso',
    description: 'A Caffe Americano is prepared by diluting an espresso shot with hot water, giving it a similar strength to, but different flavor from, traditionally brewed coffee.',
    price: 3.00,
    rating: 4.0,
    imagePath: 'assets/Americano.jfif',
  ),
  const Coffee(
    id: 'c5',
    name: 'Mocha',
    subtitle: 'With Dark Chocolate',
    description: 'A caffe mocha is a chocolate-flavored variant of a latte. Made with espresso, hot milk, and sweet dark chocolate syrup topped with velvety milk foam.',
    price: 4.50,
    rating: 4.7,
    imagePath: 'assets/Mocha.jfif',
  ),
];
