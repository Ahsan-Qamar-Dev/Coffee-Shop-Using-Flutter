import 'package:get/get.dart';

import '../../domain/customer_preferences.dart';

class ProfileController extends GetxController {
  void Function()? onChanged;
  String phone = '';
  DeliveryAddress? address;
  PaymentChoice payment = PaymentChoice.cash;
  bool orderAlerts = true;

  void savePhone(String value) {
    phone = value.trim();
    update();
    onChanged?.call();
  }

  void saveAddress(DeliveryAddress? value) {
    address = value;
    update();
    onChanged?.call();
  }

  void setPayment(PaymentChoice value) {
    payment = value;
    update();
    onChanged?.call();
  }

  void setAlerts(bool value) {
    orderAlerts = value;
    update();
    onChanged?.call();
  }

  void clear() {
    phone = '';
    address = null;
    payment = PaymentChoice.cash;
    orderAlerts = true;
    update();
    onChanged?.call();
  }
}
