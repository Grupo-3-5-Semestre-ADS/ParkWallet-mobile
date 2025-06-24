import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/pages/home/controllers/home_history_controller.dart';
import 'package:park_wallet/repositories/payment_repository.dart';
import 'package:park_wallet/repositories/product_repository.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/routes/app_pages.dart';

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

      Get.offAllNamed(Routes.HOME);
      await Future.delayed(const Duration(milliseconds: 300));
      await _showConfirmationDialog(products, detailedProducts);
    } catch (e) {
      hasError = true;
      errorMessage = "Erro ao ler dados: $e";
      Get.offAllNamed(Routes.HOME);
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
        title: Text('confirm_payment'.tr),
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
                        'R\$ ${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
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
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: [
          AppButton(
            width: 120,
            label: 'cancel'.tr,
            backgroundColor: Colors.red,
            onPressed: () {
              Get.until((route) => route.settings.name == Routes.HOME);
            },
          ),
          const SizedBox(width: 10),
          Obx(() => AppButton(
            width: 120,
            label: 'confirm'.tr,
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
                final historyCtrl = Get.find<HomeHistoryController>();
                await historyCtrl.loadHistory();
              } catch (e) {
                failureMessage = e.toString();
                log("Erro no pagamento: $e");
              } finally {
                isConfirmingPayment.value = false;
                Get.until((route) => route.settings.name == Routes.HOME);
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
        title: Text('scan_qr_code'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            scannerController.stop();
            Get.offAllNamed(Routes.HOME);
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