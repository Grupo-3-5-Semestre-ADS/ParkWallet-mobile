import 'package:get/get.dart';
import 'package:park_wallet/modules/home/controllers/HomeController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
