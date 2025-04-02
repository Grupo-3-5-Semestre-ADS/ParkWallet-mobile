import "package:get/get.dart" as home_controller;

class HomeController extends home_controller.GetxController {
  var count = 0.obs;

  void increment() {
    count++;
  }
}
