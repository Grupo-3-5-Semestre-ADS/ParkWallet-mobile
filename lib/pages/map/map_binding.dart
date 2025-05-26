// park_wallet/bindings/map_binding.dart
import 'package:get/get.dart';
import 'package:park_wallet/pages/map/controllers/map_controller.dart';
import 'package:park_wallet/pages/stores/controllers/stores_controller.dart'; // Ajuste o caminho

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoresController>(() => StoresController(), fenix: true);
    Get.lazyPut<MapController>(() => MapController(), fenix: true);
  }
}