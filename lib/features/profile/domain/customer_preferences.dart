enum PaymentChoice { cash, demoCard }

extension PaymentChoiceLabel on PaymentChoice {
  String get label =>
      this == PaymentChoice.cash ? 'Pay on collection / delivery' : 'Demo card';
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.label,
    required this.street,
    required this.city,
    required this.phone,
  });
  final String label, street, city, phone;
  String get summary => '$street, $city';
}
