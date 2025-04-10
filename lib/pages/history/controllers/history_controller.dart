import 'package:get/get.dart';
import 'package:park_wallet/data/models/transaction.dart';

class HistoryController extends GetxController {
  final RxList<Transaction> _allData = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;
  final RxString searchQuery = ''.obs;

  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _generateMockData();
    _applyFilter();
    debounce(searchQuery, (_) => _applyFilter(), time: const Duration(milliseconds: 300));
  }

  void _generateMockData() {
    final now = DateTime.now();
    final data = List.generate(
      50,
          (index) {
        final isPurchase = index % 2 == 0;
        return Transaction(
          name: isPurchase ? "Estacionamento Shopping" : "Recarga de Créditos",
          vendor: isPurchase ? "Shopping Center" : "Via PIX",
          price: (index + 1) * 2.5,
          operation: isPurchase ? "purchase" : "recharge",
          dateTime: now.subtract(Duration(days: index)).toIso8601String(),
          image: null,
        );
      },
    );

    _allData.addAll(data);
  }

  void _applyFilter() {
    final query = searchQuery.value.toLowerCase();
    final matches = _allData
        .where((tx) =>
    tx.name.toLowerCase().contains(query) ||
        tx.vendor.toLowerCase().contains(query))
        .toList();

    filteredTransactions.value = matches.take(_currentPage * _pageSize).toList();
  }

  void loadMore() {
    _currentPage++;
    _applyFilter();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
    _currentPage = 1;
  }
}
