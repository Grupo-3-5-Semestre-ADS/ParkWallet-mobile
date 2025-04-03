import "package:get/get.dart";
import "package:park_wallet/services/auth_service.dart";

class HomeController extends GetxController {
  var count = 0.obs;
  AuthService as = AuthService();

  void increment() {
        as.logout();
  }
}
