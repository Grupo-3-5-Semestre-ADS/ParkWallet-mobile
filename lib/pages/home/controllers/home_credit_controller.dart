import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/pages/history/controllers/history_controller.dart';
import 'package:park_wallet/pages/home/widgets/qr_code_scanner_page.dart';
import 'package:park_wallet/repositories/credit_repository.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/services/transaction_event_service.dart';

class HomeCreditController extends GetxController {
  CreditRepository creditRepository = CreditRepository();
  AuthService authService = Get.find<AuthService>();

  final TextEditingController valueController = TextEditingController();

  var balance = 0.0.obs;
  var isLoading = false.obs;
  
  static var hasRecentRecharge = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }
  Future<void> loadBalance() async {
    try {
      isLoading.value = true;
      final newBalance = await creditRepository.fetchBalance();
      balance.value = newBalance;
    } catch (e) {
      Get.snackbar("Erro", "Não foi possível carregar o saldo");
    } finally {
      isLoading.value = false;
    }
  }

  void pay() {
    Get.to(() => QRCodeScannerPage());
  }

  Future<void> rechargeWithValue(double amount) async {
    try {
      isLoading.value = true;
      final newBalance = await creditRepository.rechargeCredit(amount);
      balance.value = newBalance;
      Get.snackbar(
        "Sucesso", 
        "Recarga de R\$ ${amount.toStringAsFixed(2)} realizada com sucesso!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      hasRecentRecharge.value = true;
      print("DEBUG: hasRecentRecharge set to true after recharge");
      
      TransactionEventService.instance.notifyRechargeCompleted(
        amount: amount,
        userId: authService.userId ?? 'unknown',
      );
      
      try {
        final historyController = Get.find<HistoryController>();
        print("DEBUG: Calling immediate refreshData() on HistoryController");
        historyController.refreshData();
      } catch (e) {
        print("DEBUG: HistoryController not found for immediate refresh: $e");
      }
      
      await Future.delayed(const Duration(milliseconds: 2000));
      
      try {
        final historyController = Get.find<HistoryController>();
        print("DEBUG: Calling delayed refreshData() on HistoryController");
        historyController.refreshData();
      } catch (e) {
        print("DEBUG: HistoryController not found for delayed refresh: $e");
      }
    } catch (e) {
      String message = e is CustomException ? e.message : "Falha ao processar recarga";
      Get.snackbar(
        "Erro", 
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void handleRecharge(BuildContext context) {
    final rawText = valueController.text.trim();
    final normalized = rawText.replaceAll('.', '').replaceAll(',', '.');

    final value = double.tryParse(normalized);
    valueController.text = "";

    if (value != null && value > 0) {
      Navigator.of(context).pop();
      rechargeWithValue(value);
    } else {
      Get.snackbar("oops".tr, "valid_amount_warning".tr);
    }
  }
}
