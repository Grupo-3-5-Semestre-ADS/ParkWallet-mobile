import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/global/language_controller.dart';

class LanguageSelectorButton extends StatelessWidget {
  final LanguageController _languageCtrl = Get.find<LanguageController>();

  LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<Map<String, String>>(
        icon: Obx(
              () => Image.asset(
            _languageCtrl.flagImagePath.value,
            width: 50,
            height: 50,
          ),
        ),
        onSelected: (value) {
          _languageCtrl.changeLanguage(
            value['langCode']!,
            value['countryCode']!,
            value['flag']!,
          );
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: {
              'langCode': 'pt',
              'countryCode': 'BR',
              'flag': _languageCtrl.BRASIL_FLAG,
            },
            child: const Text('Português'),
          ),
          PopupMenuItem(
            value: {
              'langCode': 'en',
              'countryCode': 'US',
              'flag': _languageCtrl.UK_FLAG,
            },
            child: const Text('English'),
          ),
          PopupMenuItem(
            value: {
              'langCode': 'es',
              'countryCode': 'ES',
              'flag': _languageCtrl.SPAIN_FLAG,
            },
            child: const Text('Español'),
          ),
        ],
      ),
    );
  }
}
