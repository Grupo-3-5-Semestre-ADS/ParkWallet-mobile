import 'package:get/get.dart';
import 'package:park_wallet/data/models/product.dart';
import 'package:park_wallet/data/models/store.dart';

class StoreDetailController extends GetxController {
  final Rx<Store> store = Rx<Store>(Get.arguments);
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoreProducts();
  }

  void _loadStoreProducts() {
    // Simulando carregamento de dados
    Future.delayed(const Duration(milliseconds: 800), () {
      // Dados mockados de produtos da loja
      final mockProducts = [
        Product(
          id: '1',
          name: 'Coca-Cola 300ml',
          price: 5.00,
          storeId: store.value.id,
          image: 'assets/images/coca-cola.png',
        ),
        Product(
          id: '2',
          name: 'Pamonha Doce',
          price: 7.00,
          storeId: store.value.id,
          image: 'assets/images/pamonha.png',
        ),
        Product(
          id: '3',
          name: 'Milho Assado',
          price: 12.00,
          storeId: store.value.id,
          image: 'assets/images/milho.png',
        ),
        Product(
          id: '4',
          name: 'Água Mineral 500ml',
          price: 3.50,
          storeId: store.value.id,
        ),
        Product(
          id: '5',
          name: 'Suco Natural',
          price: 8.00,
          storeId: store.value.id,
        ),
      ];

      products.value = mockProducts;
      isLoading.value = false;
    });
  }

  void viewOnMap() {
    // Implementação futura para visualizar a loja no mapa
    Get.snackbar(
      'Funcionalidade em desenvolvimento',
      'Visualização no mapa será implementada em breve.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addToCart(Product product) {
    // Implementação futura para adicionar produto ao carrinho
    Get.snackbar(
      'Produto adicionado',
      '${product.name} adicionado ao carrinho.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}