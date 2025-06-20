import 'package:get/get.dart';
import 'package:park_wallet/data/models/product.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/repositories/product_repository.dart';

class StoreDetailController extends GetxController {
  final Rx<Store> store = Rx<Store>(Get.arguments);
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;
  final StoreRepository storeRepository = StoreRepository();
  final ProductRepository productRepository = ProductRepository();

  @override
  void onInit() {
    super.onInit();
    _loadStoreDetailAndProducts();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void updateStore(Store newStore) async {
    store.value = newStore;
    await _loadStoreDetailAndProducts();
  }

  Future<void> _loadStoreDetailAndProducts() async {
    isLoading.value = true;
    try {
      final storeDetail = await storeRepository.fetchStoreById(store.value.id);
      store.value = storeDetail;
      // Só busca produtos se não for atração
      if (store.value.type.toLowerCase() != 'atracao' && store.value.type.toLowerCase() != 'atração' && store.value.type.toLowerCase() != 'attraction') {
        final storeProducts = await storeRepository.fetchStoreProducts(store.value.id);
        products.assignAll(storeProducts);
      } else {
        products.clear();
      }
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void viewOnMap() {
    Get.snackbar(
      'Funcionalidade em desenvolvimento',
      'Visualização no mapa será implementada em breve.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

void addToCart(Product product) {
  Get.snackbar(
    'Produto adicionado',
    '${product.name} adicionado ao carrinho.',
    snackPosition: SnackPosition.BOTTOM,
  );
}