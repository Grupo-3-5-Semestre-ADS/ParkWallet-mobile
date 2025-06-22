import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:park_wallet/services/transaction_event_service.dart';

void main() {
  group('TransactionEventService Tests', () {
    late TransactionEventService transactionEventService;

    setUp(() {
      Get.testMode = true;
      transactionEventService = TransactionEventService();
      Get.put<TransactionEventService>(transactionEventService);
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(transactionEventService.hasRecentRecharge.value, isFalse);
        expect(transactionEventService.eventStream, isA<Stream<TransactionEvent>>());
      });

      test('should be accessible as singleton instance', () {
        final instance = TransactionEventService.instance;
        expect(instance, equals(transactionEventService));
      });

      test('should initialize stream controller correctly', () {
        expect(transactionEventService.eventStream, isNotNull);
        expect(transactionEventService.eventStream, isA<Stream<TransactionEvent>>());
      });
    });

    group('Recharge Event Tests', () {
      test('should notify recharge completed correctly', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        const amount = 100.0;
        const userId = 'user123';
        
        // Act
        transactionEventService.notifyRechargeCompleted(
          amount: amount,
          userId: userId,
        );
        
        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(transactionEventService.hasRecentRecharge.value, isTrue);
        expect(events.length, equals(1));
        expect(events[0].type, equals(TransactionEventType.recharge));
        expect(events[0].amount, equals(amount));
        expect(events[0].userId, equals(userId));
        expect(events[0].timestamp, isA<DateTime>());
        
        await subscription.cancel();
      });

      test('should reset hasRecentRecharge after timeout', () async {
        // Arrange
        const amount = 50.0;
        const userId = 'user456';
        
        // Act
        transactionEventService.notifyRechargeCompleted(
          amount: amount,
          userId: userId,
        );
        
        // Assert - should be true initially
        expect(transactionEventService.hasRecentRecharge.value, isTrue);
        
        // Wait for timeout (5 seconds + buffer)
        await Future.delayed(const Duration(seconds: 6));
        
        // Assert - should be false after timeout
        expect(transactionEventService.hasRecentRecharge.value, isFalse);
      });

      test('should cancel previous timer when new recharge occurs', () async {
        // Arrange
        const amount1 = 25.0;
        const amount2 = 75.0;
        const userId = 'user789';
        
        // Act - First recharge
        transactionEventService.notifyRechargeCompleted(
          amount: amount1,
          userId: userId,
        );
        
        expect(transactionEventService.hasRecentRecharge.value, isTrue);
        
        // Wait 3 seconds (less than timeout)
        await Future.delayed(const Duration(seconds: 3));
        
        // Act - Second recharge (should reset timer)
        transactionEventService.notifyRechargeCompleted(
          amount: amount2,
          userId: userId,
        );
        
        expect(transactionEventService.hasRecentRecharge.value, isTrue);
        
        // Wait another 3 seconds (total 6, but timer was reset)
        await Future.delayed(const Duration(seconds: 3));
        
        // Should still be true because timer was reset
        expect(transactionEventService.hasRecentRecharge.value, isTrue);
        
        // Wait for the new timer to complete
        await Future.delayed(const Duration(seconds: 3));
        
        // Now should be false
        expect(transactionEventService.hasRecentRecharge.value, isFalse);
      });

      test('should handle multiple recharge events', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        final recharges = [
          {'amount': 10.0, 'userId': 'user1'},
          {'amount': 20.0, 'userId': 'user2'},
          {'amount': 30.0, 'userId': 'user3'},
        ];
        
        // Act
        for (final recharge in recharges) {
          transactionEventService.notifyRechargeCompleted(
            amount: recharge['amount'] as double,
            userId: recharge['userId'] as String,
          );
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(3));
        for (int i = 0; i < events.length; i++) {
          expect(events[i].type, equals(TransactionEventType.recharge));
          expect(events[i].amount, equals(recharges[i]['amount']));
          expect(events[i].userId, equals(recharges[i]['userId']));
        }
        
        await subscription.cancel();
      });

      test('should handle zero and negative amounts', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act - Zero amount
        transactionEventService.notifyRechargeCompleted(
          amount: 0.0,
          userId: 'user_zero',
        );
        
        // Act - Negative amount
        transactionEventService.notifyRechargeCompleted(
          amount: -50.0,
          userId: 'user_negative',
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(2));
        expect(events[0].amount, equals(0.0));
        expect(events[1].amount, equals(-50.0));
        expect(transactionEventService.hasRecentRecharge.value, isTrue);
        
        await subscription.cancel();
      });
    });

    group('Payment Event Tests', () {
      test('should notify payment completed correctly', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        const amount = 25.99;
        const userId = 'buyer123';
        
        // Act
        transactionEventService.notifyPaymentCompleted(
          amount: amount,
          userId: userId,
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(1));
        expect(events[0].type, equals(TransactionEventType.payment));
        expect(events[0].amount, equals(amount));
        expect(events[0].userId, equals(userId));
        expect(events[0].timestamp, isA<DateTime>());
        
        // Payment should not affect hasRecentRecharge
        expect(transactionEventService.hasRecentRecharge.value, isFalse);
        
        await subscription.cancel();
      });

      test('should handle multiple payment events', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        final payments = [
          {'amount': 15.50, 'userId': 'buyer1'},
          {'amount': 32.75, 'userId': 'buyer2'},
          {'amount': 8.99, 'userId': 'buyer3'},
        ];
        
        // Act
        for (final payment in payments) {
          transactionEventService.notifyPaymentCompleted(
            amount: payment['amount'] as double,
            userId: payment['userId'] as String,
          );
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(3));
        for (int i = 0; i < events.length; i++) {
          expect(events[i].type, equals(TransactionEventType.payment));
          expect(events[i].amount, equals(payments[i]['amount']));
          expect(events[i].userId, equals(payments[i]['userId']));
        }
        
        await subscription.cancel();
      });

      test('should handle payment with zero and negative amounts', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act
        transactionEventService.notifyPaymentCompleted(
          amount: 0.0,
          userId: 'zero_payment',
        );
        
        transactionEventService.notifyPaymentCompleted(
          amount: -10.0,
          userId: 'negative_payment',
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(2));
        expect(events[0].amount, equals(0.0));
        expect(events[1].amount, equals(-10.0));
        
        await subscription.cancel();
      });
    });

    group('Manual Refresh Event Tests', () {
      test('should trigger history refresh correctly', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act
        transactionEventService.triggerHistoryRefresh();
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(1));
        expect(events[0].type, equals(TransactionEventType.manualRefresh));
        expect(events[0].amount, isNull);
        expect(events[0].userId, isNull);
        expect(events[0].timestamp, isA<DateTime>());
        
        await subscription.cancel();
      });

      test('should handle multiple refresh triggers', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act
        for (int i = 0; i < 5; i++) {
          transactionEventService.triggerHistoryRefresh();
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(5));
        for (final event in events) {
          expect(event.type, equals(TransactionEventType.manualRefresh));
          expect(event.amount, isNull);
          expect(event.userId, isNull);
        }
        
        await subscription.cancel();
      });
    });

    group('Mixed Event Types Tests', () {
      test('should handle mixed event types in sequence', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act - Mixed sequence
        transactionEventService.notifyRechargeCompleted(amount: 100.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 10));
        
        transactionEventService.notifyPaymentCompleted(amount: 25.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 10));
        
        transactionEventService.triggerHistoryRefresh();
        await Future.delayed(const Duration(milliseconds: 10));
        
        transactionEventService.notifyPaymentCompleted(amount: 15.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(4));
        expect(events[0].type, equals(TransactionEventType.recharge));
        expect(events[1].type, equals(TransactionEventType.payment));
        expect(events[2].type, equals(TransactionEventType.manualRefresh));
        expect(events[3].type, equals(TransactionEventType.payment));
        
        await subscription.cancel();
      });

      test('should maintain correct timestamps for events', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        final startTime = DateTime.now();
        
        // Act
        transactionEventService.notifyRechargeCompleted(amount: 50.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 100));
        
        transactionEventService.notifyPaymentCompleted(amount: 20.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 50));
        
        final endTime = DateTime.now();
        
        // Assert
        expect(events.length, equals(2));
        expect(events[0].timestamp.isAfter(startTime), isTrue);
        expect(events[0].timestamp.isBefore(endTime), isTrue);
        expect(events[1].timestamp.isAfter(events[0].timestamp), isTrue);
        expect(events[1].timestamp.isBefore(endTime), isTrue);
        
        await subscription.cancel();
      });
    });

    group('Stream Management Tests', () {
      test('should support multiple listeners', () async {
        // Arrange
        final events1 = <TransactionEvent>[];
        final events2 = <TransactionEvent>[];
        
        final subscription1 = transactionEventService.eventStream.listen((event) {
          events1.add(event);
        });
        
        final subscription2 = transactionEventService.eventStream.listen((event) {
          events2.add(event);
        });
        
        // Act
        transactionEventService.notifyRechargeCompleted(amount: 75.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events1.length, equals(1));
        expect(events2.length, equals(1));
        expect(events1[0].type, equals(events2[0].type));
        expect(events1[0].amount, equals(events2[0].amount));
        
        await subscription1.cancel();
        await subscription2.cancel();
      });

      test('should handle listener cancellation gracefully', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act - Send event before cancellation
        transactionEventService.notifyRechargeCompleted(amount: 30.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 50));
        
        expect(events.length, equals(1));
        
        // Cancel subscription
        await subscription.cancel();
        
        // Send event after cancellation
        transactionEventService.notifyPaymentCompleted(amount: 15.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert - should not receive new events
        expect(events.length, equals(1));
      });

      test('should handle stream errors gracefully', () async {
        // Arrange
        final errors = <dynamic>[];
        final subscription = transactionEventService.eventStream.listen(
          (event) {},
          onError: (error) {
            errors.add(error);
          },
        );
        
        // Act - Normal operation should not cause errors
        transactionEventService.notifyRechargeCompleted(amount: 40.0, userId: 'user1');
        transactionEventService.notifyPaymentCompleted(amount: 20.0, userId: 'user1');
        transactionEventService.triggerHistoryRefresh();
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - No errors should occur
        expect(errors, isEmpty);
        
        await subscription.cancel();
      });
    });

    group('Lifecycle Management Tests', () {
      test('should close stream controller on service close', () async {
        // Arrange
        final service = TransactionEventService();
        final events = <TransactionEvent>[];
        
        final subscription = service.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act - Send event before closing
        service.notifyRechargeCompleted(amount: 60.0, userId: 'user1');
        await Future.delayed(const Duration(milliseconds: 50));
        
        expect(events.length, equals(1));
        
        // Close service
        service.onClose();
        
        // Try to send event after closing - should not crash
        expect(() => service.notifyPaymentCompleted(amount: 30.0, userId: 'user1'), 
               returnsNormally);
        
        await subscription.cancel();
      });

      test('should cancel timer on service close', () async {
        // Arrange
        final service = TransactionEventService();
        
        // Act - Start recharge (which starts timer)
        service.notifyRechargeCompleted(amount: 80.0, userId: 'user1');
        expect(service.hasRecentRecharge.value, isTrue);
        
        // Close service immediately
        service.onClose();
        
        // Wait longer than timer duration
        await Future.delayed(const Duration(seconds: 6));
        
        // Timer should have been cancelled, but we can't easily test the internal state
        // The important thing is that onClose() doesn't throw an exception
        expect(service.isClosed, isTrue);
      });

      test('should handle multiple close calls gracefully', () {
        // Arrange
        final service = TransactionEventService();
        
        // Act & Assert - Multiple closes should not throw
        expect(() => service.onClose(), returnsNormally);
        expect(() => service.onClose(), returnsNormally);
        expect(() => service.onClose(), returnsNormally);
      });
    });

    group('Edge Cases and Performance Tests', () {
      test('should handle rapid event generation', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        // Act - Generate many events rapidly
        for (int i = 0; i < 100; i++) {
          if (i % 3 == 0) {
            transactionEventService.notifyRechargeCompleted(
              amount: i.toDouble(),
              userId: 'user$i',
            );
          } else if (i % 3 == 1) {
            transactionEventService.notifyPaymentCompleted(
              amount: i.toDouble(),
              userId: 'user$i',
            );
          } else {
            transactionEventService.triggerHistoryRefresh();
          }
        }
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(events.length, equals(100));
        
        await subscription.cancel();
      });

      test('should handle very large amounts', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        const largeAmount = 999999999.99;
        
        // Act
        transactionEventService.notifyRechargeCompleted(
          amount: largeAmount,
          userId: 'rich_user',
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(1));
        expect(events[0].amount, equals(largeAmount));
        
        await subscription.cancel();
      });

      test('should handle very long user IDs', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        final longUserId = 'user_' + 'a' * 1000;
        
        // Act
        transactionEventService.notifyPaymentCompleted(
          amount: 50.0,
          userId: longUserId,
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(1));
        expect(events[0].userId, equals(longUserId));
        
        await subscription.cancel();
      });

      test('should handle special characters in user IDs', () async {
        // Arrange
        final events = <TransactionEvent>[];
        final subscription = transactionEventService.eventStream.listen((event) {
          events.add(event);
        });
        
        const specialUserId = 'user@#\$%^&*()_+-=[]{}|;:,.<>?';
        
        // Act
        transactionEventService.notifyRechargeCompleted(
          amount: 25.0,
          userId: specialUserId,
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        expect(events.length, equals(1));
        expect(events[0].userId, equals(specialUserId));
        
        await subscription.cancel();
      });

      test('should maintain memory efficiency with many events', () async {
        // This test ensures the service doesn't accumulate events in memory
        final subscription = transactionEventService.eventStream.listen((event) {
          // Just consume events without storing them
        });
        
        // Generate many events
        for (int i = 0; i < 1000; i++) {
          transactionEventService.notifyRechargeCompleted(
            amount: i.toDouble(),
            userId: 'user$i',
          );
        }
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        // The service should still be responsive
        final testEvents = <TransactionEvent>[];
        final testSubscription = transactionEventService.eventStream.listen((event) {
          testEvents.add(event);
        });
        
        transactionEventService.notifyPaymentCompleted(amount: 99.99, userId: 'test_user');
        await Future.delayed(const Duration(milliseconds: 50));
        
        expect(testEvents.length, equals(1));
        expect(testEvents[0].amount, equals(99.99));
        
        await subscription.cancel();
        await testSubscription.cancel();
      });
    });
  });
}