import "package:get/get.dart" as home_controller;
import "package:park_wallet/services/auth_service.dart";

class HomeController extends home_controller.GetxController {
  var count = 0.obs;
  AuthService as = AuthService();

  void increment() {
        as.logout();
  }
}
