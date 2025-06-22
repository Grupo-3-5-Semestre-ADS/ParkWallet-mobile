import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/models/product.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:park_wallet/pages/map/widgets/location_permission_dialog.dart';
import 'package:park_wallet/pages/map/widgets/location_denied_dialog.dart';
import 'dart:developer' as developer;

class StoreDetailController extends GetxController {
  final Rx<Store> store = Rx<Store>(Get.arguments);
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;
  final StoreRepository storeRepository = StoreRepository();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Store) {
      _loadStoreDetailAndProducts();
    }
  }

  Future<void> _loadStoreDetailAndProducts() async {
    isLoading.value = true;
    try {
      final storeDetail = await storeRepository.fetchStoreById(store.value.id);
      store.value = storeDetail;
      if (store.value.type.toLowerCase() != 'atracao' &&
          store.value.type.toLowerCase() != 'atração' &&
          store.value.type.toLowerCase() != 'attraction' &&
          store.value.type.toLowerCase() != 'other' &&
          store.value.type.toLowerCase() != 'outro') {
        final storeProducts = await storeRepository.fetchStoreProducts(store.value.id);
        products.assignAll(storeProducts);
      } else {
        products.clear();
      }
    } catch (e, s) {
      Get.snackbar('error'.tr, 'store_details_load_error'.trParams({'error': e.toString()}));
      developer.log(
        'Falha ao carregar detalhes da loja',
        error: e,
        stackTrace: s,
        name: 'StoreDetailController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewOnMap() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Get.dialog(
        LocationPermissionDialog(
          onAllowPressed: () async {
            Get.back();
            await Permission.location.request();
          },
          onDenyPressed: () {
            Get.back();
          },
        ),
      );
      status = await Permission.location.status;
    }

    if (status.isGranted) {
      await _performViewOnMapAction();
      await Future.delayed(const Duration(seconds: 4));
      await _performViewOnMapAction();
    } else {
      await Get.dialog(LocationDeniedDialog(
        onRetryPressed: () {
          Get.back();
          viewOnMap();
        },
      ));
    }
  }

  Future<void> _performViewOnMapAction() async {
    if (store.value != null) {
      try {
        final storeId = store.value.id;
        final coordinates = await _fetchStoreCoordinatesFromFacilities(storeId);

        if (coordinates != null) {
          final lat = coordinates['lat']!;
          final lng = coordinates['lng']!;

          final arguments = {
            'storeIdToFocus': storeId,
            'focusStoreId': storeId,
            'latitude': lat,
            'longitude': lng,
          };

          if (Get.currentRoute == '/map') {
            Get.offAndToNamed('/map', arguments: arguments);
          } else {
            Get.toNamed('/map', arguments: arguments);
          }
        } else {
          Get.snackbar(
            'warning'.tr,
            'store_location_not_defined'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e, s) {
        Get.snackbar(
          'error'.tr,
          'store_location_fetch_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        developer.log(
          'Erro ao obter localização da loja no _performViewOnMapAction',
          error: e,
          stackTrace: s,
          name: 'StoreDetailController',
        );
      }
    } else {
      Get.snackbar(
        'error'.tr,
        'store_info_unavailable'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Map<String, double>?> _fetchStoreCoordinatesFromFacilities(String storeId) async {
    try {
      final Uri uri = Uri.parse(Endpoints.storesEndpoint).replace(queryParameters: {'page': '1', '_size': '100'});

      String? authToken;
      try {
        authToken = Get.find<AuthService>().token;
      } catch (e) {
        developer.log('AuthService não encontrado, continuando sem token', name: 'StoreDetailController', error: e);
      }

      final headers = {'Content-Type': 'application/json; charset=UTF-8'};
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> facilitiesDataList = (decoded is Map && decoded['data'] is List)
            ? decoded['data']
            : (decoded is List ? decoded : []);

        for (final facilityData in facilitiesDataList) {
          try {
            final facilityId = facilityData['id'].toString();

            if (facilityId == storeId) {
              final latString = facilityData['latitude']?.toString() ?? '';
              final lngString = facilityData['longitude']?.toString() ?? '';

              if (latString.isNotEmpty && lngString.isNotEmpty) {
                final lat = double.tryParse(latString);
                final lng = double.tryParse(lngString);

                if (lat != null && lng != null) {
                  return {'lat': lat, 'lng': lng};
                }
              }
            }
          } catch (e, s) {
            developer.log(
              'Erro ao processar uma facility da lista. Continuando.',
              error: e,
              stackTrace: s,
              name: 'StoreDetailController',
            );
          }
        }
      } else {
        developer.log('Erro na API ao buscar facilities. Status: ${response.statusCode}', name: 'StoreDetailController');
      }
    } catch (e, s) {
      developer.log(
        'Falha na requisição de facilities',
        error: e,
        stackTrace: s,
        name: 'StoreDetailController',
      );
    }

    return null;
  }

  void addToCart(Product product) {
    Get.snackbar(
      'product_added'.tr,
      'product_added_to_cart'.trParams({'product': product.name}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}