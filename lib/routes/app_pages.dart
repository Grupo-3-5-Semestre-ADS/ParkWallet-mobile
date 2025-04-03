import 'package:get/get.dart';
import 'package:park_wallet/pages/home/home_binding.dart';
import 'package:park_wallet/pages/home/home_page.dart';
import 'package:park_wallet/pages/login/login_page.dart';
import 'package:park_wallet/pages/register/register_page.dart';
import 'package:park_wallet/pages/register/regsiter_binding.dart';
import 'package:park_wallet/services/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
        name: Routes.LOGIN,
        page: () => const LoginPage()
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
