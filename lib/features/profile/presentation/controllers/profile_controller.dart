import 'package:get/get.dart';

import '../../domain/customer_preferences.dart';

class ProfileController extends GetxController {
  String phone = '';
  DeliveryAddress? address;
  PaymentChoice payment = PaymentChoice.cash;
  bool orderAlerts = true;

  void savePhone(String value) {
    phone = value.trim();
    update();
  }

  void saveAddress(DeliveryAddress? value) {
    address = value;
    update();
  }

  void setPayment(PaymentChoice value) {
    payment = value;
    update();
  }

  void setAlerts(bool value) {
    orderAlerts = value;
    update();
  }

  void clear() {
    phone = '';
    address = null;
    payment = PaymentChoice.cash;
    orderAlerts = true;
    update();
  }
}
