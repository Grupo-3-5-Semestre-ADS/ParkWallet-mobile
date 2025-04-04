import 'package:get/get.dart';
import 'package:park_wallet/data/models/transaction.dart';

class HomeHistoryController extends GetxController {
  var transactions = <Transaction>[
    Transaction(name: "Coca-Cola 300ml", vendor: "Barraca da Pamonha", price: 5.00, operation: "purchase"),
    Transaction(name: "Recarregou", vendor: "Sistema", price: 50.00, operation: "recharge"),
    Transaction(name: "Hambúrguer", vendor: "Hamburgueria XPTO", price: 25.00, operation: "purchase"),
    Transaction(name: "Recarregou", vendor: "Sistema", price: 30.00, operation: "recharge"),
    Transaction(name: "Coca-Cola 300ml", vendor: "Barraca da Pamonha", price: 5.00, operation: "purchase"),
    Transaction(name: "Recarregou", vendor: "Sistema", price: 50.00, operation: "recharge"),
    Transaction(name: "Hambúrguer", vendor: "Hamburgueria XPTO", price: 25.00, operation: "purchase"),
    Transaction(name: "Recarregou", vendor: "Sistema", price: 30.00, operation: "recharge"),
    Transaction(name: "Coca-Cola 300ml", vendor: "Barraca da Pamonha", price: 5.00, operation: "purchase"),
    Transaction(name: "Recarregou", vendor: "Sistema", price: 50.00, operation: "recharge"),
    Transaction(name: "Hambúrguer", vendor: "Hamburgueria XPTO", price: 25.00, operation: "purchase"),
    Transaction(name: "Recarregou", vendor: "Sistema", price: 30.00, operation: "recharge"),
  ].obs;

  void addTransaction(String name, String vendor, double price, String operation, {String? image}) {
    transactions.insert(0, Transaction(name: name, vendor: vendor, price: price, operation: operation, image: image));
  }

  void seeMore() {
    // TODO: Implementar funcionalidade de ver mais
  }
}
