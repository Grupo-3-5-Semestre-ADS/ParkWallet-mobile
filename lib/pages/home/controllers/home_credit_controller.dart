import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeCreditController extends GetxController {
  // Saldo inicial fictício
  final TextEditingController valueController = TextEditingController();

  var balance = 123.43.obs;

  // Simula um pagamento (deduz saldo)
  void pay() {
    if (balance.value >= 10) {
      balance.value -= 10;
    }
  }

  // Simula uma recarga (adiciona saldo)
  void rechargeWithValue(double amount) {
    if (amount > 0) {
      balance.value += amount;
    }
  }
  void handleRecharge(BuildContext context) {
    final rawText = valueController.text.trim();
    final normalized = rawText.replaceAll('.', '').replaceAll(',', '.');

    final value = double.tryParse(normalized);
    valueController.text = "";

    if (value != null && value > 0) {
      rechargeWithValue(value);
      Navigator.of(context).pop(); // Fecha o diálogo apenas
    } else {
      Get.snackbar("oops".tr, "valid_amount_warning".tr);
    }
  }

}
