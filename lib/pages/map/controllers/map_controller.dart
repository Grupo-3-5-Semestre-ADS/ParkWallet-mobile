import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Imports do projeto
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/constants/map_config.dart';
import 'package:park_wallet/data/models/product.dart' as ui_model;
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/services/auth_service.dart';

// Imports dos novos arquivos organizados
import 'package:park_wallet/pages/map/models/map_display_facility.dart';
import 'package:park_wallet/pages/map/services/map_location_service.dart';
import 'package:park_wallet/pages/map/services/map_marker_service.dart';
import 'package:park_wallet/pages/map/services/map_style_service.dart';
import 'package:park_wallet/pages/map/widgets/facility_details_bottom_sheet.dart';
import 'package:park_wallet/pages/map/widgets/location_denied_dialog.dart';
import 'package:park_wallet/pages/map/widgets/location_permission_dialog.dart';

class MapController extends GetxController {
  final Completer<GoogleMapController> mapCompleter = Completer();
  GoogleMapController? _mapController;
  late CameraPosition initialCameraPosition;
  late final LatLngBounds cameraBounds;
  late final MinMaxZoomPreference zoomPreference;

  final facilities = <MapDisplayFacility>[].obs;
  final Rx<Set<Marker>> markers = Rx<Set<Marker>>({});
  final RxBool isLoadingFacilities = true.obs;

  final Rx<MapDisplayFacility?> selectedFacilityForBottomSheet = Rx<MapDisplayFacility?>(null);
  final RxList<ui_model.Product> productsForBottomSheet = <ui_model.Product>[].obs;
  final RxBool isLoadingProductsForBottomSheet = false.obs;
  final RxBool isMapInteractionDisabled = false.obs;

  late final StoreRepository _storeRepository;
  final Rx<String?> selectedMarkerId = Rx<String?>(null);

  final RxBool isLocationPermissionGranted = false.obs;
  final RxBool isRequestingPermission = false.obs;

  String? _storeIdToFocus;

  Marker? _userLocationMarker;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  @override
  void onInit() {
    super.onInit();
    print('MapController onInit iniciado');

    _storeRepository = StoreRepository();
    cameraBounds = MapConfig.getCameraBounds();
    zoomPreference = MapConfig.getZoomPreference();
    initialCameraPosition = MapConfig.getDefaultCameraPosition();

    ever(selectedMarkerId, (_) {
      _updateMarkersSelection();
    });

    _checkLocationPermissionOnInit();

    if (kIsWeb) {
      _startUserLocationTracking();
    }
  }

