import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/global/language_controller.dart';
import 'package:park_wallet/routes/app_pages.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/services/profile_service.dart';

class CommonDrawer extends StatelessWidget {

  CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final ProfileService profileService = ProfileService();

    final LanguageController languageController =
        Get.find<LanguageController>();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(languageController.flagImagePath.value),
                    )),
                    const SizedBox(height: 10),
                    Text(
                      'welcome'.tr,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      (profileService.userProfile?.name.split(" ").first ?? profileService.userProfile?.name) ?? '',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('profile'.tr),
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.PROFILE);
                  },
                ),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.pin_drop),
                  title: Text('map'.tr),
                  onTap: () => Get.offNamed(Routes.MAP),
                ),
                ListTile(
                  leading: const Icon(Icons.store),
                  title: Text('stores'.tr),
                  onTap: () => Get.offNamed(Routes.STORES),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text('home'.tr),
                  onTap: () => Get.offNamed(Routes.HOME),
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: Text('history'.tr),
                  onTap: () => Get.offNamed(Routes.HISTORY),
                ),
                ListTile(
                  leading: const Icon(Icons.chat_rounded),
                  title: Text('news'.tr),
                  onTap: () => Get.offNamed(Routes.CHAT),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text("logout".tr),
                  onTap: () {
                    authService.logout();
                    Get.offAllNamed(
                      '/login',
                    );
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
