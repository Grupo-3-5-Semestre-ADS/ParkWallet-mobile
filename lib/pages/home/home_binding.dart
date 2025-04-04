import 'package:get/get.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/pages/home/controllers/home_history_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeCreditController>(() => HomeCreditController());
    Get.lazyPut<HomeHistoryController>(() => HomeHistoryController());
  }
}
