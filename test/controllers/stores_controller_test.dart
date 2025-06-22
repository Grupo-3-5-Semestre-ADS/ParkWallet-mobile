import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/pages/stores/controllers/store_detail_controller.dart';
import 'package:park_wallet/pages/stores/controllers/stores_controller.dart';
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/routes/app_pages.dart';

import 'stores_controller_test.mocks.dart';

@GenerateMocks([StoreRepository])
void main() {
  group('StoresController Tests', () {
    late StoresController storesController;
    late MockStoreRepository mockStoreRepository;
    late List<Store> testStores;

    setUp(() {
      Get.testMode = true;
      mockStoreRepository = MockStoreRepository();
      
      testStores = [
        Store(
          id: 1,
          name: 'Test Store 1',
          description: 'Test Description 1',
          type: 'store',
          imageUrl: 'https://example.com/store1.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Test Address 1',
          phone: '11999999999',
          email: 'store1@test.com',
          website: 'https://store1.com',
          openingHours: '09:00-18:00',
          rating: 4.5,
          reviewCount: 100,
        ),
        Store(
          id: 2,
          name: 'Test Store 2',
          description: 'Test Description 2',
          type: 'store',
          imageUrl: 'https://example.com/store2.jpg',
          latitude: -23.5515,
          longitude: -46.6343,
          address: 'Test Address 2',
          phone: '11888888888',
          email: 'store2@test.com',
          website: 'https://store2.com',
          openingHours: '08:00-20:00',
          rating: 4.2,
          reviewCount: 80,
        ),
        Store(
          id: 3,
          name: 'Test Restaurant',
          description: 'Test Restaurant Description',
          type: 'restaurant',
          imageUrl: 'https://example.com/restaurant.jpg',
          latitude: -23.5525,
          longitude: -46.6353,
          address: 'Restaurant Address',
          phone: '11777777777',
          email: 'restaurant@test.com',
          website: 'https://restaurant.com',
          openingHours: '11:00-23:00',
          rating: 4.8,
          reviewCount: 200,
        ),
      ];
      
      storesController = StoresController();
      storesController.storeRepository = mockStoreRepository;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(storesController.filteredStores, isEmpty);
        expect(storesController.searchQuery.value, isEmpty);
        expect(storesController.isLoading.value, isTrue);
      });

      test('should fetch stores on init and filter only store type', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => testStores);
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStores(page: 1, limit: 100)).called(1);
        expect(storesController.filteredStores.length, equals(2)); // Only stores, not restaurant
        expect(storesController.filteredStores[0].type, equals('store'));
        expect(storesController.filteredStores[1].type, equals('store'));
        expect(storesController.isLoading.value, isFalse);
      });

      test('should handle empty stores list on init', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => <Store>[]);
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStores(page: 1, limit: 100)).called(1);
        expect(storesController.filteredStores, isEmpty);
        expect(storesController.isLoading.value, isFalse);
      });

      test('should handle fetch error on init', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenThrow(Exception('Network error'));
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStores(page: 1, limit: 100)).called(1);
        expect(storesController.filteredStores, isEmpty);
        expect(storesController.isLoading.value, isFalse);
      });
    });

    group('Store Filtering Tests', () {
      test('should filter stores by type correctly', () async {
        // Arrange
        final mixedStores = [
          ...testStores,
          Store(
            id: 4,
            name: 'Test Attraction',
            description: 'Test Attraction Description',
            type: 'attraction',
            imageUrl: 'https://example.com/attraction.jpg',
            latitude: -23.5535,
            longitude: -46.6363,
            address: 'Attraction Address',
            phone: '11666666666',
            email: 'attraction@test.com',
            website: 'https://attraction.com',
            openingHours: '10:00-17:00',
            rating: 4.0,
            reviewCount: 50,
          ),
        ];
        
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => mixedStores);
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(storesController.filteredStores.length, equals(2)); // Only stores
        expect(storesController.filteredStores.every((s) => s.type == 'store'), isTrue);
      });

      test('should handle case-insensitive store type filtering', () async {
        // Arrange
        final caseVariationStores = [
          Store(
            id: 5,
            name: 'Store 1',
            description: 'Description',
            type: 'STORE',
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://store.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          ),
          Store(
            id: 6,
            name: 'Store 2',
            description: 'Description',
            type: 'Store',
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://store.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          ),
          Store(
            id: 7,
            name: 'Restaurant',
            description: 'Description',
            type: 'RESTAURANT',
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://store.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          ),
        ];
        
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => caseVariationStores);
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(storesController.filteredStores.length, equals(2)); // Only stores
        expect(storesController.filteredStores.every((s) => s.type?.toLowerCase() == 'store'), isTrue);
      });
    });

    group('Search Functionality Tests', () {
      setUp(() async {
        when(mockStoreRepository.fetchStores(page: any, limit: any))
            .thenAnswer((_) async => testStores.where((s) => s.type == 'store').toList());
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should filter stores by name', () async {
        // Act
        storesController.updateSearch('Store 1');
        await Future.delayed(const Duration(milliseconds: 400)); // Wait for debounce
        
        // Assert
        expect(storesController.filteredStores.length, equals(1));
        expect(storesController.filteredStores.first.name, contains('Store 1'));
      });

      test('should filter stores by partial name match', () async {
        // Act
        storesController.updateSearch('Test');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(storesController.filteredStores.length, equals(2));
        expect(storesController.filteredStores.every((s) => s.name.contains('Test')), isTrue);
      });

      test('should filter stores by type', () async {
        // Act
        storesController.updateSearch('store');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(storesController.filteredStores.length, equals(2));
        expect(storesController.filteredStores.every((s) => s.type == 'store'), isTrue);
      });

      test('should handle case-insensitive search', () async {
        // Act
        storesController.updateSearch('STORE 1');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(storesController.filteredStores.length, equals(1));
        expect(storesController.filteredStores.first.name, contains('Store 1'));
      });

      test('should return empty list for no matches', () async {
        // Act
        storesController.updateSearch('NonExistent');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(storesController.filteredStores, isEmpty);
      });

      test('should return all stores when search is empty', () async {
        // Arrange - first set a search
        storesController.updateSearch('Store 1');
        await Future.delayed(const Duration(milliseconds: 400));
        expect(storesController.filteredStores.length, equals(1));
        
        // Act - clear search
        storesController.updateSearch('');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(storesController.filteredStores.length, equals(2));
      });

      test('should handle special characters in search', () async {
        // Arrange
        final specialStore = Store(
          id: 8,
          name: 'Store & Co.',
          description: 'Special store',
          type: 'store',
          imageUrl: 'https://example.com/image.jpg',
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Address',
          phone: '11999999999',
          email: 'test@store.com',
          website: 'https://store.com',
          openingHours: '09:00-18:00',
          rating: 4.5,
          reviewCount: 100,
        );
        
        when(mockStoreRepository.fetchStores(page: any, limit: any))
            .thenAnswer((_) async => [specialStore]);
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        storesController.updateSearch('&');
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert
        expect(storesController.filteredStores.length, equals(1));
        expect(storesController.filteredStores.first.name, contains('&'));
      });
    });

    group('Pagination Tests', () {
      test('should load more stores when requested', () async {
        // Arrange
        final firstPageStores = testStores.where((s) => s.type == 'store').take(2).toList();
        final secondPageStores = [
          Store(
            id: 9,
            name: 'Store 3',
            description: 'Description 3',
            type: 'store',
            imageUrl: 'https://example.com/store3.jpg',
            latitude: -23.5545,
            longitude: -46.6373,
            address: 'Address 3',
            phone: '11555555555',
            email: 'store3@test.com',
            website: 'https://store3.com',
            openingHours: '07:00-19:00',
            rating: 4.3,
            reviewCount: 60,
          ),
        ];
        
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => firstPageStores);
        when(mockStoreRepository.fetchStores(page: 2, limit: 100))
            .thenAnswer((_) async => secondPageStores);
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(storesController.filteredStores.length, equals(2));
        
        // Act
        storesController.loadMoreStores();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStores(page: 2, limit: 100)).called(1);
        expect(storesController.filteredStores.length, equals(3));
      });

      test('should not load more when no more stores available', () async {
        // Arrange
        final limitedStores = testStores.where((s) => s.type == 'store').take(50).toList(); // Less than limit
        
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => limitedStores);
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        storesController.loadMoreStores();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verifyNever(mockStoreRepository.fetchStores(page: 2, limit: 100));
      });

      test('should handle pagination error', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => testStores.where((s) => s.type == 'store').toList());
        when(mockStoreRepository.fetchStores(page: 2, limit: 100))
            .thenThrow(Exception('Pagination error'));
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        storesController.loadMoreStores();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.fetchStores(page: 2, limit: 100)).called(1);
        expect(storesController.isLoading.value, isFalse);
      });

      test('should prevent concurrent fetch operations', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: any, limit: any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return testStores.where((s) => s.type == 'store').toList();
        });
        
        storesController.onInit();
        
        // Act - try to load more before first load completes
        storesController.loadMoreStores();
        storesController.loadMoreStores();
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert - should only call once for init and once for first loadMore
        verify(mockStoreRepository.fetchStores(page: 1, limit: 100)).called(1);
        verify(mockStoreRepository.fetchStores(page: 2, limit: 100)).called(1);
      });
    });

    group('Navigation Tests', () {
      test('should navigate to store detail', () {
        // Arrange
        final store = testStores.first;
        
        // Act
        storesController.navigateToStoreDetail(store);
        
        // Assert
        expect(Get.currentRoute, equals(Routes.STORE_DETAIL));
        expect(Get.arguments, equals(store));
      });

      test('should clean up previous StoreDetailController before navigation', () {
        // Arrange
        final store = testStores.first;
        Get.put(StoreDetailController()); // Register a controller
        
        expect(Get.isRegistered<StoreDetailController>(), isTrue);
        
        // Act
        storesController.navigateToStoreDetail(store);
        
        // Assert
        expect(Get.isRegistered<StoreDetailController>(), isFalse);
      });

      test('should handle navigation when no previous controller exists', () {
        // Arrange
        final store = testStores.first;
        expect(Get.isRegistered<StoreDetailController>(), isFalse);
        
        // Act & Assert - should not throw
        expect(() => storesController.navigateToStoreDetail(store), returnsNormally);
      });
    });

    group('Edge Cases and Integration Tests', () {
      test('should handle stores with null or empty type', () async {
        // Arrange
        final storesWithNullType = [
          Store(
            id: 10,
            name: 'Store with null type',
            description: 'Description',
            type: null,
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://store.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          ),
          Store(
            id: 11,
            name: 'Store with empty type',
            description: 'Description',
            type: '',
            imageUrl: 'https://example.com/image.jpg',
            latitude: -23.5505,
            longitude: -46.6333,
            address: 'Address',
            phone: '11999999999',
            email: 'test@store.com',
            website: 'https://store.com',
            openingHours: '09:00-18:00',
            rating: 4.5,
            reviewCount: 100,
          ),
        ];
        
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => storesWithNullType);
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should handle gracefully
        expect(storesController.filteredStores, isEmpty);
        expect(storesController.isLoading.value, isFalse);
      });

      test('should handle very large store lists', () async {
        // Arrange
        final largeStoreList = List.generate(1000, (index) => Store(
          id: index + 1,
          name: 'Store $index',
          description: 'Description $index',
          type: 'store',
          imageUrl: 'https://example.com/store$index.jpg',
          latitude: -23.5505 + (index * 0.001),
          longitude: -46.6333 + (index * 0.001),
          address: 'Address $index',
          phone: '1199999999$index',
          email: 'store$index@test.com',
          website: 'https://store$index.com',
          openingHours: '09:00-18:00',
          rating: 4.0 + (index % 10) * 0.1,
          reviewCount: 100 + index,
        ));
        
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => largeStoreList.take(100).toList());
        
        // Act
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(storesController.filteredStores.length, equals(100));
        expect(storesController.isLoading.value, isFalse);
      });

      test('should handle rapid search updates', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: any, limit: any))
            .thenAnswer((_) async => testStores.where((s) => s.type == 'store').toList());
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act - rapid search updates
        storesController.updateSearch('S');
        storesController.updateSearch('St');
        storesController.updateSearch('Sto');
        storesController.updateSearch('Store');
        
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Assert - should handle debouncing correctly
        expect(storesController.searchQuery.value, equals('Store'));
        expect(storesController.filteredStores.length, equals(2));
      });

      test('should maintain state consistency during errors', () async {
        // Arrange
        when(mockStoreRepository.fetchStores(page: 1, limit: 100))
            .thenAnswer((_) async => testStores.where((s) => s.type == 'store').toList());
        when(mockStoreRepository.fetchStores(page: 2, limit: 100))
            .thenThrow(Exception('Network error'));
        
        storesController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        final initialCount = storesController.filteredStores.length;
        
        // Act
        storesController.loadMoreStores();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - state should remain consistent
        expect(storesController.filteredStores.length, equals(initialCount));
        expect(storesController.isLoading.value, isFalse);
      });

      test('should handle memory management correctly', () {
        // Arrange
        final controller = StoresController();
        controller.storeRepository = mockStoreRepository;
        
        // Act
        controller.onInit();
        controller.onClose();
        
        // Assert - no memory leaks or exceptions
        expect(controller.isClosed, isTrue);
      });
    });
  });
}