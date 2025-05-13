import 'package:get/get.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/repositories/history_repository.dart';

class HomeHistoryController extends GetxController {
  RxList<Transaction> transactions = <Transaction>[].obs;
  final _historyRepository = HistoryRepository();

  @override Future<void> onInit() async {
    super.onInit();
    await loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final fetched = await _historyRepository.fetchHistory(page: 1, size: 5);
      transactions.assignAll(fetched);
    } catch (e) {
      // Você pode tratar o erro com snackbar ou logger, se quiser
      print('Erro ao carregar histórico: $e');
    }
  }

}
