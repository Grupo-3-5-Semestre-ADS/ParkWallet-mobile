import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/models/product.dart';

void main() {
  group('Product Tests', () {
    test('should create Product with required fields', () {
      const id = '1';
      const name = 'Test Product';
      const price = 10.99;
      const storeId = 'store123';
      
      final product = Product(
        id: id,
        name: name,
        price: price,
        storeId: storeId,
      );
      
      expect(product.id, equals(id));
      expect(product.name, equals(name));
      expect(product.price, equals(price));
      expect(product.storeId, equals(storeId));
      expect(product.image, isNull);
      expect(product.description, isNull);
    });

    test('should create Product with all fields', () {
      const id = '2';
      const name = 'Complete Product';
      const price = 25.50;
      const storeId = 'store456';
      const image = 'https://example.com/image.jpg';
      const description = 'A complete product description';
      
      final product = Product(
        id: id,
        name: name,
        price: price,
        storeId: storeId,
        image: image,
        description: description,
      );
      
      expect(product.id, equals(id));
      expect(product.name, equals(name));
      expect(product.price, equals(price));
      expect(product.storeId, equals(storeId));
      expect(product.image, equals(image));
      expect(product.description, equals(description));
    });

    test('should create Product from JSON with all fields', () {
      final json = {
        'id': 123,
        'name': 'JSON Product',
        'price': '15.75',
        'storeId': 'jsonStore',
        'image': 'https://example.com/json-image.jpg',
        'description': 'Product from JSON',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.id, equals('123'));
      expect(product.name, equals('JSON Product'));
      expect(product.price, equals(15.75));
      expect(product.storeId, equals('jsonStore'));
      expect(product.image, equals('https://example.com/json-image.jpg'));
      expect(product.description, equals('Product from JSON'));
    });

    test('should create Product from JSON with facilityId fallback', () {
      final json = {
        'id': 456,
        'name': 'Facility Product',
        'price': 20.00,
        'facilityId': 'facility789',
        'image': null,
        'description': null,
      };
      
      final product = Product.fromJson(json);
      
      expect(product.id, equals('456'));
      expect(product.name, equals('Facility Product'));
      expect(product.price, equals(20.00));
      expect(product.storeId, equals('facility789'));
      expect(product.image, isNull);
      expect(product.description, isNull);
    });

    test('should handle missing or null values in JSON', () {
      final json = {
        'id': 789,
        'price': '5.99',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.id, equals('789'));
      expect(product.name, equals(''));
      expect(product.price, equals(5.99));
      expect(product.storeId, equals(''));
      expect(product.image, isNull);
      expect(product.description, isNull);
    });

    test('should handle different price formats in JSON', () {
      final jsonWithIntPrice = {
        'id': 1,
        'name': 'Int Price Product',
        'price': 10,
        'storeId': 'store1',
      };
      
      final jsonWithDoublePrice = {
        'id': 2,
        'name': 'Double Price Product',
        'price': 10.5,
        'storeId': 'store2',
      };
      
      final jsonWithStringPrice = {
        'id': 3,
        'name': 'String Price Product',
        'price': '10.99',
        'storeId': 'store3',
      };
      
      final product1 = Product.fromJson(jsonWithIntPrice);
      final product2 = Product.fromJson(jsonWithDoublePrice);
      final product3 = Product.fromJson(jsonWithStringPrice);
      
      expect(product1.price, equals(10.0));
      expect(product2.price, equals(10.5));
      expect(product3.price, equals(10.99));
    });

    test('should handle zero and negative prices', () {
      final product1 = Product(
        id: '1',
        name: 'Free Product',
        price: 0.0,
        storeId: 'store1',
      );
      
      final product2 = Product(
        id: '2',
        name: 'Negative Price Product',
        price: -5.0,
        storeId: 'store2',
      );
      
      expect(product1.price, equals(0.0));
      expect(product2.price, equals(-5.0));
    });

    test('should handle empty strings in constructor', () {
      final product = Product(
        id: '',
        name: '',
        price: 0.0,
        storeId: '',
        image: '',
        description: '',
      );
      
      expect(product.id, equals(''));
      expect(product.name, equals(''));
      expect(product.price, equals(0.0));
      expect(product.storeId, equals(''));
      expect(product.image, equals(''));
      expect(product.description, equals(''));
    });

    test('should prioritize storeId over facilityId in JSON', () {
      final json = {
        'id': 999,
        'name': 'Priority Test',
        'price': '1.00',
        'storeId': 'primaryStore',
        'facilityId': 'fallbackFacility',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.storeId, equals('primaryStore'));
    });
  });
}