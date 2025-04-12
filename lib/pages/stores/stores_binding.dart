import 'package:get/get.dart';
import 'package:park_wallet/pages/stores/controllers/stores_controller.dart';

class StoresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoresController>(() => StoresController());
  }
}