import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopNavigation extends GetxController {
  int index = 0;
  void select(int value) {
    if (value < 0 || value > 3) return;
    index = value;
    update();
  }
}

void openShopTab(BuildContext context, int index) {
  Get.find<ShopNavigation>().select(index);
  Navigator.of(context).popUntil((route) => route.isFirst);
}
