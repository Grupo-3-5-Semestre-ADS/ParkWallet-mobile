import 'package:get/get.dart';
import 'package:park_wallet/data/models/store.dart';

class StoresController extends GetxController {
  final RxList<Store> _allStores = <Store>[].obs;
  final RxList<Store> filteredStores = <Store>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _generateMockData();
    _applyFilter();
    debounce(searchQuery, (_) => _applyFilter(), time: const Duration(milliseconds: 300));
  }

  void _generateMockData() {
    final stores = [
      Store(
        id: '1',
        name: 'Barraca da Pamonha',
        type: 'Alimentação',
        image: 'assets/images/pamonha.png',
        description: 'Deliciosas pamonhas e outros produtos de milho.',
      ),
      Store(
        id: '2',
        name: 'Barraca das Porções',
        type: 'Alimentação',
        image: 'assets/images/porcoes.png',
        description: 'Porções variadas para toda a família.',
      ),
      Store(
        id: '3',
        name: 'Loja de Souvenirs',
        type: 'Presentes',
        image: null,
        description: 'Lembranças e presentes para todos os gostos.',
      ),
      Store(
        id: '4',
        name: 'Café do Parque',
        type: 'Alimentação',
        image: null,
        description: 'Cafés especiais e lanches rápidos.',
      ),
      Store(
        id: '5',
        name: 'Loja de Brinquedos',
        type: 'Entretenimento',
        image: null,
        description: 'Brinquedos e jogos para todas as idades.',
      ),
      Store(
        id: '6',
        name: 'Sorveteria Gelato',
        type: 'Alimentação',
        image: null,
        description: 'Sorvetes artesanais com sabores variados.',
      ),
      Store(
        id: '7',
        name: 'Loja de Roupas',
        type: 'Vestuário',
        image: null,
        description: 'Roupas e acessórios para toda a família.',
      ),
      Store(
        id: '8',
        name: 'Farmácia do Parque',
        type: 'Saúde',
        image: null,
        description: 'Medicamentos e produtos de higiene.',
      ),
    ];

    _allStores.addAll(stores);
  }

  void _applyFilter() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredStores.value = _allStores;
      return;
    }

    final matches = _allStores
        .where((store) =>
            store.name.toLowerCase().contains(query) ||
            store.type.toLowerCase().contains(query))
        .toList();

    filteredStores.value = matches;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void navigateToStoreDetail(Store store) {
    // Implementar navegação para a tela de detalhes da loja
    // Get.toNamed('/store-detail', arguments: store);
    Get.snackbar(
      'Funcionalidade em desenvolvimento',
      'Detalhes da loja ${store.name} serão implementados em breve.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}