import 'package:get/get.dart';
import 'package:park_wallet/pages/chat/chat_binding.dart';
import 'package:park_wallet/pages/chat/chat_page.dart';
import 'package:park_wallet/pages/history/history_binding.dart';
import 'package:park_wallet/pages/history/history_page.dart';
import 'package:park_wallet/pages/home/home_binding.dart';
import 'package:park_wallet/pages/home/home_page.dart';
import 'package:park_wallet/pages/login/login_page.dart';
import 'package:park_wallet/pages/login/pages/forgot_password_page.dart';
import 'package:park_wallet/pages/profile/profile_binding.dart';
import 'package:park_wallet/pages/profile/profile_page.dart';
import 'package:park_wallet/pages/register/register_page.dart';
import 'package:park_wallet/pages/register/regsiter_binding.dart';
import 'package:park_wallet/pages/stores/store_detail_binding.dart';
import 'package:park_wallet/pages/stores/store_detail_page.dart';
import 'package:park_wallet/pages/stores/stores_binding.dart';
import 'package:park_wallet/pages/stores/stores_page.dart';
import 'package:park_wallet/services/auth_middleware.dart';
import 'package:park_wallet/pages/map/map_binding.dart';
import 'package:park_wallet/pages/map/map_page.dart';

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
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.STORES,
      page: () => const StoresPage(),
      binding: StoresBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.STORE_DETAIL,
      page: () => const StoreDetailPage(),
      binding: StoreDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => const ChatPage(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
    ),
      GetPage(
      name: Routes.MAP,
      page: () => const MapPage(),
      binding: MapBinding(),
      middlewares: [AuthMiddleware()],
    )
  ];
}
