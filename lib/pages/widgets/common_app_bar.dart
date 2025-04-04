import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/global/language_controller.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;

  const CommonAppBar({Key? key, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();
    final RxString flagImagePath = languageController.flagImagePath;

    return AppBar(
      backgroundColor: AppColors.very_light_grey,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
      ),
      actions: [
        Obx(() => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PopupMenuButton<String>(
            onSelected: (String selectedFlag) {
              if (selectedFlag == languageController.BRASIL_FLAG) {
                languageController.changeLanguage('pt', 'BR', selectedFlag);
              } else if (selectedFlag == languageController.UK_FLAG) {
                languageController.changeLanguage('en', 'US', selectedFlag);
              } else if (selectedFlag == languageController.SPAIN_FLAG) {
                languageController.changeLanguage('es', 'ES', selectedFlag);

              }
              print(Get.locale);

            },
            itemBuilder: (BuildContext context) => [
              _buildMenuItem(languageController.BRASIL_FLAG),
              _buildMenuItem(languageController.UK_FLAG),
              _buildMenuItem(languageController.SPAIN_FLAG),
            ],
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 20,
              backgroundImage: AssetImage(languageController.flagImagePath.value),
            ),
          ),
        )),
      ],

      elevation: 4,
    );
  }

  PopupMenuItem<String> _buildMenuItem(String flagPath) {
    return PopupMenuItem<String>(
      value: flagPath,
      child: Row(
        children: [
          Image.asset(flagPath, width: 25, height: 25),
          const SizedBox(width: 10),
          Text(_getFlagName(flagPath)),
        ],
      ),
    );
  }

  String _getFlagName(String flagPath) {
    if (flagPath.contains("brasil")) return "Português";
    if (flagPath.contains("uk")) return "English";
    if (flagPath.contains("spain")) return "Español";
    return "Desconhecido";
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
