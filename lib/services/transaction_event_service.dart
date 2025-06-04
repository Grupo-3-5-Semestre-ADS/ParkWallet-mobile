import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';

class TransactionEventService extends GetxService {
  static TransactionEventService get instance => Get.find<TransactionEventService>();
  
  final StreamController<TransactionEvent> _eventController = StreamController<TransactionEvent>.broadcast();
  
  Stream<TransactionEvent> get eventStream => _eventController.stream;
  
  final RxBool hasRecentRecharge = false.obs;
  
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
  
  void notifyRechargeCompleted({required double amount, required String userId}) {
    log('TransactionEventService: Recharge completed - Amount: $amount, UserId: $userId');
    
    hasRecentRecharge.value = true;
    
    _eventController.add(TransactionEvent(
      type: TransactionEventType.recharge,
      amount: amount,
      userId: userId,
      timestamp: DateTime.now(),
    ));
    
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 5), () {
      hasRecentRecharge.value = false;
      log('TransactionEventService: Recent recharge flag reset');
    });
  }
  
  void notifyPaymentCompleted({required double amount, required String userId}) {
    log('TransactionEventService: Payment completed - Amount: $amount, UserId: $userId');
    
    _eventController.add(TransactionEvent(
      type: TransactionEventType.payment,
      amount: amount,
      userId: userId,
      timestamp: DateTime.now(),
    ));
  }
  
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