  void _startUserLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      return;
    }

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      _updateUserLocationMarker(position);
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      _updateUserLocationMarker(position);
    } catch (e) {
      print('Erro ao obter posição inicial: $e');
    }
  }

  void _updateUserLocationMarker(Position position) {
    final marker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    _userLocationMarker = marker;
    _updateMarkersSelection();
  }

  Future<void> _checkLocationPermissionOnInit() async {
    print('Verificando permissão de localização...');
    final hasPermission = await MapLocationService.checkLocationPermission();
    isLocationPermissionGranted.value = hasPermission;

    if (hasPermission) {
      print('Permissão concedida, iniciando carregamento...');
      await _initializeAssetsAndFetch();
    } else {
      print('Permissão negada, mostrando dialog...');
      _showLocationPermissionDialog();
    }
  }

  void _showLocationPermissionDialog() {
    Get.dialog(
      LocationPermissionDialog(
        onAllowPressed: () {
          Get.back();
          _requestLocationPermission();
        },
        onDenyPressed: () {
          Get.back();
          _handlePermissionDenied();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _requestLocationPermission() async {
    if (isRequestingPermission.value) return;

    isRequestingPermission.value = true;

    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        isLocationPermissionGranted.value = true;
        Get.snackbar(
          'Sucesso',
          'Permissão de localização concedida!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        await _initializeAssetsAndFetch();
      } else if (status.isPermanentlyDenied) {
        _showLocationDeniedDialog();
      } else {
        _handlePermissionDenied();
      }
    } catch (e) {
      print('Erro ao solicitar permissão: $e');
      _handlePermissionDenied();
    } finally {
      isRequestingPermission.value = false;
    }
  }

  void _handlePermissionDenied() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    _showLocationDeniedDialog();
  }

  void _showLocationDeniedDialog() {
    Get.dialog(
      LocationDeniedDialog(
        onRetryPressed: () {
          Get.back();
          _showLocationPermissionDialog();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> _ensureLocationPermission() async {
    if (isLocationPermissionGranted.value) {
      return true;
    }

    final status = await Permission.location.status;
    if (status.isGranted) {
      isLocationPermissionGranted.value = true;
      return true;
    }

    _showLocationPermissionDialog();
    return false;
  }

  void _setupInitialPosition() {
    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic>) {
        final args = Get.arguments as Map<String, dynamic>;

        if (args.containsKey('focusStoreId')) {
          final storeId = args['focusStoreId'].toString();
          _storeIdToFocus = storeId;
          selectedMarkerId.value = storeId;

          if (args.containsKey('latitude') && args.containsKey('longitude')) {
            final latValue = args['latitude'];
            final lngValue = args['longitude'];

            final lat = double.tryParse(latValue.toString());
            final lng = double.tryParse(lngValue.toString());

            if (lat != null && lng != null) {
              initialCameraPosition = MapConfig.getFocusedCameraPosition(lat, lng);
              return;
            }
          }
        }
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    print('Mapa criado!');
    _mapController = controller;
    _setupInitialPosition();

    if (!mapCompleter.isCompleted) {
      mapCompleter.complete(controller);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      mapCompleter.future.then((c) {
        if (MapStyleService.mapStyle != null) {
          c.setMapStyle(MapStyleService.mapStyle);
        }
      }).catchError((error) {
        print('Erro ao aplicar estilo do mapa: $error');
      });
    });

    if (_storeIdToFocus != null) {
      final currentTarget = initialCameraPosition.target;
      final isParkCenter = currentTarget.latitude == MapConfig.parkCenter.latitude &&
          currentTarget.longitude == MapConfig.parkCenter.longitude;

      if (!isParkCenter) {
        if (isLoadingFacilities.value) {
          once(isLoadingFacilities, (bool isLoading) {
            if (!isLoading) {
              _updateMarkersSelection();
            }
          });
        } else {
          _updateMarkersSelection();
        }
      } else {
        if (isLoadingFacilities.value) {
          once(isLoadingFacilities, (bool isLoading) {
            if (!isLoading) {
              _focusOnStoreAfterLoad(_storeIdToFocus!);
            }
          });
        } else {
          _focusOnStoreAfterLoad(_storeIdToFocus!);
        }
      }
    }
  }

  void _focusOnStoreAfterLoad(String storeId) {
    final facility = facilities.firstWhereOrNull((f) => f.id == storeId);
    if (facility != null && facility.latitude != null && facility.longitude != null) {
      final targetPosition = LatLng(facility.latitude!, facility.longitude!);

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(targetPosition, MapConfig.focusZoom));
      } else {
        mapCompleter.future.then((controller) {
          return controller.animateCamera(CameraUpdate.newLatLngZoom(targetPosition, MapConfig.focusZoom));
        }).catchError((error) {
          print('Erro ao focar na loja: $error');
        });
      }
    } else {
      Get.snackbar('Aviso', 'Localização da loja não encontrada no mapa.');
    }
  }

  Future<void> _initializeAssetsAndFetch() async {
    print('Inicializando assets e buscando facilities...');
    try {
      await MapMarkerService.initializeMarkerIcons();
      print('Marcadores inicializados');
      
      await MapStyleService.loadMapStyle();
      print('Estilo do mapa carregado');
      
      await _fetchAndLoadFacilities();
      print('Facilities carregadas');
    } catch (e) {
      print('Erro ao inicializar: $e');
      await _fetchAndLoadFacilities();
    }
  }

  void _handleMarkerTap(String facilityId) {
    final facility = facilities.firstWhereOrNull((f) => f.id == facilityId);
    if (facility == null) return;

    selectedMarkerId.value = facilityId;

    selectedFacilityForBottomSheet.value = facility;
    productsForBottomSheet.clear();
    if (facility.type.toLowerCase() == 'store') {
      _fetchProductsForBottomSheet(facility.id);
    }
    isMapInteractionDisabled.value = true;
    Get.bottomSheet(
      FacilityDetailsBottomSheet(facility: facility, controller: this),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ).whenComplete(() {
      selectedFacilityForBottomSheet.value = null;
      productsForBottomSheet.clear();
      isMapInteractionDisabled.value = false;
    });
  }

  void _updateMarkersSelection() {
    print('Atualizando markers. Total facilities: ${facilities.length}');
    final newMarkers = <Marker>{};

    for (final facility in facilities) {
      if (facility.inactive || facility.latitude == null || facility.longitude == null) {
        print('Facility ${facility.name} pulada - inactive: ${facility.inactive}, lat: ${facility.latitude}, lng: ${facility.longitude}');
        continue;
      }

      final isSelected = selectedMarkerId.value == facility.id;
      final icon = MapMarkerService.getMarkerIcon(facility.type, isSelected);

      newMarkers.add(Marker(
        markerId: MarkerId(facility.id),
        position: LatLng(facility.latitude!, facility.longitude!),
        icon: icon,
        onTap: () => _handleMarkerTap(facility.id)
      ));
    }

    if (kIsWeb && _userLocationMarker != null) {
      newMarkers.removeWhere((m) => m.markerId.value == 'user_location');
      newMarkers.add(_userLocationMarker!);
    }

    print('Total markers criados: ${newMarkers.length}');
    markers.value = newMarkers;
  }

  Future<void> _fetchProductsForBottomSheet(String facilityId) async {
    isLoadingProductsForBottomSheet.value = true;
    productsForBottomSheet.clear();
    try {
      final fetchedProducts = await _storeRepository.fetchStoreProducts(facilityId);
      productsForBottomSheet.assignAll(fetchedProducts);
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      Get.snackbar('Erro', 'Não foi possível carregar os produtos da loja.');
    } finally {
      isLoadingProductsForBottomSheet.value = false;
    }
  }

  Future<void> _fetchAndLoadFacilities() async {
    print('Buscando facilities...');
    isLoadingFacilities.value = true;
    try {
      final Uri uri = Uri.parse(Endpoints.storesEndpoint).replace(queryParameters: {'page': '1', '_size': '100'});
      String? authToken;
      try {
        authToken = Get.find<AuthService>().token;
      } catch (e) {
        print('Sem token de auth: $e');
      }
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
      
      print('Fazendo requisição para: $uri');
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      
      print('Status da resposta: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> facilitiesDataList = (decoded is Map && decoded['data'] is List)
            ? decoded['data']
            : (decoded is List ? decoded : []);
            
        print('Dados recebidos: ${facilitiesDataList.length} facilities');
        final newFacilities = <MapDisplayFacility>[];
        for (final data in facilitiesDataList) {
          try {
            final facility = MapDisplayFacility.fromJson(data);
            if (facility.inactive || facility.latitude == null || facility.longitude == null) {
              print('Facility ${facility.name} ignorada - inactive: ${facility.inactive}');
              continue;
            }
            newFacilities.add(facility);
          } catch (e) {
            print('Erro ao processar facility: $e');
          }
        }
        
        print('Facilities válidas: ${newFacilities.length}');
        facilities.assignAll(newFacilities);
        _updateMarkersSelection();
      } else {
        print('Erro na API: ${response.statusCode} - ${response.body}');
        Get.snackbar('Erro de API', 'Falha ao buscar locais: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro de rede: $e');
      Get.snackbar('Erro de Rede', 'Não foi possível conectar ao servidor.');
    } finally {
      isLoadingFacilities.value = false;
    }
  }

  void focusOnStore(String storeId) {
    selectedMarkerId.value = storeId;

    final facility = facilities.firstWhereOrNull((f) => f.id == storeId);
    if (facility != null && facility.latitude != null && facility.longitude != null) {
      final targetPosition = LatLng(facility.latitude!, facility.longitude!);

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(targetPosition, MapConfig.focusZoom));
      } else {
        mapCompleter.future.then((controller) {
          controller.animateCamera(CameraUpdate.newLatLngZoom(targetPosition, MapConfig.focusZoom));
        });
      }
    }
  }

  void resetToDefaultPosition() {
    selectedMarkerId.value = null;
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(MapConfig.getDefaultCameraPosition()));
    } else {
      mapCompleter.future.then((controller) {
        controller.animateCamera(CameraUpdate.newCameraPosition(MapConfig.getDefaultCameraPosition()));
      });
    }
  }

