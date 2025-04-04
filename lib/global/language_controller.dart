import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LanguageController extends GetxController {
  final String BRASIL_FLAG = "assets/images/brasil-circle-flag.png";
  final String UK_FLAG = "assets/images/uk-circle-flag.png";
  final String SPAIN_FLAG = "assets/images/spain-circle-flag.png";

  var flagImagePath = "".obs;

  @override
  void onInit() {
    super.onInit();

    final currentLocale = Get.locale ?? const Locale('pt', 'BR');
    Get.updateLocale(currentLocale);
    print(" AAA $currentLocale");
    if (currentLocale.languageCode == 'pt') {
      flagImagePath.value = BRASIL_FLAG;
    } else if (currentLocale.languageCode == 'en') {
      flagImagePath.value = UK_FLAG;
    } else if (currentLocale.languageCode == 'es') {
      flagImagePath.value = SPAIN_FLAG;
    } else {
      flagImagePath.value = BRASIL_FLAG; // fallback
    }
  }


  void changeLanguage(String langCode, String countryCode, String flag) {
    flagImagePath.value = flag; // Atualiza a bandeira
    Get.updateLocale(Locale(langCode, countryCode)); // Atualiza o idioma do app
  }
}
