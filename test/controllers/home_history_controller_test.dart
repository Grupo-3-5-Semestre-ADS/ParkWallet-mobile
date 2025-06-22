import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/pages/home/controllers/home_history_controller.dart';
import 'package:park_wallet/repositories/transaction_repository.dart';

import 'home_history_controller_test.mocks.dart';

@GenerateMocks([TransactionRepository])
void main() {
  group('HomeHistoryController Tests', () {
    late HomeHistoryController homeHistoryController;
    late MockTransactionRepository mockTransactionRepository;
    late List<Transaction> testTransactions;

    setUp(() {
      Get.testMode = true;
      mockTransactionRepository = MockTransactionRepository();
      
      testTransactions = [
        Transaction(
          id: 1,
          amount: 25.50,
          description: 'Coffee purchase',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(minutes: 30)),
          status: 'completed',
          merchantName: 'Coffee Shop',
          category: 'food',
        ),
        Transaction(
          id: 2,
          amount: 100.00,
          description: 'Credit recharge',
          type: 'credit',
          date: DateTime.now().subtract(const Duration(hours: 1)),
          status: 'completed',
          merchantName: 'ParkWallet',
          category: 'recharge',
        ),
        Transaction(
          id: 3,
          amount: 15.75,
          description: 'Parking payment',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'completed',
          merchantName: 'Parking Lot A',
          category: 'parking',
        ),
        Transaction(
          id: 4,
          amount: 8.25,
          description: 'Snack purchase',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(hours: 3)),
          status: 'pending',
          merchantName: 'Snack Bar',
          category: 'food',
        ),
        Transaction(
          id: 5,
          amount: 50.00,
          description: 'Refund',
          type: 'credit',
          date: DateTime.now().subtract(const Duration(hours: 4)),
          status: 'completed',
          merchantName: 'Store XYZ',
          category: 'refund',
        ),
        Transaction(
          id: 6,
          amount: 12.30,
          description: 'Bus ticket',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          status: 'completed',
          merchantName: 'Transport Co',
          category: 'transport',
        ),
      ];
      
      homeHistoryController = HomeHistoryController();
      homeHistoryController.transactionRepository = mockTransactionRepository;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isTrue);
      });

      test('should load recent transactions on init with limit of 5', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(5).toList());
        
        // Act
        homeHistoryController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 5)).called(1);
        expect(homeHistoryController.recentTransactions.length, equals(5));
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle fewer than 5 transactions', () async {
        // Arrange
        final limitedTransactions = testTransactions.take(3).toList();
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => limitedTransactions);
        
        // Act
        homeHistoryController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 5)).called(1);
        expect(homeHistoryController.recentTransactions.length, equals(3));
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle empty transactions list', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => <Transaction>[]);
        
        // Act
        homeHistoryController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 5)).called(1);
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle fetch error on init', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenThrow(Exception('Network error'));
        
        // Act
        homeHistoryController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 5)).called(1);
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isFalse);
      });
    });

    group('Loading Recent Transactions Tests', () {
      test('should set loading state correctly during fetch', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return testTransactions.take(5).toList();
        });
        
        // Act
        homeHistoryController.loadRecentTransactions();
        
        // Assert - should be loading
        expect(homeHistoryController.isLoading.value, isTrue);
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert - should not be loading after completion
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should update recent transactions list', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(3));
        expect(homeHistoryController.recentTransactions[0].id, equals(1));
        expect(homeHistoryController.recentTransactions[1].id, equals(2));
        expect(homeHistoryController.recentTransactions[2].id, equals(3));
      });

      test('should maintain transaction order from repository', () async {
        // Arrange
        final orderedTransactions = [
          testTransactions[2], // id: 3
          testTransactions[0], // id: 1
          testTransactions[1], // id: 2
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => orderedTransactions);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(3));
        expect(homeHistoryController.recentTransactions[0].id, equals(3));
        expect(homeHistoryController.recentTransactions[1].id, equals(1));
        expect(homeHistoryController.recentTransactions[2].id, equals(2));
      });

      test('should handle network timeout error', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenThrow(Exception('Timeout error'));
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle server error', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenThrow(Exception('Server error 500'));
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle authentication error', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenThrow(Exception('Authentication failed'));
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isFalse);
      });
    });

    group('Data Validation Tests', () {
      test('should handle transactions with null fields', () async {
        // Arrange
        final transactionsWithNulls = [
          Transaction(
            id: 1,
            amount: 25.50,
            description: null,
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: null,
            category: null,
          ),
          Transaction(
            id: 2,
            amount: 100.00,
            description: 'Valid transaction',
            type: 'credit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Valid Merchant',
            category: 'valid',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithNulls);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(2));
        expect(homeHistoryController.recentTransactions[0].description, isNull);
        expect(homeHistoryController.recentTransactions[1].description, equals('Valid transaction'));
      });

      test('should handle transactions with zero amounts', () async {
        // Arrange
        final transactionsWithZero = [
          Transaction(
            id: 1,
            amount: 0.0,
            description: 'Zero amount transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Test Merchant',
            category: 'test',
          ),
          Transaction(
            id: 2,
            amount: 25.50,
            description: 'Normal transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Normal Merchant',
            category: 'normal',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithZero);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(2));
        expect(homeHistoryController.recentTransactions[0].amount, equals(0.0));
        expect(homeHistoryController.recentTransactions[1].amount, equals(25.50));
      });

      test('should handle transactions with negative amounts', () async {
        // Arrange
        final transactionsWithNegative = [
          Transaction(
            id: 1,
            amount: -10.0,
            description: 'Negative amount transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Test Merchant',
            category: 'test',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithNegative);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(1));
        expect(homeHistoryController.recentTransactions[0].amount, equals(-10.0));
      });

      test('should handle transactions with very large amounts', () async {
        // Arrange
        final transactionsWithLargeAmounts = [
          Transaction(
            id: 1,
            amount: 999999.99,
            description: 'Large amount transaction',
            type: 'credit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Large Merchant',
            category: 'large',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithLargeAmounts);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(1));
        expect(homeHistoryController.recentTransactions[0].amount, equals(999999.99));
      });

      test('should handle transactions with different statuses', () async {
        // Arrange
        final transactionsWithDifferentStatuses = [
          Transaction(
            id: 1,
            amount: 25.50,
            description: 'Completed transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Merchant 1',
            category: 'test',
          ),
          Transaction(
            id: 2,
            amount: 30.00,
            description: 'Pending transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'pending',
            merchantName: 'Merchant 2',
            category: 'test',
          ),
          Transaction(
            id: 3,
            amount: 15.00,
            description: 'Failed transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'failed',
            merchantName: 'Merchant 3',
            category: 'test',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithDifferentStatuses);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(3));
        expect(homeHistoryController.recentTransactions[0].status, equals('completed'));
        expect(homeHistoryController.recentTransactions[1].status, equals('pending'));
        expect(homeHistoryController.recentTransactions[2].status, equals('failed'));
      });
    });

    group('Performance and Edge Cases Tests', () {
      test('should handle concurrent load requests', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return testTransactions.take(3).toList();
        });
        
        // Act - make concurrent requests
        homeHistoryController.loadRecentTransactions();
        homeHistoryController.loadRecentTransactions();
        homeHistoryController.loadRecentTransactions();
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert - should handle gracefully
        expect(homeHistoryController.recentTransactions.length, equals(3));
        expect(homeHistoryController.isLoading.value, isFalse);
        // Repository should be called multiple times but controller should handle it
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 5)).called(greaterThan(0));
      });

      test('should handle very fast successive calls', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(2).toList());
        
        // Act - very fast successive calls
        for (int i = 0; i < 10; i++) {
          homeHistoryController.loadRecentTransactions();
        }
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should handle gracefully
        expect(homeHistoryController.recentTransactions.length, equals(2));
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle transactions with special characters', () async {
        // Arrange
        final transactionsWithSpecialChars = [
          Transaction(
            id: 1,
            amount: 25.50,
            description: 'Transaction with émojis 🎉💰',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Café & Restaurante',
            category: 'food & beverage',
          ),
          Transaction(
            id: 2,
            amount: 30.00,
            description: 'Transaction with symbols @#\$%^&*()',
            type: 'credit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Store & Co.',
            category: 'retail',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithSpecialChars);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(2));
        expect(homeHistoryController.recentTransactions[0].description, contains('🎉'));
        expect(homeHistoryController.recentTransactions[1].merchantName, contains('&'));
      });

      test('should handle transactions with very long descriptions', () async {
        // Arrange
        final longDescription = 'A' * 1000; // Very long description
        final transactionsWithLongText = [
          Transaction(
            id: 1,
            amount: 25.50,
            description: longDescription,
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Test Merchant',
            category: 'test',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => transactionsWithLongText);
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(1));
        expect(homeHistoryController.recentTransactions[0].description?.length, equals(1000));
      });

      test('should handle memory management correctly', () {
        // Arrange
        final controller = HomeHistoryController();
        controller.transactionRepository = mockTransactionRepository;
        
        // Act
        controller.onInit();
        controller.onClose();
        
        // Assert - no memory leaks or exceptions
        expect(controller.isClosed, isTrue);
      });

      test('should maintain state consistency after errors', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(2).toList());
        
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(homeHistoryController.recentTransactions.length, equals(2));
        
        // Act - simulate error on next call
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenThrow(Exception('Network error'));
        
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should clear transactions on error
        expect(homeHistoryController.recentTransactions, isEmpty);
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle exactly 5 transactions correctly', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(5).toList());
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(5));
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle more than 5 transactions by limiting to 5', () async {
        // Arrange - repository returns exactly 5 due to limit parameter
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(5).toList());
        
        // Act
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 5)).called(1);
        expect(homeHistoryController.recentTransactions.length, equals(5));
      });
    });

    group('Integration Tests', () {
      test('should work correctly with onInit lifecycle', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        
        // Act
        homeHistoryController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(3));
        expect(homeHistoryController.isLoading.value, isFalse);
      });

      test('should handle refresh scenario', () async {
        // Arrange - initial load
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => testTransactions.take(2).toList());
        
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(homeHistoryController.recentTransactions.length, equals(2));
        
        // Act - refresh with new data
        final newTransactions = [
          Transaction(
            id: 7,
            amount: 35.00,
            description: 'New transaction',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'New Merchant',
            category: 'new',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 5))
            .thenAnswer((_) async => newTransactions);
        
        homeHistoryController.loadRecentTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(homeHistoryController.recentTransactions.length, equals(1));
        expect(homeHistoryController.recentTransactions[0].id, equals(7));
      });
    });
  });
}