import 'package:get/get.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/routes/app_pages.dart';
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/pages/stores/controllers/store_detail_controller.dart';
class StoresController extends GetxController {
  final RxList<Store> _allStores = <Store>[].obs;
  final RxList<Store> filteredStores = <Store>[].obs;
  final RxString searchQuery = ''.obs;
  final StoreRepository storeRepository = StoreRepository();
  final RxBool isLoading = true.obs;
  int _currentPage = 1;
  final int _limit = 100;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  void onInit() {
    super.onInit();
    _fetchStores(reset: true);
    debounce(searchQuery, (_) => _applyFilter(), time: const Duration(milliseconds: 300));
  }

  Future<void> _fetchStores({bool reset = false}) async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    if (reset) {
      _allStores.clear();
      _currentPage = 1;
      _hasMore = true;
    }
    isLoading.value = true;
    try {
      final stores = await storeRepository.fetchStores(page: _currentPage, limit: _limit);
      if (stores.length < _limit) {
        _hasMore = false;
      }
      _allStores.addAll(stores);
      _applyFilter();
      _currentPage++;
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      isLoading.value = false;
      _isFetchingMore = false;
    }
  }

  void loadMoreStores() {
    if (_hasMore && !_isFetchingMore) {
      _fetchStores();
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
    _fetchStores(reset: true);
  }
  void navigateToStoreDetail(Store store) {
    Get.delete<StoreDetailController>();
    Get.toNamed(Routes.STORE_DETAIL, arguments: store, preventDuplicates: false);
  }
}