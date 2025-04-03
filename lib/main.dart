import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/login/controllers/login_controller.dart';
import 'package:park_wallet/routes/app_pages.dart';
import 'package:park_wallet/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put<LoginController>(LoginController());
  await Get.putAsync(() => AuthService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
