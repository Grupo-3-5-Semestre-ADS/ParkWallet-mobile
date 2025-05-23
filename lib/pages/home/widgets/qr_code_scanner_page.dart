import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/repositories/payment_repository.dart';
import 'package:park_wallet/repositories/product_repository.dart';
// Import your AppButton
import 'package:park_wallet/pages/widgets/app_button.dart'; // Ensure this path is correct

class QRCodeScannerPage extends StatelessWidget {
  QRCodeScannerPage({super.key});

  final PaymentRepository paymentRepository = PaymentRepository();
  final RxBool isProcessing = false.obs;
  final MobileScannerController scannerController = MobileScannerController();

  void _handleScan(BarcodeCapture capture) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    scannerController.stop();

    bool hasError = false;
    String? errorMessage;

    try {
      final code = capture.barcodes.first.rawValue;
      if (code == null) throw 'QR code inválido.';

      final dynamic json = jsonDecode(code);

      if (json is! Map || json['products'] is! List) {
        throw 'QR Code inválido: campo "products" ausente ou malformado.';
      }

      final List productsJson = json['products'];
      final List<ProductPaymentRequest> products = [];
      final List<Map<String, dynamic>> detailedProducts = [];

      final productRepo = ProductRepository();

      for (var item in productsJson) {
        if (item['productId'] == null || item['quantity'] == null) {
          throw 'Produto inválido no QR Code.';
        }

        final productId = int.parse(item['productId'].toString());
        final quantity = int.parse(item['quantity'].toString());
        try {
          final product = await productRepo.fetchProductById(productId);
          log('Produto carregado: ${product.name}');

          products.add(ProductPaymentRequest(productId: productId, quantity: quantity));
          detailedProducts.add({
            'name': product.name,
            'price': product.price,
            'quantity': quantity,
            'total': product.price * quantity,
            'facility': product.facility?.name ?? 'Loja desconhecida',
          });
        } catch (e) {
          log('Erro ao buscar produto ID $productId: $e');
          throw 'Erro ao buscar produto ID $productId';
        }
      }

      Get.back(); // Fecha o scanner
      await Future.delayed(const Duration(milliseconds: 300));
      await _showConfirmationDialog(products, detailedProducts);
    } catch (e) {
      hasError = true;
      errorMessage = "Erro ao ler dados: $e";
      Get.back();
    } finally {
      isProcessing.value = false;

      if (hasError && errorMessage != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        Get.snackbar("Erro", errorMessage, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _showConfirmationDialog(
      List<ProductPaymentRequest> products,
      List<Map<String, dynamic>> detailedProducts,
      ) async {
    final totalCompra = detailedProducts.fold<double>(0, (sum, item) => sum + item['total']);
    final RxBool isConfirmingPayment = false.obs;

    await Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Pagamento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...detailedProducts.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['facility'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        'R\$ ${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Text(
                    'R\$ ${item['total'].toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
              const Divider(height: 20, thickness: 1),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: R\$ ${totalCompra.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        // MODIFICATIONS FOR BUTTON LAYOUT:
        actionsAlignment: MainAxisAlignment.center, // Center the actions
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding if needed
        actions: [
          AppButton(
            width: 120, // Define a width, adjust as needed
            label: 'Cancelar',
            backgroundColor: Colors.red,
            onPressed: () {
              Get.back(); // Closes this confirmation dialog
            },
          ),
          const SizedBox(width: 10), // Spacing between buttons
          Obx(() => AppButton(
            width: 120, // Same width as the cancel button
            label: 'Confirmar',
            backgroundColor: Colors.green,
            isLoading: isConfirmingPayment.value,
            onPressed: isConfirmingPayment.value
                ? null
                : () async {
              isConfirmingPayment.value = true;
              String? successMessage;
              String? failureMessage;

              try {
                final message = await paymentRepository.fetchPayment(products);
                successMessage = message;
                final creditCtrl = Get.find<HomeCreditController>();
                await creditCtrl.loadBalance();
              } catch (e) {
                failureMessage = e.toString();
                log("Erro no pagamento: $e");
              } finally {
                isConfirmingPayment.value = false;
                Get.back(); // Close the confirmation dialog

                await Future.delayed(const Duration(milliseconds: 100));

                if (successMessage != null) {
                  Get.snackbar("Sucesso", successMessage,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white);
                }
                if (failureMessage != null) {
                  Get.snackbar("Erro no Pagamento", failureMessage,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                }
              }
            },
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            scannerController.stop();
            Get.back();
          },
        ),
      ),
      body: MobileScanner(
        controller: scannerController,
        onDetect: _handleScan,
      ),
    );
  }
}