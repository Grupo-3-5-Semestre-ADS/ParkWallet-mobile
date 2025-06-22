import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/models/product.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/pages/stores/controllers/store_detail_controller.dart';
import 'package:park_wallet/repositories/store_repository.dart';

import 'store_detail_controller_test.mocks.dart';

@GenerateMocks([StoreRepository])
void main() {
  group('StoreDetailController Tests', () {
    late StoreDetailController storeDetailController;
    late MockStoreRepository mockStoreRepository;
    late Store testStore;

    setUp(() {
      Get.testMode = true;
      mockStoreRepository = MockStoreRepository();
      
      testStore = Store(
        id: 1,
        name: 'Test Store',
        description: 'Test Description',
        type: 'restaurant',
        imageUrl: 'https://example.com/image.jpg',
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Test Address',
        phone: '11999999999',
        email: 'test@store.com',
        website: 'https://teststore.com',
        openingHours: '09:00-18:00',
        rating: 4.5,
        reviewCount: 100,
      );
      
      // Set up Get.arguments
      Get.arguments = testStore;
      
      storeDetailController = StoreDetailController();
      storeDetailController.storeRepository = mockStoreRepository;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with store from Get.arguments', () {
        expect(storeDetailController.store.value, equals(testStore));
        expect(storeDetailController.products, isEmpty);
        expect(storeDetailController.isLoading.value, isTrue);
      });

      test('should load store details and products on init for regular store', () async {
        // Arrange
        final updatedStore = Store(
          id: 1,
          name: 'Updated Test Store',
          description: 'Updated Description',
          type: 'restaurant',
          imageUrl: 'https://example.com/updated.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Updated Address',
          phone: '11888888888',
          email: 'updated@store.com',
          website: 'https://updatedstore.com',
          openingHours: '08:00-20:00',
          rating: 4.8,
          reviewCount: 150,
        );
        
        final testProducts = [
          Product(
            id: 1,
            name: 'Product 1',
            description: 'Description 1',
            price: 10.0,
            imageUrl: 'https://example.com/product1.jpg',
            category: 'Food',
            isAvailable: true,
            storeId: 1,
          ),
          Product(
            id: 2,
            name: 'Product 2',
            description: 'Description 2',
            price: 15.0,
            imageUrl: 'https://example.com/product2.jpg',
            category: 'Drink',
            isAvailable: true,
            storeId: 1,
          ),
        ];
        
        when(mockStoreRepository.fetchStoreById(1))
            .thenAnswer((_) async => updatedStore);
        when(mockStoreRepository.fetchStoreProducts(1))
            .thenAnswer((_) async => testProducts);
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(1)).called(1);
        verify(mockStoreRepository.fetchStoreProducts(1)).called(1);
        expect(storeDetailController.store.value, equals(updatedStore));
        expect(storeDetailController.products.length, equals(2));
        expect(storeDetailController.isLoading.value, isFalse);
      });

      test('should not load products for attraction type stores', () async {
        // Arrange
        final attractionStore = Store(
          id: 2,
          name: 'Test Attraction',
          description: 'Test Attraction Description',
          type: 'atracao',
          imageUrl: 'https://example.com/attraction.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Attraction Address',
          phone: '11777777777',
          email: 'attraction@test.com',
          website: 'https://attraction.com',
          openingHours: '10:00-17:00',
          rating: 4.2,
          reviewCount: 80,
        );
        
        Get.arguments = attractionStore;
        storeDetailController = StoreDetailController();
        storeDetailController.storeRepository = mockStoreRepository;
        
        when(mockStoreRepository.fetchStoreById(2))
            .thenAnswer((_) async => attractionStore);
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(2)).called(1);
        verifyNever(mockStoreRepository.fetchStoreProducts(any));
        expect(storeDetailController.products, isEmpty);
      });

      test('should not load products for different attraction type variations', () async {
        final attractionTypes = ['atracao', 'atração', 'attraction', 'other', 'outro'];
        
        for (final type in attractionTypes) {
          // Arrange
          final attractionStore = Store(
            id: 3,
            name: 'Test $type',
            description: 'Test Description',
            type: type,
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Test Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://teststore.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          );
          
          Get.arguments = attractionStore;
          final controller = StoreDetailController();
          controller.storeRepository = mockStoreRepository;
          
          when(mockStoreRepository.fetchStoreById(3))
              .thenAnswer((_) async => attractionStore);
          
          // Act
          controller.onInit();
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Assert
          verify(mockStoreRepository.fetchStoreById(3)).called(1);
          verifyNever(mockStoreRepository.fetchStoreProducts(any));
          expect(controller.products, isEmpty);
          
          // Reset for next iteration
          reset(mockStoreRepository);
        }
      });
    });

    group('Error Handling Tests', () {
      test('should handle store detail fetch error', () async {
        // Arrange
        when(mockStoreRepository.fetchStoreById(1))
            .thenThrow(Exception('Failed to fetch store'));
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(1)).called(1);
        expect(storeDetailController.isLoading.value, isFalse);
      });

      test('should handle products fetch error', () async {
        // Arrange
        final updatedStore = Store(
          id: 1,
          name: 'Updated Test Store',
          description: 'Updated Description',
          type: 'restaurant',
          imageUrl: 'https://example.com/updated.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Updated Address',
          phone: '11888888888',
          email: 'updated@store.com',
          website: 'https://updatedstore.com',
          openingHours: '08:00-20:00',
          rating: 4.8,
          reviewCount: 150,
        );
        
        when(mockStoreRepository.fetchStoreById(1))
            .thenAnswer((_) async => updatedStore);
        when(mockStoreRepository.fetchStoreProducts(1))
            .thenThrow(Exception('Failed to fetch products'));
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(1)).called(1);
        verify(mockStoreRepository.fetchStoreProducts(1)).called(1);
        expect(storeDetailController.store.value, equals(updatedStore));
        expect(storeDetailController.isLoading.value, isFalse);
      });

      test('should handle network timeout error', () async {
        // Arrange
        when(mockStoreRepository.fetchStoreById(1))
            .thenThrow(Exception('Network timeout'));
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(1)).called(1);
        expect(storeDetailController.isLoading.value, isFalse);
      });

      test('should handle invalid store ID error', () async {
        // Arrange
        when(mockStoreRepository.fetchStoreById(1))
            .thenThrow(Exception('Store not found'));
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(1)).called(1);
        expect(storeDetailController.isLoading.value, isFalse);
      });
    });

    group('Store Type Handling Tests', () {
      test('should handle case-insensitive store types', () async {
        final caseVariations = [
          'ATRACAO', 'Atracao', 'ATRAÇÃO', 'Atração',
          'ATTRACTION', 'Attraction', 'OTHER', 'Other',
          'OUTRO', 'Outro'
        ];
        
        for (final type in caseVariations) {
          // Arrange
          final attractionStore = Store(
            id: 4,
            name: 'Test Store',
            description: 'Test Description',
            type: type,
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Test Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://teststore.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          );
          
          Get.arguments = attractionStore;
          final controller = StoreDetailController();
          controller.storeRepository = mockStoreRepository;
          
          when(mockStoreRepository.fetchStoreById(4))
              .thenAnswer((_) async => attractionStore);
          
          // Act
          controller.onInit();
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Assert
          verify(mockStoreRepository.fetchStoreById(4)).called(1);
          verifyNever(mockStoreRepository.fetchStoreProducts(any));
          expect(controller.products, isEmpty);
          
          // Reset for next iteration
          reset(mockStoreRepository);
        }
      });

      test('should load products for non-attraction store types', () async {
        final regularTypes = ['restaurant', 'shop', 'cafe', 'market', 'pharmacy'];
        
        for (final type in regularTypes) {
          // Arrange
          final regularStore = Store(
            id: 5,
            name: 'Test Store',
            description: 'Test Description',
            type: type,
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Test Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://teststore.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          );
          
          final testProducts = [
            Product(
              id: 1,
              name: 'Product 1',
              description: 'Description 1',
              price: 10.0,
              imageUrl: 'https://example.com/product1.jpg',
              category: 'Category',
              isAvailable: true,
              storeId: 5,
            ),
          ];
          
          Get.arguments = regularStore;
          final controller = StoreDetailController();
          controller.storeRepository = mockStoreRepository;
          
          when(mockStoreRepository.fetchStoreById(5))
              .thenAnswer((_) async => regularStore);
          when(mockStoreRepository.fetchStoreProducts(5))
              .thenAnswer((_) async => testProducts);
          
          // Act
          controller.onInit();
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Assert
          verify(mockStoreRepository.fetchStoreById(5)).called(1);
          verify(mockStoreRepository.fetchStoreProducts(5)).called(1);
          expect(controller.products.length, equals(1));
          
          // Reset for next iteration
          reset(mockStoreRepository);
        }
      });
    });

    group('Products Management Tests', () {
      test('should clear products for attraction stores', () async {
        // Arrange
        final attractionStore = Store(
          id: 6,
          name: 'Test Attraction',
          description: 'Test Description',
          type: 'atracao',
          imageUrl: 'https://example.com/image.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Test Address',
          phone: '11999999999',
          email: 'test@store.com',
          website: 'https://teststore.com',
          openingHours: '09:00-18:00',
          rating: 4.5,
          reviewCount: 100,
        );
        
        Get.arguments = attractionStore;
        storeDetailController = StoreDetailController();
        storeDetailController.storeRepository = mockStoreRepository;
        
        // Add some initial products
        storeDetailController.products.add(Product(
          id: 1,
          name: 'Initial Product',
          description: 'Description',
          price: 10.0,
          imageUrl: 'https://example.com/product.jpg',
          category: 'Category',
          isAvailable: true,
          storeId: 6,
        ));
        
        when(mockStoreRepository.fetchStoreById(6))
            .thenAnswer((_) async => attractionStore);
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(storeDetailController.products, isEmpty);
      });

      test('should handle empty products list', () async {
        // Arrange
        final updatedStore = Store(
          id: 7,
          name: 'Empty Store',
          description: 'Store with no products',
          type: 'restaurant',
          imageUrl: 'https://example.com/image.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Test Address',
          phone: '11999999999',
          email: 'test@store.com',
          website: 'https://teststore.com',
          openingHours: '09:00-18:00',
          rating: 4.5,
          reviewCount: 100,
        );
        
        Get.arguments = updatedStore;
        storeDetailController = StoreDetailController();
        storeDetailController.storeRepository = mockStoreRepository;
        
        when(mockStoreRepository.fetchStoreById(7))
            .thenAnswer((_) async => updatedStore);
        when(mockStoreRepository.fetchStoreProducts(7))
            .thenAnswer((_) async => <Product>[]);
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(7)).called(1);
        verify(mockStoreRepository.fetchStoreProducts(7)).called(1);
        expect(storeDetailController.products, isEmpty);
        expect(storeDetailController.isLoading.value, isFalse);
      });

      test('should handle large number of products', () async {
        // Arrange
        final updatedStore = Store(
          id: 8,
          name: 'Large Store',
          description: 'Store with many products',
          type: 'market',
          imageUrl: 'https://example.com/image.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Test Address',
          phone: '11999999999',
          email: 'test@store.com',
          website: 'https://teststore.com',
          openingHours: '09:00-18:00',
          rating: 4.5,
          reviewCount: 100,
        );
        
        final manyProducts = List.generate(100, (index) => Product(
          id: index + 1,
          name: 'Product ${index + 1}',
          description: 'Description ${index + 1}',
          price: (index + 1) * 5.0,
          imageUrl: 'https://example.com/product${index + 1}.jpg',
          category: 'Category ${(index % 5) + 1}',
          isAvailable: index % 2 == 0,
          storeId: 8,
        ));
        
        Get.arguments = updatedStore;
        storeDetailController = StoreDetailController();
        storeDetailController.storeRepository = mockStoreRepository;
        
        when(mockStoreRepository.fetchStoreById(8))
            .thenAnswer((_) async => updatedStore);
        when(mockStoreRepository.fetchStoreProducts(8))
            .thenAnswer((_) async => manyProducts);
        
        // Act
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStoreById(8)).called(1);
        verify(mockStoreRepository.fetchStoreProducts(8)).called(1);
        expect(storeDetailController.products.length, equals(100));
        expect(storeDetailController.isLoading.value, isFalse);
      });
    });

    group('Invalid Arguments Tests', () {
      test('should handle null Get.arguments', () {
        // Arrange
        Get.arguments = null;
        
        // Act
        final controller = StoreDetailController();
        controller.storeRepository = mockStoreRepository;
        controller.onInit();
        
        // Assert
        verifyNever(mockStoreRepository.fetchStoreById(any));
        verifyNever(mockStoreRepository.fetchStoreProducts(any));
      });

      test('should handle invalid Get.arguments type', () {
        // Arrange
        Get.arguments = 'invalid_argument';
        
        // Act
        final controller = StoreDetailController();
        controller.storeRepository = mockStoreRepository;
        controller.onInit();
        
        // Assert
        verifyNever(mockStoreRepository.fetchStoreById(any));
        verifyNever(mockStoreRepository.fetchStoreProducts(any));
      });
    });

    group('Loading State Tests', () {
      test('should set loading to false after successful load', () async {
        // Arrange
        final updatedStore = Store(
          id: 9,
          name: 'Test Store',
          description: 'Test Description',
          type: 'restaurant',
          imageUrl: 'https://example.com/image.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Test Address',
          phone: '11999999999',
          email: 'test@store.com',
          website: 'https://teststore.com',
          openingHours: '09:00-18:00',
          rating: 4.5,
          reviewCount: 100,
        );
        
        Get.arguments = updatedStore;
        storeDetailController = StoreDetailController();
        storeDetailController.storeRepository = mockStoreRepository;
        
        when(mockStoreRepository.fetchStoreById(9))
            .thenAnswer((_) async => updatedStore);
        when(mockStoreRepository.fetchStoreProducts(9))
            .thenAnswer((_) async => <Product>[]);
        
        // Act
        expect(storeDetailController.isLoading.value, isTrue);
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(storeDetailController.isLoading.value, isFalse);
      });

      test('should set loading to false after error', () async {
        // Arrange
        when(mockStoreRepository.fetchStoreById(1))
            .thenThrow(Exception('Error'));
        
        // Act
        expect(storeDetailController.isLoading.value, isTrue);
        storeDetailController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(storeDetailController.isLoading.value, isFalse);
      });
    });
  });
}