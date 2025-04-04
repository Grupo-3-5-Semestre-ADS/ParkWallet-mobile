import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/global/language_controller.dart';
import 'package:park_wallet/services/auth_service.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final LanguageController languageController =
        Get.find<LanguageController>();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      languageController.flagImagePath.value,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                 Text(
                    'welcome'.tr,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  )

              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Início"),
                  onTap: () {
                    Get.offNamed('/home'); // Navegar para a tela inicial
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Sair"),
                  onTap: () {
                    authService.logout();
                    Get.offAllNamed(
                      '/login',
                    ); // Redirecionar para a tela de login
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
