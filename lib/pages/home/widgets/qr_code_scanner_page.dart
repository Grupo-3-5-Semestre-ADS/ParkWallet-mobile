import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/repositories/payment_repository.dart';
import 'package:park_wallet/repositories/product_repository.dart';

class QRCodeScannerPage extends StatelessWidget {
  QRCodeScannerPage({super.key});

  final PaymentRepository paymentRepository = PaymentRepository();
  final RxBool isProcessing = false.obs;
  final MobileScannerController scannerController = MobileScannerController(); // Novo!

  void _handleScan(BarcodeCapture capture) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    scannerController.stop();

    bool hasError = false;
    String? errorMessage;

    try {
      final code = capture.barcodes.first.rawValue;
      if (code == null) throw 'QR code inválido.';
      print('QR Code bruto: $code');

      final dynamic json = jsonDecode(code);
      print('JSON decodificado: $json');

      if (json is! Map || json['products'] is! List) {
        throw 'QR Code inválido: campo "products" ausente ou malformado.';
      }
      print('Chegou aqui');


      final List productsJson = json['products'];
      final List<ProductPaymentRequest> products = [];
      final List<Map<String, dynamic>> detailedProducts = [];

      final productRepo = ProductRepository();
      print('Chegou aqui');

      for (var item in productsJson) {
        print('Chegou aqui no list');
        if (item['productId'] == null || item['quantity'] == null) {
          throw 'Produto inválido no QR Code.';
        }

        print('Chegou aqui no list2');

        final productId = int.parse(item['productId'].toString());
        final quantity = int.parse(item['quantity'].toString());
        print('Chegou aqui2');
        try {
          final product = await productRepo.fetchProductById(productId);
          print('Produto carregado: ${product.name}');

          products.add(ProductPaymentRequest(productId: productId, quantity: quantity));
          detailedProducts.add({
            'name': product.name,
            'price': product.price,
            'quantity': quantity,
            'total': product.price * quantity,
            'facility': product.facility?.name ?? 'Loja desconhecida',
          });
        } catch (e) {
          print('Erro ao buscar produto ID $productId: $e');
          throw 'Erro ao buscar produto ID $productId';
        }
      }
      print('Chegou aqui3');

      Get.back(); // Fecha o scanner
      await Future.delayed(const Duration(milliseconds: 300));
      await _showConfirmationDialog(products, detailedProducts);
    } catch (e) {
      hasError = true;
      errorMessage = "Erro ao ler dados: $e";
      Get.back(); // Fecha o scanner mesmo assim
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

    await Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Pagamento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        style: const TextStyle(color: Colors.grey),
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

              const Divider(),
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
              Get.back();
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              try {
                final message = await paymentRepository.fetchPayment(products);

                Get.back();
                Get.snackbar("Sucesso", message, snackPosition: SnackPosition.BOTTOM);

                final creditCtrl = Get.find<HomeCreditController>();
                await creditCtrl.loadBalance();
              } catch (e) {
                Get.back();
                Get.snackbar("Erro", e.toString(), snackPosition: SnackPosition.BOTTOM);
              } finally {
                isProcessing.value = false;
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
        controller: scannerController,
        onDetect: _handleScan,
      ),
    );
  }
}
