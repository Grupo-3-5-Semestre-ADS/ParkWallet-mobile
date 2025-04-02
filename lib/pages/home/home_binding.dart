import 'package:get/get.dart';
import 'package:park_wallet/pages/home/controllers/HomeController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
