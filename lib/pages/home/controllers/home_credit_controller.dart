import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/home/widgets/qr_code_scanner_page.dart';
import 'package:park_wallet/repositories/credit_repository.dart';

class HomeCreditController extends GetxController {
  CreditRepository creditRepository = CreditRepository();

  final TextEditingController valueController = TextEditingController();

  var balance = 0.0.obs;

  // override
  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }
  //
  Future<void> loadBalance() async {
    try {
      final newBalance = await creditRepository.fetchBalance();
      balance.value = newBalance;
    } catch (e) {
      Get.snackbar("Erro", "Não foi possível carregar o saldo");
    }
  }

  // Simula um pagamento (deduz saldo)
  void pay() {
    Get.to(() => QRCodeScannerPage());
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
