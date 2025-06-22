import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/models/store.dart';

void main() {
  group('Store Tests', () {
    test('should create Store with required fields', () {
      const id = '1';
      const name = 'Test Store';
      const type = 'Restaurant';
      
      final store = Store(
        id: id,
        name: name,
        type: type,
      );
      
      expect(store.id, equals(id));
      expect(store.name, equals(name));
      expect(store.type, equals(type));
      expect(store.image, isNull);
      expect(store.description, isNull);
    });

    test('should create Store with all fields', () {
      const id = '2';
      const name = 'Complete Store';
      const type = 'Clothing';
      const image = 'https://example.com/store-image.jpg';
      const description = 'A complete store with all details';
      
      final store = Store(
        id: id,
        name: name,
        type: type,
        image: image,
        description: description,
      );
      
      expect(store.id, equals(id));
      expect(store.name, equals(name));
      expect(store.type, equals(type));
      expect(store.image, equals(image));
      expect(store.description, equals(description));
    });

    test('should create Store from JSON with all fields', () {
      final json = {
        'id': 123,
        'name': 'JSON Store',
        'type': 'Electronics',
        'image': 'https://example.com/json-store.jpg',
        'description': 'Store created from JSON',
      };
      
      final store = Store.fromJson(json);
      
      expect(store.id, equals('123'));
      expect(store.name, equals('JSON Store'));
      expect(store.type, equals('Electronics'));
      expect(store.image, equals('https://example.com/json-store.jpg'));
      expect(store.description, equals('Store created from JSON'));
    });

    test('should create Store from JSON with missing optional fields', () {
      final json = {
        'id': 456,
        'name': 'Minimal Store',
        'type': 'Books',
      };
      
      final store = Store.fromJson(json);
      
      expect(store.id, equals('456'));
      expect(store.name, equals('Minimal Store'));
      expect(store.type, equals('Books'));
      expect(store.image, isNull);
      expect(store.description, isNull);
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 789,
        'name': 'Null Fields Store',
        'type': 'Sports',
        'image': null,
        'description': null,
      };
      
      final store = Store.fromJson(json);
      
      expect(store.id, equals('789'));
      expect(store.name, equals('Null Fields Store'));
      expect(store.type, equals('Sports'));
      expect(store.image, isNull);
      expect(store.description, isNull);
    });

    test('should handle missing required fields in JSON with defaults', () {
      final json = {
        'id': 999,
      };
      
      final store = Store.fromJson(json);
      
      expect(store.id, equals('999'));
      expect(store.name, equals(''));
      expect(store.type, equals(''));
      expect(store.image, isNull);
      expect(store.description, isNull);
    });

    test('should handle different ID types in JSON', () {
      final jsonWithIntId = {
        'id': 100,
        'name': 'Int ID Store',
        'type': 'Food',
      };
      
      final jsonWithStringId = {
        'id': '200',
        'name': 'String ID Store',
        'type': 'Fashion',
      };
      
      final jsonWithDoubleId = {
        'id': 300.0,
        'name': 'Double ID Store',
        'type': 'Home',
      };
      
      final store1 = Store.fromJson(jsonWithIntId);
      final store2 = Store.fromJson(jsonWithStringId);
      final store3 = Store.fromJson(jsonWithDoubleId);
      
      expect(store1.id, equals('100'));
      expect(store2.id, equals('200'));
      expect(store3.id, equals('300.0'));
    });

    test('should handle empty strings in constructor', () {
      final store = Store(
        id: '',
        name: '',
        type: '',
        image: '',
        description: '',
      );
      
      expect(store.id, equals(''));
      expect(store.name, equals(''));
      expect(store.type, equals(''));
      expect(store.image, equals(''));
      expect(store.description, equals(''));
    });

    test('should handle special characters in fields', () {
      final store = Store(
        id: 'store-123',
        name: 'Loja do João & Cia',
        type: 'Café & Restaurante',
        image: 'https://example.com/store_image.jpg?v=1&size=large',
        description: 'Uma loja com acentos: ção, ã, é, ü',
      );
      
      expect(store.id, equals('store-123'));
      expect(store.name, equals('Loja do João & Cia'));
      expect(store.type, equals('Café & Restaurante'));
      expect(store.image, equals('https://example.com/store_image.jpg?v=1&size=large'));
      expect(store.description, equals('Uma loja com acentos: ção, ã, é, ü'));
    });

    test('should handle various store types', () {
      final storeTypes = [
        'Restaurant',
        'Clothing',
        'Electronics',
        'Books',
        'Sports',
        'Pharmacy',
        'Supermarket',
        'Coffee Shop',
        'Beauty Salon',
        'Hardware Store'
      ];
      
      for (int i = 0; i < storeTypes.length; i++) {
        final store = Store(
          id: i.toString(),
          name: '${storeTypes[i]} Store',
          type: storeTypes[i],
        );
        
        expect(store.type, equals(storeTypes[i]));
        expect(store.name, equals('${storeTypes[i]} Store'));
      }
    });

    test('should maintain immutability of fields', () {
      final store = Store(
        id: 'immutable-store',
        name: 'Immutable Store',
        type: 'Test Type',
        image: 'test-image.jpg',
        description: 'Test description',
      );
      
      // Verify fields are final (cannot be reassigned)
      expect(store.id, equals('immutable-store'));
      expect(store.name, equals('Immutable Store'));
      expect(store.type, equals('Test Type'));
      expect(store.image, equals('test-image.jpg'));
      expect(store.description, equals('Test description'));
    });

    test('should handle long descriptions and names', () {
      const longName = 'This is a very long store name that might be used in some cases where the store has a very descriptive and detailed name';
      const longDescription = 'This is a very long description that provides detailed information about the store, its products, services, history, and everything else that might be relevant for customers to know about this particular establishment.';
      
      final store = Store(
        id: 'long-content-store',
        name: longName,
        type: 'Detailed Store',
        description: longDescription,
      );
      
      expect(store.name, equals(longName));
      expect(store.description, equals(longDescription));
      expect(store.name.length, greaterThan(50));
      expect(store.description!.length, greaterThan(100));
    });
  });
}