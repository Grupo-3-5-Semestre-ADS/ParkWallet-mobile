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

  @override
  void onInit() {
    print("OnInit");
    super.onInit();
    loadData();
    debounce(searchQuery, (_) {
      currentPage = 1;
      _applyFilter();
    }, time: const Duration(milliseconds: 300));
  }

  // Carregar as transações usando o HistoryRepository
  Future<void> loadData({bool reset = false}) async {
    try {
      if (reset) {
        currentPage = 1;
        _allData.clear();
      }

      final newData = await _historyRepository.fetchHistory(page: currentPage, size: _pageSize);

      if (newData.isEmpty && _allData.isEmpty) {
        Get.snackbar(
          "Sem Dados",
          "Não há transações anteriores.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (newData.isEmpty && _allData.isNotEmpty) {
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
      Get.snackbar(
        "Erro",
        "Erro ao carregar transações: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Erro ao carregar transações: $e");
    }
  }



  // Aplicar o filtro de busca
  void _applyFilter() {
    final query = searchQuery.value.toLowerCase();

    final filtered = _allData.where((transaction) {
      final operation = transaction.operation.toLowerCase();
      return operation.contains(query); // Filtra por operação, ou pode adicionar mais filtros
    }).toList();

    final start = 0;
    final end = (currentPage * _pageSize).clamp(0, filtered.length);
    filteredTransactions.assignAll(filtered.sublist(start, end));
  }

  // Carregar mais transações para a próxima página
  void loadMore() {
    currentPage++;
    log("Carregando página $currentPage");
    loadData();
  }


  // Atualizar o valor de pesquisa
  void updateSearch(String value) {
    searchQuery.value = value;
    currentPage = 1;
    _applyFilter();
  }
}
