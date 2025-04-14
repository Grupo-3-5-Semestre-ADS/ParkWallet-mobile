import 'package:get/get.dart';
import 'package:park_wallet/pages/stores/controllers/store_detail_controller.dart';

class StoreDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreDetailController>(() => StoreDetailController());
  }
}