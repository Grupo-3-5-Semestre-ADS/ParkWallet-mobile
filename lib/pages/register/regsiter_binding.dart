import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/register/controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
  }
}
