class Coffee {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final double price;
  final double rating;
  final String imagePath;

  const Coffee({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.rating,
    required this.imagePath,
  });

  int priceCentsFor(String size) {
    if (!const ['S', 'M', 'L'].contains(size)) {
      throw ArgumentError.value(size, 'size', 'Choose S, M or L');
    }
    return (price * 100).round() +
        (size == 'M'
            ? 50
            : size == 'L'
            ? 100
            : 0);
  }

  bool get containsMilk =>
      const ['Cappuccino', 'Latte', 'Mocha'].contains(name);
}