Future<void> centerOnPark() async {
  try {
    GoogleMapController? controller = _mapController;
    if (controller == null) {
      controller = await mapCompleter.future;
    }

    final defaultPosition = MapConfig.getDefaultCameraPosition();

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(defaultPosition),
    );

    initialCameraPosition = defaultPosition;
    selectedMarkerId.value = null;
    _storeIdToFocus = null;

  } catch (e) {
    print('Erro ao centralizar mapa: $e');
  }
}

  Future<void> findNearestStore() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        return;
      }

      Get.dialog(
        Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Procurando loja mais próxima...'),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Get.back(); 
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true, 
      );

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      final stores = facilities.where((facility) =>
          facility.type.toLowerCase() == 'store' &&
          facility.latitude != null &&
          facility.longitude != null).toList();

      if (stores.isEmpty) {
        Get.snackbar(
            'Nenhuma loja encontrada', 'Não há lojas cadastradas no mapa.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      double minDistance = double.infinity;
      MapDisplayFacility? nearestStore;

      for (var store in stores) {
        double distance = MapLocationService.calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          store.latitude!,
          store.longitude!,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestStore = store;
        }
      }

      if (nearestStore != null) {
        selectedMarkerId.value = nearestStore.id;

        GoogleMapController? controller = _mapController ?? await mapCompleter.future;

        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(nearestStore.latitude!, nearestStore.longitude!),
              zoom: MapConfig.focusZoom,
            ),
          ),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar('Erro', 'Não foi possível encontrar a loja mais próxima.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print('Erro ao encontrar loja mais próxima: $e');
    }
  }

  Future<void> centerOnMyLocation() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      Get.snackbar(
        'Permissão Negada',
        'Não é possível obter a localização sem a sua permissão.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Obtendo sua localização...'),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );

    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Get.back(); 

      final GoogleMapController? controller = _mapController ?? await mapCompleter.future;
      controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition.latitude, currentPosition.longitude),
          MapConfig.focusZoom,
        ),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erro',
        'Não foi possível obter sua localização. Verifique se o GPS está ativado.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[800],
        colorText: Colors.white,
      );
      print('Erro ao centralizar na localização do usuário: $e');
    }
  }

  @override
  void onClose() {
    _mapController = null;
    _positionStreamSubscription?.cancel();
    super.onClose();
  }
}

