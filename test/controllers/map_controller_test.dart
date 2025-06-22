import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:park_wallet/pages/map/controllers/map_controller.dart';
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/services/map_location_service.dart';
import 'package:park_wallet/services/map_marker_service.dart';
import 'package:park_wallet/services/map_style_service.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/data/models/product.dart';

import 'map_controller_test.mocks.dart';

@GenerateMocks([
  StoreRepository,
  MapLocationService,
  MapMarkerService,
  MapStyleService,
])
void main() {
  group('MapController Tests', () {
    late MapController mapController;
    late MockStoreRepository mockStoreRepository;
    late MockMapLocationService mockMapLocationService;
    late MockMapMarkerService mockMapMarkerService;
    late MockMapStyleService mockMapStyleService;
    late List<Store> testStores;
    late List<Product> testProducts;

    setUp(() {
      Get.testMode = true;
      mockStoreRepository = MockStoreRepository();
      mockMapLocationService = MockMapLocationService();
      mockMapMarkerService = MockMapMarkerService();
      mockMapStyleService = MockMapStyleService();
      
      testStores = [
        Store(
          id: 1,
          name: 'Loja A',
          description: 'Descrição da Loja A',
          latitude: -23.5505,
          longitude: -46.6333,
          type: 'store',
          imageUrl: 'https://example.com/image1.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Store(
          id: 2,
          name: 'Atração B',
          description: 'Descrição da Atração B',
          latitude: -23.5515,
          longitude: -46.6343,
          type: 'attraction',
          imageUrl: 'https://example.com/image2.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      testProducts = [
        Product(
          id: 1,
          name: 'Produto 1',
          description: 'Descrição do Produto 1',
          price: 10.99,
          imageUrl: 'https://example.com/product1.jpg',
          storeId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 2,
          name: 'Produto 2',
          description: 'Descrição do Produto 2',
          price: 25.50,
          imageUrl: 'https://example.com/product2.jpg',
          storeId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Register mock services
      Get.put<StoreRepository>(mockStoreRepository);
      Get.put<MapLocationService>(mockMapLocationService);
      Get.put<MapMarkerService>(mockMapMarkerService);
      Get.put<MapStyleService>(mockMapStyleService);
      
      mapController = MapController();
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(mapController.facilities.value, isEmpty);
        expect(mapController.markers.value, isEmpty);
        expect(mapController.isLoading.value, isTrue);
        expect(mapController.selectedFacility.value, isNull);
        expect(mapController.facilityProducts.value, isEmpty);
        expect(mapController.isLoadingProducts.value, isFalse);
        expect(mapController.userLocation.value, isNull);
        expect(mapController.mapController, isNull);
        expect(mapController.mapStyle.value, isEmpty);
      });

      test('should load facilities and setup map on init', () async {
        // Arrange
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(testStores))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.getStores()).called(1);
        verify(mockMapMarkerService.createMarkersFromStores(testStores)).called(1);
        verify(mockMapStyleService.loadMapStyle()).called(1);
        verify(mockMapLocationService.getCurrentLocation()).called(1);
        expect(mapController.facilities.value, equals(testStores));
        expect(mapController.isLoading.value, isFalse);
        expect(mapController.mapStyle.value, equals('map_style_json'));
        expect(mapController.userLocation.value, equals(const LatLng(-23.5505, -46.6333)));
      });

      test('should handle error during facilities loading', () async {
        // Arrange
        when(mockStoreRepository.getStores())
            .thenThrow(Exception('Network error'));
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockStoreRepository.getStores()).called(1);
        expect(mapController.facilities.value, isEmpty);
        expect(mapController.isLoading.value, isFalse);
      });

      test('should handle location permission denied', () async {
        // Arrange
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(testStores))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenThrow(Exception('Location permission denied'));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockMapLocationService.getCurrentLocation()).called(1);
        expect(mapController.userLocation.value, isNull);
        expect(mapController.facilities.value, equals(testStores));
        expect(mapController.isLoading.value, isFalse);
      });

      test('should handle map style loading error', () async {
        // Arrange
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(testStores))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenThrow(Exception('Style loading failed'));
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockMapStyleService.loadMapStyle()).called(1);
        expect(mapController.mapStyle.value, isEmpty);
        expect(mapController.facilities.value, equals(testStores));
        expect(mapController.isLoading.value, isFalse);
      });
    });

    group('Marker Management Tests', () {
      test('should create markers from facilities', () async {
        // Arrange
        final testMarkers = <Marker>{
          const Marker(
            markerId: MarkerId('store_1'),
            position: LatLng(-23.5505, -46.6333),
          ),
          const Marker(
            markerId: MarkerId('store_2'),
            position: LatLng(-23.5515, -46.6343),
          ),
        };
        
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(testStores))
            .thenReturn(testMarkers);
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockMapMarkerService.createMarkersFromStores(testStores)).called(1);
        expect(mapController.markers.value, equals(testMarkers));
      });

      test('should handle empty facilities list', () async {
        // Arrange
        when(mockStoreRepository.getStores()).thenAnswer((_) async => <Store>[]);
        when(mockMapMarkerService.createMarkersFromStores(<Store>[]))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(mapController.facilities.value, isEmpty);
        expect(mapController.markers.value, isEmpty);
        expect(mapController.isLoading.value, isFalse);
      });

      test('should update markers when facilities change', () async {
        // Arrange
        final newMarkers = <Marker>{
          const Marker(
            markerId: MarkerId('store_3'),
            position: LatLng(-23.5525, -46.6353),
          ),
        };
        
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(any))
            .thenReturn(newMarkers);
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Simulate facilities update
        mapController.updateMarkers();
        
        // Assert
        expect(mapController.markers.value, equals(newMarkers));
      });
    });

    group('Facility Selection Tests', () {
      setUp(() async {
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(testStores))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should select facility and load products', () async {
        // Arrange
        when(mockStoreRepository.getProductsByStoreId(1))
            .thenAnswer((_) async => testProducts);
        
        // Act
        await mapController.selectFacility(testStores[0]);
        
        // Assert
        verify(mockStoreRepository.getProductsByStoreId(1)).called(1);
        expect(mapController.selectedFacility.value, equals(testStores[0]));
        expect(mapController.facilityProducts.value, equals(testProducts));
        expect(mapController.isLoadingProducts.value, isFalse);
      });

      test('should handle product loading error', () async {
        // Arrange
        when(mockStoreRepository.getProductsByStoreId(1))
            .thenThrow(Exception('Failed to load products'));
        
        // Act
        await mapController.selectFacility(testStores[0]);
        
        // Assert
        verify(mockStoreRepository.getProductsByStoreId(1)).called(1);
        expect(mapController.selectedFacility.value, equals(testStores[0]));
        expect(mapController.facilityProducts.value, isEmpty);
        expect(mapController.isLoadingProducts.value, isFalse);
      });

      test('should set loading state during product fetch', () async {
        // Arrange
        when(mockStoreRepository.getProductsByStoreId(1))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return testProducts;
        });
        
        // Act
        final future = mapController.selectFacility(testStores[0]);
        
        // Assert - should be loading
        expect(mapController.isLoadingProducts.value, isTrue);
        
        await future;
        
        // Assert - should not be loading after completion
        expect(mapController.isLoadingProducts.value, isFalse);
      });

      test('should handle attraction type facility', () async {
        // Arrange - attraction doesn't have products
        
        // Act
        await mapController.selectFacility(testStores[1]); // attraction
        
        // Assert
        verifyNever(mockStoreRepository.getProductsByStoreId(any));
        expect(mapController.selectedFacility.value, equals(testStores[1]));
        expect(mapController.facilityProducts.value, isEmpty);
        expect(mapController.isLoadingProducts.value, isFalse);
      });

      test('should clear previous selection when selecting new facility', () async {
        // Arrange
        when(mockStoreRepository.getProductsByStoreId(any))
            .thenAnswer((_) async => testProducts);
        
        // Act - select first facility
        await mapController.selectFacility(testStores[0]);
        expect(mapController.selectedFacility.value, equals(testStores[0]));
        
        // Act - select second facility
        await mapController.selectFacility(testStores[1]);
        
        // Assert
        expect(mapController.selectedFacility.value, equals(testStores[1]));
      });
    });

    group('Bottom Sheet Management Tests', () {
      test('should show facility details', () {
        // Act
        mapController.showFacilityDetails(testStores[0]);
        
        // Assert
        expect(mapController.selectedFacility.value, equals(testStores[0]));
      });

      test('should hide facility details', () {
        // Arrange
        mapController.selectedFacility.value = testStores[0];
        mapController.facilityProducts.value = testProducts;
        
        // Act
        mapController.hideFacilityDetails();
        
        // Assert
        expect(mapController.selectedFacility.value, isNull);
        expect(mapController.facilityProducts.value, isEmpty);
        expect(mapController.isLoadingProducts.value, isFalse);
      });

      test('should toggle facility details visibility', () {
        // Initially hidden
        expect(mapController.selectedFacility.value, isNull);
        
        // Show details
        mapController.showFacilityDetails(testStores[0]);
        expect(mapController.selectedFacility.value, equals(testStores[0]));
        
        // Hide details
        mapController.hideFacilityDetails();
        expect(mapController.selectedFacility.value, isNull);
      });
    });

    group('Map Controller Integration Tests', () {
      test('should handle map controller assignment', () {
        // Arrange
        final mockGoogleMapController = MockGoogleMapController();
        
        // Act
        mapController.onMapCreated(mockGoogleMapController);
        
        // Assert
        expect(mapController.mapController, equals(mockGoogleMapController));
      });

      test('should apply map style when controller is ready', () async {
        // Arrange
        final mockGoogleMapController = MockGoogleMapController();
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'test_style');
        
        mapController.mapStyle.value = 'test_style';
        
        // Act
        mapController.onMapCreated(mockGoogleMapController);
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Assert
        verify(mockGoogleMapController.setMapStyle('test_style')).called(1);
      });
    });

    group('Location Management Tests', () {
      test('should update user location', () async {
        // Arrange
        const newLocation = LatLng(-23.5600, -46.6400);
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => newLocation);
        
        // Act
        await mapController.updateUserLocation();
        
        // Assert
        verify(mockMapLocationService.getCurrentLocation()).called(1);
        expect(mapController.userLocation.value, equals(newLocation));
      });

      test('should handle location update error', () async {
        // Arrange
        when(mockMapLocationService.getCurrentLocation())
            .thenThrow(Exception('Location unavailable'));
        
        // Act
        await mapController.updateUserLocation();
        
        // Assert
        verify(mockMapLocationService.getCurrentLocation()).called(1);
        expect(mapController.userLocation.value, isNull);
      });

      test('should center map on user location', () async {
        // Arrange
        final mockGoogleMapController = MockGoogleMapController();
        const userLocation = LatLng(-23.5505, -46.6333);
        
        mapController.onMapCreated(mockGoogleMapController);
        mapController.userLocation.value = userLocation;
        
        // Act
        await mapController.centerOnUserLocation();
        
        // Assert
        verify(mockGoogleMapController.animateCamera(any)).called(1);
      });

      test('should handle center on location when no location available', () async {
        // Arrange
        final mockGoogleMapController = MockGoogleMapController();
        mapController.onMapCreated(mockGoogleMapController);
        mapController.userLocation.value = null;
        
        // Act
        await mapController.centerOnUserLocation();
        
        // Assert
        verifyNever(mockGoogleMapController.animateCamera(any));
      });
    });

    group('Search and Filter Tests', () {
      setUp(() async {
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(any))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should filter facilities by type', () {
        // Act
        final stores = mapController.getFacilitiesByType('store');
        final attractions = mapController.getFacilitiesByType('attraction');
        
        // Assert
        expect(stores.length, equals(1));
        expect(stores[0].type, equals('store'));
        expect(attractions.length, equals(1));
        expect(attractions[0].type, equals('attraction'));
      });

      test('should search facilities by name', () {
        // Act
        final searchResults = mapController.searchFacilities('Loja');
        
        // Assert
        expect(searchResults.length, equals(1));
        expect(searchResults[0].name, contains('Loja'));
      });

      test('should handle case-insensitive search', () {
        // Act
        final searchResults = mapController.searchFacilities('loja');
        
        // Assert
        expect(searchResults.length, equals(1));
        expect(searchResults[0].name.toLowerCase(), contains('loja'));
      });

      test('should return empty list for no matches', () {
        // Act
        final searchResults = mapController.searchFacilities('NonExistent');
        
        // Assert
        expect(searchResults, isEmpty);
      });

      test('should handle empty search query', () {
        // Act
        final searchResults = mapController.searchFacilities('');
        
        // Assert
        expect(searchResults, equals(testStores));
      });
    });

    group('Edge Cases and Performance Tests', () {
      test('should handle large number of facilities', () async {
        // Arrange
        final largeFacilitiesList = List.generate(1000, (index) => Store(
          id: index,
          name: 'Store $index',
          description: 'Description $index',
          latitude: -23.5505 + (index * 0.001),
          longitude: -46.6333 + (index * 0.001),
          type: index % 2 == 0 ? 'store' : 'attraction',
          imageUrl: 'https://example.com/image$index.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        when(mockStoreRepository.getStores())
            .thenAnswer((_) async => largeFacilitiesList);
        when(mockMapMarkerService.createMarkersFromStores(largeFacilitiesList))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(mapController.facilities.value.length, equals(1000));
        expect(mapController.isLoading.value, isFalse);
      });

      test('should handle concurrent facility selections', () async {
        // Arrange
        when(mockStoreRepository.getStores()).thenAnswer((_) async => testStores);
        when(mockMapMarkerService.createMarkersFromStores(testStores))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        when(mockStoreRepository.getProductsByStoreId(any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return testProducts;
        });
        
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act - select multiple facilities concurrently
        final future1 = mapController.selectFacility(testStores[0]);
        final future2 = mapController.selectFacility(testStores[1]);
        
        await Future.wait([future1, future2]);
        
        // Assert - should handle gracefully
        expect(mapController.isLoadingProducts.value, isFalse);
        expect(mapController.selectedFacility.value, isNotNull);
      });

      test('should handle memory management correctly', () {
        // Arrange
        final controller = MapController();
        
        // Act
        controller.onInit();
        controller.onClose();
        
        // Assert - no memory leaks or exceptions
        expect(controller.isClosed, isTrue);
      });

      test('should handle facilities with null coordinates', () async {
        // Arrange
        final facilitiesWithNullCoords = [
          Store(
            id: 1,
            name: 'Store with null coords',
            description: 'Description',
            latitude: null,
            longitude: null,
            type: 'store',
            imageUrl: 'https://example.com/image.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        when(mockStoreRepository.getStores())
            .thenAnswer((_) async => facilitiesWithNullCoords);
        when(mockMapMarkerService.createMarkersFromStores(facilitiesWithNullCoords))
            .thenReturn(<Marker>{});
        when(mockMapStyleService.loadMapStyle())
            .thenAnswer((_) async => 'map_style_json');
        when(mockMapLocationService.getCurrentLocation())
            .thenAnswer((_) async => const LatLng(-23.5505, -46.6333));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should handle gracefully
        expect(mapController.facilities.value, equals(facilitiesWithNullCoords));
        expect(mapController.isLoading.value, isFalse);
      });

      test('should maintain state consistency during errors', () async {
        // Arrange
        when(mockStoreRepository.getStores())
            .thenThrow(Exception('Network error'));
        when(mockMapStyleService.loadMapStyle())
            .thenThrow(Exception('Style error'));
        when(mockMapLocationService.getCurrentLocation())
            .thenThrow(Exception('Location error'));
        
        // Act
        mapController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should handle gracefully
        expect(mapController.isLoading.value, isFalse);
        expect(mapController.facilities.value, isEmpty);
        expect(mapController.markers.value, isEmpty);
        expect(mapController.userLocation.value, isNull);
        expect(mapController.mapStyle.value, isEmpty);
      });
    });
  });
}

// Mock class for GoogleMapController
class MockGoogleMapController extends Mock implements GoogleMapController {
  @override
  Future<void> setMapStyle(String? mapStyle) async {}
  
  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {}
}