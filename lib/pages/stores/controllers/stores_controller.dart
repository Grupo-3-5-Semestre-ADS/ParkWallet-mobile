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
      // FILTRA APENAS LOJAS DO TIPO 'store'
      final onlyStores = stores.where((s) => s.type?.toLowerCase() == 'store').toList();
      if (onlyStores.length < _limit) {
        _hasMore = false;
      }
      _allStores.addAll(onlyStores);
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
    // FILTRA APENAS LOJAS DO TIPO 'store' ANTES DE FILTRAR POR NOME/TIPO
    final onlyStores = _allStores.where((s) => s.type?.toLowerCase() == 'store').toList();
    if (query.isEmpty) {
      filteredStores.value = onlyStores;
    } else {
      final matches = onlyStores
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
    // Remove o controller anterior apenas se estiver registrado
    if (Get.isRegistered<StoreDetailController>()) {
      Get.delete<StoreDetailController>();
    }
    Get.toNamed(Routes.STORE_DETAIL, arguments: store, preventDuplicates: false);
  }
}