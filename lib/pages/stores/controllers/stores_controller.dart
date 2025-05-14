import 'package:get/get.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/routes/app_pages.dart';
import 'package:park_wallet/repositories/store_repository.dart';

class StoresController extends GetxController {
  final RxList<Store> _allStores = <Store>[].obs;
  final RxList<Store> filteredStores = <Store>[].obs;
  final RxString searchQuery = ''.obs;
  final StoreRepository storeRepository = StoreRepository();
  final RxBool isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    _fetchStores();
    debounce(searchQuery, (_) => _applyFilter(), time: const Duration(milliseconds: 300));
  }
  Future<void> _fetchStores() async {
    isLoading.value = true;
    try {
      final stores = await storeRepository.fetchStores();
      _allStores.assignAll(stores);
      _applyFilter();
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  void _applyFilter() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredStores.value = _allStores;
    } else {
      final matches = _allStores
          .where((store) =>
              store.name.toLowerCase().contains(query) ||
              store.type.toLowerCase().contains(query))
          .toList();
      filteredStores.value = matches;
    }
  }
  void updateSearch(String value) {
    searchQuery.value = value;
  }
  void navigateToStoreDetail(Store store) {
    Get.toNamed(Routes.STORE_DETAIL, arguments: store);
  }
}