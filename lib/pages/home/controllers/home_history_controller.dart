import 'package:get/get.dart';
import 'package:park_wallet/data/models/transaction.dart';

class HomeHistoryController extends GetxController {
  var transactions = <Transaction>[
    Transaction(
      name: "Coca-Cola 300ml",
      vendor: "Barraca da Pamonha",
      price: 5.00,
      operation: "purchase",
      dateTime: DateTime.now().toIso8601String(),
    ),
    Transaction(
      name: "Recarregou",
      vendor: "Sistema",
      price: 50.00,
      operation: "recharge",
      dateTime: DateTime.now().toIso8601String(),
    ),
    Transaction(
      name: "Hambúrguer",
      vendor: "Hamburgueria XPTO",
      price: 25.00,
      operation: "purchase",
      dateTime: DateTime.now().toIso8601String(),
    ),
    // ...repita para os demais
  ].obs;


  void addTransaction(
      String name,
      String vendor,
      double price,
      String operation, {
        String? image,
      }) {
    transactions.insert(
      0,
      Transaction(
        name: name,
        vendor: vendor,
        price: price,
        operation: operation,
        dateTime: DateTime.now().toIso8601String(), // Corrigido aqui também
        image: image,
      ),
    );
  }
  void seeMore() {
    // TODO: Implementar funcionalidade de ver mais
  }
}
