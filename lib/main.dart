import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/global/app_translations.dart';
import 'package:park_wallet/global/language_controller.dart';
import 'package:park_wallet/pages/login/controllers/login_controller.dart';
import 'package:park_wallet/routes/app_pages.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/services/profile_service.dart';
import 'package:park_wallet/services/transaction_event_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<LanguageController>(LanguageController());
  Get.put<LoginController>(LoginController());
  Get.put<TransactionEventService>(TransactionEventService());
  Get.put<RouteObserver<PageRoute>>(RouteObserver<PageRoute>());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => ProfileService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Get.locale ?? Get.deviceLocale ?? const Locale('pt', 'BR'),
      fallbackLocale: Locale('pt', 'BR'),
      translations: AppTranslations(),
      navigatorObservers: [Get.find<RouteObserver<PageRoute>>()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sapphire,
        ),
      ),
      title: 'Flutter Auth with GetX',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.HOME,
      getPages: AppPages.routes,
    );
  }
}
