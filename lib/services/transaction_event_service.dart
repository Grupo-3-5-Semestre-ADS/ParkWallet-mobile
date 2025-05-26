import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';

/// Service to manage global transaction events
class TransactionEventService extends GetxService {
  static TransactionEventService get instance => Get.find<TransactionEventService>();
  
  // Stream controller for transaction events
  final StreamController<TransactionEvent> _eventController = StreamController<TransactionEvent>.broadcast();
  
  // Stream getter
  Stream<TransactionEvent> get eventStream => _eventController.stream;
  
  // Observable for recent recharge status
  final RxBool hasRecentRecharge = false.obs;
  
  // Timer for auto-reset
  Timer? _resetTimer;
  
  @override
  void onInit() {
    super.onInit();
    log('TransactionEventService initialized');
  }
  
  @override
  void onClose() {
    _eventController.close();
    _resetTimer?.cancel();
    super.onClose();
  }
  
  /// Notify that a recharge was completed
  void notifyRechargeCompleted({required double amount, required String userId}) {
    log('TransactionEventService: Recharge completed - Amount: $amount, UserId: $userId');
    
    // Set the flag
    hasRecentRecharge.value = true;
    
    // Add event to stream
    _eventController.add(TransactionEvent(
      type: TransactionEventType.recharge,
      amount: amount,
      userId: userId,
      timestamp: DateTime.now(),
    ));
    
    // Reset flag after 5 seconds
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 5), () {
      hasRecentRecharge.value = false;
      log('TransactionEventService: Recent recharge flag reset');
    });
  }
  
  /// Notify that a payment was completed
  void notifyPaymentCompleted({required double amount, required String userId}) {
    log('TransactionEventService: Payment completed - Amount: $amount, UserId: $userId');
    
    _eventController.add(TransactionEvent(
      type: TransactionEventType.payment,
      amount: amount,
      userId: userId,
      timestamp: DateTime.now(),
    ));
  }
  
  /// Manually trigger history refresh
  void triggerHistoryRefresh() {
    log('TransactionEventService: Manual history refresh triggered');
    _eventController.add(TransactionEvent(
      type: TransactionEventType.manualRefresh,
      timestamp: DateTime.now(),
    ));
  }
}

enum TransactionEventType {
  recharge,
  payment,
  manualRefresh,
}

class TransactionEvent {
  final TransactionEventType type;
  final double? amount;
  final String? userId;
  final DateTime timestamp;
  
  TransactionEvent({
    required this.type,
    this.amount,
    this.userId,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'TransactionEvent(type: $type, amount: $amount, userId: $userId, timestamp: $timestamp)';
  }
}
