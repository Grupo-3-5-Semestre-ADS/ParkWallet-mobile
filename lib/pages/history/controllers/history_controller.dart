import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/repositories/history_repository.dart';

class HistoryController extends GetxController {
  final RxList<Transaction> _allData = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;
  final RxString searchQuery = ''.obs;

  int currentPage = 1;
  final int _pageSize = 10;

  final HistoryRepository _historyRepository = HistoryRepository();
  final ScrollController scrollController = ScrollController();

  RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        loadMore();
      }
    });

    debounce(searchQuery, (_) {
      currentPage = 1;
      _applyFilter();
    }, time: const Duration(milliseconds: 300));
  }

  Future<void> loadData({bool reset = false, bool showMessages = true}) async {
    try {
      if (reset) {
        currentPage = 1;
        _allData.clear();
      }

      final newData = await _historyRepository.fetchHistory(
        page: currentPage,
        size: _pageSize,
      );

      if (newData.isEmpty && _allData.isEmpty && showMessages) {
        Get.snackbar(
          "Sem Dados",
          "Não há transações anteriores.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (newData.isEmpty && _allData.isNotEmpty && showMessages) {
        Get.snackbar(
          "Fim da Lista",
          "Você já visualizou todas as transações.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blueGrey,
          colorText: Colors.white,
        );
      } else {
        _allData.addAll(newData);
        _applyFilter();
      }
    } catch (e) {
      if (showMessages) {
        Get.snackbar(
          "Erro",
          "Erro ao carregar transações: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      log("Erro ao carregar transações: $e");
    }
  }


  void _applyFilter() {
    final query = searchQuery.value.toLowerCase();

    final filtered = _allData.where((transaction) {
      final operation = transaction.operation.toLowerCase();
      return operation.contains(query);
    }).toList();

    final start = 0;
    final end = (currentPage * _pageSize).clamp(0, filtered.length);
    filteredTransactions.assignAll(filtered.sublist(start, end));
  }

  void loadMore() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    currentPage++;
    await loadData(showMessages: false);
    isLoadingMore.value = false;
  }


  void updateSearch(String value) {
    searchQuery.value = value;
    currentPage = 1;
    _applyFilter();
  }
}
