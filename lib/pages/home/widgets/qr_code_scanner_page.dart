import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/repositories/payment_repository.dart';

class QRCodeScannerPage extends StatelessWidget {
  QRCodeScannerPage({super.key});
  final PaymentRepository paymentRepository = PaymentRepository();

  final RxBool isProcessing = false.obs;

  void _handleScan(BarcodeCapture capture) async {
    if (isProcessing.value) return; // Ignora múltiplas leituras
    isProcessing.value = true;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    try {
      final json = jsonDecode(code);
      final List productsJson = json['products'];

      final products = productsJson.map((item) => ProductPaymentRequest(
        productId: int.parse(item['productId'].toString()),
        quantity: int.parse(item['quantity'].toString()),
      )).toList();

      Get.back(); // Fecha o scanner

      await Future.delayed(const Duration(milliseconds: 300));
      await _showConfirmationDialog(products);
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar("Erro", "Erro ao ler dados: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _showConfirmationDialog(List<ProductPaymentRequest> products) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: products.map((p) => Text('Produto ${p.productId} - Qtd: ${p.quantity}')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              isProcessing.value = false;
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Fecha o modal
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              try {
                final message = await paymentRepository.fetchPayment(products);

                Get.back(); // Fecha o loading
                Get.snackbar("Sucesso", message, snackPosition: SnackPosition.BOTTOM);

                // Atualiza o saldo
                final creditCtrl = Get.find<HomeCreditController>();
                await creditCtrl.loadBalance();

              } catch (e) {
                Get.back(); // Fecha o loading
                Get.snackbar("Erro", e.toString(), snackPosition: SnackPosition.BOTTOM);
              } finally {
                isProcessing.value = false; // Libera novo scan
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR Code')),
      body: MobileScanner(
        onDetect: (capture) => _handleScan(capture),
      ),
    );
  }
}
