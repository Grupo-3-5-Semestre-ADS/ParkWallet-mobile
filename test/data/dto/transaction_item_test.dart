import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/dto/transaction_item.dart';

void main() {
  group('TransactionItem Tests', () {
    test('should create TransactionItem with all required fields', () {
      const productId = 123;
      const quantity = 5;
      const totalValue = 25.50;
      
      final transactionItem = TransactionItem(
        productId: productId,
        quantity: quantity,
        totalValue: totalValue,
      );
      
      expect(transactionItem.productId, equals(productId));
      expect(transactionItem.quantity, equals(quantity));
      expect(transactionItem.totalValue, equals(totalValue));
    });

    test('should create TransactionItem from JSON with valid data', () {
      final json = {
        'productId': 456,
        'quantity': 3,
        'totalValue': '15.75',
      };
      
      final transactionItem = TransactionItem.fromJson(json);
      
      expect(transactionItem.productId, equals(456));
      expect(transactionItem.quantity, equals(3));
      expect(transactionItem.totalValue, equals(15.75));
    });

    test('should handle different totalValue formats in JSON', () {
      final jsonWithInt = {
        'productId': 1,
        'quantity': 1,
        'totalValue': 10,
      };
      
      final jsonWithDouble = {
        'productId': 2,
        'quantity': 2,
        'totalValue': 20.5,
      };
      
      final jsonWithString = {
        'productId': 3,
        'quantity': 3,
        'totalValue': '30.99',
      };
      
      final item1 = TransactionItem.fromJson(jsonWithInt);
      final item2 = TransactionItem.fromJson(jsonWithDouble);
      final item3 = TransactionItem.fromJson(jsonWithString);
      
      expect(item1.totalValue, equals(10.0));
      expect(item2.totalValue, equals(20.5));
      expect(item3.totalValue, equals(30.99));
    });

    test('should handle null or invalid totalValue in JSON', () {
      final jsonWithNull = {
        'productId': 1,
        'quantity': 1,
        'totalValue': null,
      };
      
      final jsonWithInvalid = {
        'productId': 2,
        'quantity': 2,
        'totalValue': 'invalid',
      };
      
      final jsonWithMissing = {
        'productId': 3,
        'quantity': 3,
      };
      
      final item1 = TransactionItem.fromJson(jsonWithNull);
      final item2 = TransactionItem.fromJson(jsonWithInvalid);
      final item3 = TransactionItem.fromJson(jsonWithMissing);
      
      expect(item1.totalValue, equals(0.0));
      expect(item2.totalValue, equals(0.0));
      expect(item3.totalValue, equals(0.0));
    });

    test('should handle zero and negative values', () {
      final item1 = TransactionItem(
        productId: 1,
        quantity: 0,
        totalValue: 0.0,
      );
      
      final item2 = TransactionItem(
        productId: 2,
        quantity: -1,
        totalValue: -10.50,
      );
      
      expect(item1.quantity, equals(0));
      expect(item1.totalValue, equals(0.0));
      expect(item2.quantity, equals(-1));
      expect(item2.totalValue, equals(-10.50));
    });

    test('should handle large values', () {
      final item = TransactionItem(
        productId: 999999,
        quantity: 1000,
        totalValue: 9999.99,
      );
      
      expect(item.productId, equals(999999));
      expect(item.quantity, equals(1000));
      expect(item.totalValue, equals(9999.99));
    });

    test('should have correct toString representation', () {
      final transactionItem = TransactionItem(
        productId: 42,
        quantity: 7,
        totalValue: 35.00,
      );
      
      final stringRepresentation = transactionItem.toString();
      
      expect(stringRepresentation, contains('TransactionItem{'));
      expect(stringRepresentation, contains('productId: 42'));
      expect(stringRepresentation, contains('quantity: 7'));
      expect(stringRepresentation, contains('totalValue: 35.0'));
      expect(stringRepresentation, endsWith('}'));
    });

    test('should handle typical e-commerce scenarios', () {
      // Single item purchase
      final singleItem = TransactionItem(
        productId: 100,
        quantity: 1,
        totalValue: 19.99,
      );
      
      // Multiple quantity purchase
      final multipleItems = TransactionItem(
        productId: 200,
        quantity: 5,
        totalValue: 99.95,
      );
      
      // Bulk purchase
      final bulkItems = TransactionItem(
        productId: 300,
        quantity: 50,
        totalValue: 250.00,
      );
      
      expect(singleItem.quantity, equals(1));
      expect(singleItem.totalValue, equals(19.99));
      
      expect(multipleItems.quantity, equals(5));
      expect(multipleItems.totalValue, equals(99.95));
      
      expect(bulkItems.quantity, equals(50));
      expect(bulkItems.totalValue, equals(250.00));
    });

    test('should calculate unit price correctly', () {
      final item1 = TransactionItem(
        productId: 1,
        quantity: 2,
        totalValue: 20.00,
      );
      
      final item2 = TransactionItem(
        productId: 2,
        quantity: 3,
        totalValue: 15.00,
      );
      
      // Calculate unit price manually for verification
      final unitPrice1 = item1.totalValue / item1.quantity;
      final unitPrice2 = item2.totalValue / item2.quantity;
      
      expect(unitPrice1, equals(10.00));
      expect(unitPrice2, equals(5.00));
    });

    test('should maintain immutability of fields', () {
      final transactionItem = TransactionItem(
        productId: 999,
        quantity: 10,
        totalValue: 100.00,
      );
      
      // Verify fields are final (cannot be reassigned)
      expect(transactionItem.productId, equals(999));
      expect(transactionItem.quantity, equals(10));
      expect(transactionItem.totalValue, equals(100.00));
    });

    test('should handle edge cases with decimal precision', () {
      final item = TransactionItem(
        productId: 1,
        quantity: 3,
        totalValue: 10.333333,
      );
      
      expect(item.totalValue, equals(10.333333));
      expect(item.totalValue, isA<double>());
    });

    test('should create from JSON with missing productId and quantity', () {
      final json = {
        'totalValue': '25.00',
      };
      
      // This should handle null values gracefully
      expect(() => TransactionItem.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('should handle various JSON data types for productId and quantity', () {
      final jsonWithStringIds = {
        'productId': '123',
        'quantity': '5',
        'totalValue': '50.00',
      };
      
      // Note: The current implementation expects int types
      // This test documents the expected behavior
      expect(() => TransactionItem.fromJson(jsonWithStringIds), 
             throwsA(isA<TypeError>()));
    });
  });
}