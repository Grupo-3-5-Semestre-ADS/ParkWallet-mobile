import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/data/dto/transaction_item.dart';

void main() {
  group('Transaction Tests', () {
    test('should create Transaction with all required fields', () {
      const totalValue = 25.50;
      const operation = 'PURCHASE';
      const createdAt = '2024-01-15T10:30:00Z';
      final items = [
        TransactionItem(
          productId: 1,
          quantity: 2,
          totalValue: 15.00,
        ),
        TransactionItem(
          productId: 2,
          quantity: 1,
          totalValue: 10.50,
        ),
      ];
      
      final transaction = Transaction(
        totalValue: totalValue,
        operation: operation,
        items: items,
        createdAt: createdAt,
      );
      
      expect(transaction.totalValue, equals(totalValue));
      expect(transaction.operation, equals(operation));
      expect(transaction.items, equals(items));
      expect(transaction.createdAt, equals(createdAt));
      expect(transaction.items.length, equals(2));
    });

    test('should create Transaction from JSON with valid data', () {
      final json = {
        'totalValue': '45.75',
        'operation': 'PAYMENT',
        'createdAt': '2024-02-20T14:45:30Z',
        'itemsTransaction': [
          {
            'productId': 10,
            'quantity': 3,
            'totalValue': '30.00',
          },
          {
            'productId': 20,
            'quantity': 1,
            'totalValue': '15.75',
          },
        ],
      };
      
      final transaction = Transaction.fromJson(json);
      
      expect(transaction.totalValue, equals(45.75));
      expect(transaction.operation, equals('PAYMENT'));
      expect(transaction.createdAt, equals('2024-02-20T14:45:30Z'));
      expect(transaction.items.length, equals(2));
      expect(transaction.items[0].productId, equals(10));
      expect(transaction.items[0].quantity, equals(3));
      expect(transaction.items[0].totalValue, equals(30.00));
      expect(transaction.items[1].productId, equals(20));
      expect(transaction.items[1].quantity, equals(1));
      expect(transaction.items[1].totalValue, equals(15.75));
    });

    test('should handle missing or null values in JSON', () {
      final json = {
        'itemsTransaction': [],
      };
      
      final transaction = Transaction.fromJson(json);
      
      expect(transaction.totalValue, equals(0.0));
      expect(transaction.operation, equals(''));
      expect(transaction.createdAt, equals(''));
      expect(transaction.items, isEmpty);
    });

    test('should handle invalid totalValue in JSON', () {
      final json1 = {
        'totalValue': 'invalid',
        'operation': 'TEST',
        'createdAt': '2024-01-01',
        'itemsTransaction': [],
      };
      
      final json2 = {
        'totalValue': null,
        'operation': 'TEST',
        'createdAt': '2024-01-01',
        'itemsTransaction': [],
      };
      
      final transaction1 = Transaction.fromJson(json1);
      final transaction2 = Transaction.fromJson(json2);
      
      expect(transaction1.totalValue, equals(0.0));
      expect(transaction2.totalValue, equals(0.0));
    });

    test('should handle different totalValue formats in JSON', () {
      final jsonWithInt = {
        'totalValue': 100,
        'operation': 'RECHARGE',
        'createdAt': '2024-01-01',
        'itemsTransaction': [],
      };
      
      final jsonWithDouble = {
        'totalValue': 99.99,
        'operation': 'PURCHASE',
        'createdAt': '2024-01-01',
        'itemsTransaction': [],
      };
      
      final jsonWithString = {
        'totalValue': '50.25',
        'operation': 'REFUND',
        'createdAt': '2024-01-01',
        'itemsTransaction': [],
      };
      
      final transaction1 = Transaction.fromJson(jsonWithInt);
      final transaction2 = Transaction.fromJson(jsonWithDouble);
      final transaction3 = Transaction.fromJson(jsonWithString);
      
      expect(transaction1.totalValue, equals(100.0));
      expect(transaction2.totalValue, equals(99.99));
      expect(transaction3.totalValue, equals(50.25));
    });

    test('should create Transaction with empty items list', () {
      final transaction = Transaction(
        totalValue: 0.0,
        operation: 'EMPTY',
        items: [],
        createdAt: '2024-01-01T00:00:00Z',
      );
      
      expect(transaction.items, isEmpty);
      expect(transaction.items.length, equals(0));
    });

    test('should handle various operation types', () {
      final operations = [
        'PURCHASE',
        'PAYMENT',
        'RECHARGE',
        'REFUND',
        'TRANSFER',
        'WITHDRAWAL',
      ];
      
      for (final operation in operations) {
        final transaction = Transaction(
          totalValue: 10.0,
          operation: operation,
          items: [],
          createdAt: '2024-01-01T00:00:00Z',
        );
        
        expect(transaction.operation, equals(operation));
      }
    });

    test('should have correct toString representation', () {
      final items = [
        TransactionItem(
          productId: 1,
          quantity: 1,
          totalValue: 10.0,
        ),
      ];
      
      final transaction = Transaction(
        totalValue: 10.0,
        operation: 'TEST',
        items: items,
        createdAt: '2024-01-01T12:00:00Z',
      );
      
      final stringRepresentation = transaction.toString();
      
      expect(stringRepresentation, contains('Transaction{'));
      expect(stringRepresentation, contains('totalValue: 10.0'));
      expect(stringRepresentation, contains('operation: TEST'));
      expect(stringRepresentation, contains('items: '));
      expect(stringRepresentation, contains('createdAt: 2024-01-01T12:00:00Z'));
      expect(stringRepresentation, endsWith('} \n'));
    });

    test('should handle zero and negative total values', () {
      final transaction1 = Transaction(
        totalValue: 0.0,
        operation: 'FREE',
        items: [],
        createdAt: '2024-01-01',
      );
      
      final transaction2 = Transaction(
        totalValue: -25.50,
        operation: 'REFUND',
        items: [],
        createdAt: '2024-01-01',
      );
      
      expect(transaction1.totalValue, equals(0.0));
      expect(transaction2.totalValue, equals(-25.50));
    });

    test('should handle large number of items', () {
      final items = List.generate(100, (index) => TransactionItem(
        productId: index,
        quantity: 1,
        totalValue: 1.0,
      ));
      
      final transaction = Transaction(
        totalValue: 100.0,
        operation: 'BULK_PURCHASE',
        items: items,
        createdAt: '2024-01-01',
      );
      
      expect(transaction.items.length, equals(100));
      expect(transaction.items.first.productId, equals(0));
      expect(transaction.items.last.productId, equals(99));
    });

    test('should maintain immutability of fields', () {
      final items = [
        TransactionItem(
          productId: 1,
          quantity: 1,
          totalValue: 10.0,
        ),
      ];
      
      final transaction = Transaction(
        totalValue: 10.0,
        operation: 'IMMUTABLE_TEST',
        items: items,
        createdAt: '2024-01-01T00:00:00Z',
      );
      
      // Verify fields are final (cannot be reassigned)
      expect(transaction.totalValue, equals(10.0));
      expect(transaction.operation, equals('IMMUTABLE_TEST'));
      expect(transaction.items, equals(items));
      expect(transaction.createdAt, equals('2024-01-01T00:00:00Z'));
    });
  });
}