import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/repositories/history_repository.dart';
import 'package:park_wallet/services/transaction_event_service.dart';

class HistoryController extends GetxController with GetTickerProviderStateMixin {
  final RxList<Transaction> _allData = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;
  final RxString searchQuery = ''.obs;

  int currentPage = 1;
  final int _pageSize = 10;

  final HistoryRepository _historyRepository = HistoryRepository();
  final ScrollController scrollController = ScrollController();

  RxBool isLoadingMore = false.obs;
  RxBool isRefreshing = false.obs;
  RxBool hasNewTransactions = false.obs;
  
  StreamSubscription<TransactionEvent>? _eventSubscription;
  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    loadData();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });

    debounce(searchQuery, (_) {
      currentPage = 1;
      _applyFilter();
    }, time: const Duration(milliseconds: 300));
    
    try {
      final homeCreditController = Get.find<HomeCreditController>();
      ever(homeCreditController.balance, (_) => _reloadOnBalanceChange());
    } catch (e) {
      log("HomeCreditController not found: $e");
    }
    
    ever(HomeCreditController.hasRecentRecharge, (hasRecharge) {
      if (hasRecharge) {
        refreshData();
        Future.delayed(const Duration(seconds: 2), () {
          HomeCreditController.hasRecentRecharge.value = false;
        });
      }
    });
    
    _eventSubscription = TransactionEventService.instance.eventStream.listen((event) {
      switch (event.type) {
        case TransactionEventType.recharge:
        case TransactionEventType.payment:
        case TransactionEventType.manualRefresh:
          _handleTransactionEvent(event);
          break;
      }
    });
    
    _startPeriodicCheck();
  }
  
  void _startPeriodicCheck() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (TransactionEventService.instance.hasRecentRecharge.value || 
          HomeCreditController.hasRecentRecharge.value) {
        refreshData();
      }
    });
  }
  
  @override
  void onClose() {
    _eventSubscription?.cancel();
    _periodicTimer?.cancel();
    super.onClose();
  }
  
  void _handleTransactionEvent(TransactionEvent event) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      refreshData();
    });
  }
  
  void _reloadOnBalanceChange() {
    loadData(reset: true, showMessages: false);
  }
  
  void onPageVisible() {
    if (TransactionEventService.instance.hasRecentRecharge.value ||
        HomeCreditController.hasRecentRecharge.value) {
      refreshData();
    } else {
      loadData(reset: true, showMessages: false);
    }
  }

  Future<void> refreshData() async {
    if (isRefreshing.value) {
      return;
    }
    
    isRefreshing.value = true;
    hasNewTransactions.value = false;
    
    try {
      final oldCount = _allData.length;
      await loadData(reset: true, showMessages: false);
      
      final newCount = _allData.length;
      if (newCount > oldCount) {
        hasNewTransactions.value = true;
        
        final newTransactionsCount = newCount - oldCount;
        Get.snackbar(
          "✓ Atualizado",
          "$newTransactionsCount nova${newTransactionsCount > 1 ? 's' : ''} transaç${newTransactionsCount > 1 ? 'ões' : 'ão'} encontrada${newTransactionsCount > 1 ? 's' : ''}",
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: 8,
        );
      }
    } catch (e) {
      log("Error refreshing data: $e");
      Get.snackbar(
        "Erro",
        "Erro ao atualizar histórico",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      isRefreshing.value = false;
      
      Future.delayed(const Duration(seconds: 3), () {
        hasNewTransactions.value = false;
      });
    }
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
