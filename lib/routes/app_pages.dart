import 'package:get/get.dart';
import 'package:park_wallet/pages/home/home_binding.dart';
import 'package:park_wallet/pages/home/home_page.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}