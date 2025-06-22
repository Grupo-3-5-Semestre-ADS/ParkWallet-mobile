import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/pages/history/controllers/history_controller.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/repositories/transaction_repository.dart';
import 'package:park_wallet/services/transaction_event_service.dart';

import 'history_controller_test.mocks.dart';

@GenerateMocks([TransactionRepository, TransactionEventService, HomeCreditController])
void main() {
  group('HistoryController Tests', () {
    late HistoryController historyController;
    late MockTransactionRepository mockTransactionRepository;
    late MockTransactionEventService mockTransactionEventService;
    late MockHomeCreditController mockHomeCreditController;
    late List<Transaction> testTransactions;

    setUp(() {
      Get.testMode = true;
      mockTransactionRepository = MockTransactionRepository();
      mockTransactionEventService = MockTransactionEventService();
      mockHomeCreditController = MockHomeCreditController();
      
      testTransactions = [
        Transaction(
          id: 1,
          amount: 25.50,
          description: 'Coffee purchase',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(hours: 1)),
          status: 'completed',
          merchantName: 'Coffee Shop',
          category: 'food',
        ),
        Transaction(
          id: 2,
          amount: 100.00,
          description: 'Credit recharge',
          type: 'credit',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'completed',
          merchantName: 'ParkWallet',
          category: 'recharge',
        ),
        Transaction(
          id: 3,
          amount: 15.75,
          description: 'Parking payment',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(hours: 3)),
          status: 'completed',
          merchantName: 'Parking Lot A',
          category: 'parking',
        ),
        Transaction(
          id: 4,
          amount: 8.25,
          description: 'Snack purchase',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'pending',
          merchantName: 'Snack Bar',
          category: 'food',
        ),
        Transaction(
          id: 5,
          amount: 50.00,
          description: 'Refund',
          type: 'credit',
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: 'completed',
          merchantName: 'Store XYZ',
          category: 'refund',
        ),
      ];
      
      historyController = HistoryController();
      historyController.transactionRepository = mockTransactionRepository;
      historyController.transactionEventService = mockTransactionEventService;
      
      // Mock HomeCreditController
      Get.put<HomeCreditController>(mockHomeCreditController);
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(historyController.transactions, isEmpty);
        expect(historyController.filteredTransactions, isEmpty);
        expect(historyController.searchQuery.value, isEmpty);
        expect(historyController.isLoading.value, isTrue);
        expect(historyController.currentPage, equals(1));
        expect(historyController.hasMoreData.value, isTrue);
      });

      test('should load transactions on init', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 20)).called(1);
        expect(historyController.transactions.length, equals(3));
        expect(historyController.filteredTransactions.length, equals(3));
        expect(historyController.isLoading.value, isFalse);
      });

      test('should handle empty transactions on init', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => <Transaction>[]);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 20)).called(1);
        expect(historyController.transactions, isEmpty);
        expect(historyController.filteredTransactions, isEmpty);
        expect(historyController.isLoading.value, isFalse);
        expect(historyController.hasMoreData.value, isFalse);
      });

      test('should handle fetch error on init', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenThrow(Exception('Network error'));
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 20)).called(1);
        expect(historyController.transactions, isEmpty);
        expect(historyController.filteredTransactions, isEmpty);
        expect(historyController.isLoading.value, isFalse);
      });

      test('should listen to transaction events on init', () async {
        // Arrange
        final newTransaction = Transaction(
          id: 6,
          amount: 30.00,
          description: 'New transaction',
          type: 'debit',
          date: DateTime.now(),
          status: 'completed',
          merchantName: 'New Store',
          category: 'shopping',
        );
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(2).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.fromIterable([newTransaction]));
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Assert
        expect(historyController.transactions.length, equals(3)); // 2 initial + 1 from stream
        expect(historyController.transactions.first.id, equals(6)); // New transaction should be first
        verify(mockHomeCreditController.loadUserCredit()).called(1);
      });
    });

    group('Search Functionality Tests', () {
      setUp(() async {
        when(mockTransactionRepository.getTransactions(page: any, limit: any))
            .thenAnswer((_) async => testTransactions);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should filter transactions by description', () async {
        // Act
        historyController.updateSearch('Coffee');
        await Future.delayed(const Duration(milliseconds: 400)); // Wait for debounce
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(1));
        expect(historyController.filteredTransactions.first.description, contains('Coffee'));
      });

      test('should filter transactions by merchant name', () async {
        // Act
        historyController.updateSearch('Coffee Shop');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(1));
        expect(historyController.filteredTransactions.first.merchantName, contains('Coffee Shop'));
      });

      test('should filter transactions by type', () async {
        // Act
        historyController.updateSearch('credit');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(2));
        expect(historyController.filteredTransactions.every((t) => t.type == 'credit'), isTrue);
      });

      test('should filter transactions by category', () async {
        // Act
        historyController.updateSearch('food');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(2));
        expect(historyController.filteredTransactions.every((t) => t.category == 'food'), isTrue);
      });

      test('should handle case-insensitive search', () async {
        // Act
        historyController.updateSearch('COFFEE');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(1));
        expect(historyController.filteredTransactions.first.description?.toLowerCase(), contains('coffee'));
      });

      test('should return empty list for no matches', () async {
        // Act
        historyController.updateSearch('NonExistent');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions, isEmpty);
      });

      test('should return all transactions when search is empty', () async {
        // Arrange - first set a search
        historyController.updateSearch('Coffee');
        await Future.delayed(const Duration(milliseconds: 400));
        expect(historyController.filteredTransactions.length, equals(1));
        
        // Act - clear search
        historyController.updateSearch('');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(testTransactions.length));
      });

      test('should handle special characters in search', () async {
        // Arrange
        final specialTransaction = Transaction(
          id: 7,
          amount: 12.50,
          description: 'Purchase @ Store & Co.',
          type: 'debit',
          date: DateTime.now(),
          status: 'completed',
          merchantName: 'Store & Co.',
          category: 'shopping',
        );
        
        when(mockTransactionRepository.getTransactions(page: any, limit: any))
            .thenAnswer((_) async => [specialTransaction]);
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        historyController.updateSearch('@');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(historyController.filteredTransactions.length, equals(1));
        expect(historyController.filteredTransactions.first.description, contains('@'));
      });
    });

    group('Pagination Tests', () {
      test('should load more transactions when requested', () async {
        // Arrange
        final firstPageTransactions = testTransactions.take(3).toList();
        final secondPageTransactions = testTransactions.skip(3).take(2).toList();
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => firstPageTransactions);
        when(mockTransactionRepository.getTransactions(page: 2, limit: 20))
            .thenAnswer((_) async => secondPageTransactions);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(historyController.transactions.length, equals(3));
        
        // Act
        historyController.loadMoreTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 2, limit: 20)).called(1);
        expect(historyController.transactions.length, equals(5));
        expect(historyController.currentPage, equals(2));
      });

      test('should not load more when no more transactions available', () async {
        // Arrange
        final limitedTransactions = testTransactions.take(10).toList(); // Less than limit
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => limitedTransactions);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(historyController.hasMoreData.value, isFalse);
        
        // Act
        historyController.loadMoreTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verifyNever(mockTransactionRepository.getTransactions(page: 2, limit: 20));
      });

      test('should handle pagination error', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        when(mockTransactionRepository.getTransactions(page: 2, limit: 20))
            .thenThrow(Exception('Pagination error'));
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        historyController.loadMoreTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockTransactionRepository.getTransactions(page: 2, limit: 20)).called(1);
        expect(historyController.isLoading.value, isFalse);
        expect(historyController.currentPage, equals(1)); // Should not increment on error
      });

      test('should prevent concurrent fetch operations', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: any, limit: any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return testTransactions.take(3).toList();
        });
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        
        // Act - try to load more before first load completes
        historyController.loadMoreTransactions();
        historyController.loadMoreTransactions();
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert - should only call once for init and once for first loadMore
        verify(mockTransactionRepository.getTransactions(page: 1, limit: 20)).called(1);
        verify(mockTransactionRepository.getTransactions(page: 2, limit: 20)).called(1);
      });
    });

    group('Refresh Functionality Tests', () {
      test('should refresh transactions and reset pagination', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Load more to increase page
        when(mockTransactionRepository.getTransactions(page: 2, limit: 20))
            .thenAnswer((_) async => testTransactions.skip(3).take(2).toList());
        historyController.loadMoreTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(historyController.currentPage, equals(2));
        expect(historyController.transactions.length, equals(5));
        
        // Act - refresh
        final refreshedTransactions = testTransactions.take(4).toList();
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => refreshedTransactions);
        
        historyController.refreshTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(historyController.currentPage, equals(1));
        expect(historyController.transactions.length, equals(4));
        expect(historyController.hasMoreData.value, isTrue);
      });

      test('should handle refresh error', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        final originalCount = historyController.transactions.length;
        
        // Act - refresh with error
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenThrow(Exception('Refresh error'));
        
        historyController.refreshTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should maintain original data
        expect(historyController.transactions.length, equals(originalCount));
        expect(historyController.isLoading.value, isFalse);
      });
    });

    group('Transaction Event Handling Tests', () {
      test('should add new transaction from event stream', () async {
        // Arrange
        final newTransaction = Transaction(
          id: 6,
          amount: 45.00,
          description: 'New event transaction',
          type: 'debit',
          date: DateTime.now(),
          status: 'completed',
          merchantName: 'Event Store',
          category: 'shopping',
        );
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(2).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.fromIterable([newTransaction]));
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Assert
        expect(historyController.transactions.length, equals(3));
        expect(historyController.transactions.first.id, equals(6)); // Should be added at the beginning
        expect(historyController.filteredTransactions.length, equals(3));
        verify(mockHomeCreditController.loadUserCredit()).called(1);
      });

      test('should handle multiple transactions from event stream', () async {
        // Arrange
        final newTransactions = [
          Transaction(
            id: 6,
            amount: 20.00,
            description: 'Event transaction 1',
            type: 'debit',
            date: DateTime.now(),
            status: 'completed',
            merchantName: 'Store 1',
            category: 'shopping',
          ),
          Transaction(
            id: 7,
            amount: 30.00,
            description: 'Event transaction 2',
            type: 'credit',
            date: DateTime.now().add(const Duration(minutes: 1)),
            status: 'completed',
            merchantName: 'Store 2',
            category: 'refund',
          ),
        ];
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(1).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.fromIterable(newTransactions));
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert
        expect(historyController.transactions.length, equals(3));
        expect(historyController.transactions[0].id, equals(7)); // Latest should be first
        expect(historyController.transactions[1].id, equals(6));
        verify(mockHomeCreditController.loadUserCredit()).called(2);
      });

      test('should handle event stream errors gracefully', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(2).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.error(Exception('Stream error')));
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Assert - should not crash and maintain original data
        expect(historyController.transactions.length, equals(2));
        expect(historyController.isLoading.value, isFalse);
      });

      test('should maintain transaction order when adding from events', () async {
        // Arrange
        final oldTransaction = Transaction(
          id: 6,
          amount: 20.00,
          description: 'Old transaction',
          type: 'debit',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          status: 'completed',
          merchantName: 'Old Store',
          category: 'shopping',
        );
        
        final newTransaction = Transaction(
          id: 7,
          amount: 30.00,
          description: 'New transaction',
          type: 'debit',
          date: DateTime.now(),
          status: 'completed',
          merchantName: 'New Store',
          category: 'shopping',
        );
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => [oldTransaction]);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.fromIterable([newTransaction]));
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Assert - newer transaction should be first
        expect(historyController.transactions.length, equals(2));
        expect(historyController.transactions.first.id, equals(7));
        expect(historyController.transactions.last.id, equals(6));
      });
    });

    group('Edge Cases and Integration Tests', () {
      test('should handle transactions with null fields', () async {
        // Arrange
        final transactionWithNulls = Transaction(
          id: 8,
          amount: 15.00,
          description: null,
          type: 'debit',
          date: DateTime.now(),
          status: 'completed',
          merchantName: null,
          category: null,
        );
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => [transactionWithNulls]);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should handle gracefully
        expect(historyController.transactions.length, equals(1));
        expect(historyController.filteredTransactions.length, equals(1));
        
        // Test search with null fields
        historyController.updateSearch('test');
        await Future.delayed(const Duration(milliseconds: 400));
        
        expect(historyController.filteredTransactions, isEmpty);
      });

      test('should handle very large transaction lists', () async {
        // Arrange
        final largeTransactionList = List.generate(1000, (index) => Transaction(
          id: index + 1,
          amount: (index + 1) * 10.0,
          description: 'Transaction $index',
          type: index % 2 == 0 ? 'debit' : 'credit',
          date: DateTime.now().subtract(Duration(hours: index)),
          status: 'completed',
          merchantName: 'Merchant $index',
          category: 'category${index % 5}',
        ));
        
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => largeTransactionList.take(20).toList());
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(historyController.transactions.length, equals(20));
        expect(historyController.isLoading.value, isFalse);
      });

      test('should handle rapid search updates', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: any, limit: any))
            .thenAnswer((_) async => testTransactions);
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act - rapid search updates
        historyController.updateSearch('C');
        historyController.updateSearch('Co');
        historyController.updateSearch('Cof');
        historyController.updateSearch('Coffee');
        
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert - should handle debouncing correctly
        expect(historyController.searchQuery.value, equals('Coffee'));
        expect(historyController.filteredTransactions.length, equals(1));
      });

      test('should maintain state consistency during errors', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => testTransactions.take(3).toList());
        when(mockTransactionRepository.getTransactions(page: 2, limit: 20))
            .thenThrow(Exception('Network error'));
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        historyController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        final initialCount = historyController.transactions.length;
        
        // Act
        historyController.loadMoreTransactions();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - state should remain consistent
        expect(historyController.transactions.length, equals(initialCount));
        expect(historyController.isLoading.value, isFalse);
        expect(historyController.currentPage, equals(1)); // Should not increment on error
      });

      test('should handle memory management correctly', () {
        // Arrange
        final controller = HistoryController();
        controller.transactionRepository = mockTransactionRepository;
        controller.transactionEventService = mockTransactionEventService;
        
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act
        controller.onInit();
        controller.onClose();
        
        // Assert - no memory leaks or exceptions
        expect(controller.isClosed, isTrue);
      });

      test('should handle concurrent operations gracefully', () async {
        // Arrange
        when(mockTransactionRepository.getTransactions(page: any, limit: any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return testTransactions.take(3).toList();
        });
        when(mockTransactionEventService.transactionStream)
            .thenAnswer((_) => Stream.empty());
        
        // Act - concurrent operations
        historyController.onInit();
        historyController.refreshTransactions();
        historyController.updateSearch('Coffee');
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Assert - should handle gracefully without crashes
        expect(historyController.isLoading.value, isFalse);
        expect(historyController.transactions.isNotEmpty, isTrue);
      });
    });
  });
}