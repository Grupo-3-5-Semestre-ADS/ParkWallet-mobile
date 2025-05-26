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
  
  // Stream subscription for transaction events
  StreamSubscription<TransactionEvent>? _eventSubscription;
  // Timer for periodic checks
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
    
    // Subscribe to balance change events
    try {
      final homeCreditController = Get.find<HomeCreditController>();
      ever(homeCreditController.balance, (_) => _reloadOnBalanceChange());
    } catch (e) {
      log("HomeCreditController not found: $e");
    }
    
    // Subscribe to recent recharge events (legacy)
    ever(HomeCreditController.hasRecentRecharge, (hasRecharge) {
      print("DEBUG: hasRecentRecharge changed to: $hasRecharge");
      if (hasRecharge) {
        log("Recent recharge detected, refreshing history");
        refreshData();
        // Reset the flag after handling
        Future.delayed(const Duration(seconds: 2), () {
          HomeCreditController.hasRecentRecharge.value = false;
          print("DEBUG: hasRecentRecharge reset to false");
        });
      }
    });
    
    // Subscribe to the new transaction event service
    _eventSubscription = TransactionEventService.instance.eventStream.listen((event) {
      log("TransactionEvent received: $event");
      switch (event.type) {
        case TransactionEventType.recharge:
        case TransactionEventType.payment:
        case TransactionEventType.manualRefresh:
          _handleTransactionEvent(event);
          break;
      }
    });
    
    // Start periodic check for recharges
    _startPeriodicCheck();
  }
  
  /// Start periodic check for recent recharges
  void _startPeriodicCheck() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (TransactionEventService.instance.hasRecentRecharge.value || 
          HomeCreditController.hasRecentRecharge.value) {
        log("Periodic check detected recent recharge, refreshing history");
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
  
  // Handle transaction events
  void _handleTransactionEvent(TransactionEvent event) {
    log("Handling transaction event: ${event.type}");
    
    // Add a small delay to ensure backend has processed the transaction
    Future.delayed(const Duration(milliseconds: 1000), () {
      refreshData();
    });
  }
  
  // Method to reload data when balance changes
  void _reloadOnBalanceChange() {
    log("Balance changed, reloading history");
    loadData(reset: true, showMessages: false);
  }
  
  // Method called when page becomes visible
  void onPageVisible() {
    log("History page became visible");
    
    // Check if there was a recent recharge using the new service
    if (TransactionEventService.instance.hasRecentRecharge.value || 
        HomeCreditController.hasRecentRecharge.value) {
      log("Recent recharge detected on page visible, refreshing");
      refreshData();
    } else {
      // Regular refresh to ensure data is up to date
      loadData(reset: true, showMessages: false);
    }
  }

  // Public method for manual refresh
  Future<void> refreshData() async {
    print("DEBUG: refreshData() called");
    if (isRefreshing.value) {
      print("DEBUG: Already refreshing, skipping");
      return;
    }
    
    isRefreshing.value = true;
    hasNewTransactions.value = false;
    
    try {
      final oldCount = _allData.length;
      print("DEBUG: Old transaction count: $oldCount");
      await loadData(reset: true, showMessages: false);
      
      // Check if there are new transactions
      final newCount = _allData.length;
      print("DEBUG: New transaction count: $newCount");
      if (newCount > oldCount) {
        hasNewTransactions.value = true;
        
        // Show success message with count
        final newTransactionsCount = newCount - oldCount;
        Get.snackbar(
          "✓ Atualizado",
          "$newTransactionsCount nova${newTransactionsCount > 1 ? 's' : ''} transaç${newTransactionsCount > 1 ? 'ões' : 'ão'} encontrada${newTransactionsCount > 1 ? 's' : ''}",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        // Show simple refresh confirmation
        Get.snackbar(
          "✓ Atualizado",
          "Histórico de transações atualizado",
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.8),
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
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isRefreshing.value = false;
      
      // Hide new transactions indicator after some time
      Future.delayed(const Duration(seconds: 5), () {
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
