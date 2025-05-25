import 'dart:developer';

import 'package:get/get.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/repositories/history_repository.dart';

class HomeHistoryController extends GetxController {
  RxList<Transaction> transactions = <Transaction>[].obs;
  final _historyRepository = HistoryRepository();
  RxBool isLoading = false.obs;
  RxInt maxVisibleItems = 5.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadHistory();
  }

  Future<void> loadHistory({int? size}) async {
    try {
      isLoading.value = true;
      final fetchSize = size ?? maxVisibleItems.value;
      final fetched = await _historyRepository.fetchHistory(page: 1, size: fetchSize);
      transactions.assignAll(fetched);
      log(fetched.toString());
    } catch (e) {
      Get.snackbar("Erro", "Erro ao carregar histórico: $e");
      log('Erro ao carregar histórico: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
