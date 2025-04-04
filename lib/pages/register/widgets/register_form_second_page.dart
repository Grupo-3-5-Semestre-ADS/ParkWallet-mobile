import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/register/controllers/register_controller.dart';

class RegisterFormSecondPage extends GetView<RegisterController> {
  const RegisterFormSecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: controller.emailCtrl,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: 'email'.tr,
            hintText: 'email_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            counterText: "",
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.passwordCtrl,
          obscureText: true,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: 'password'.tr,
            hintText: 'password_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            counterText: "",
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.repeatPasswordCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'confirm_password'.tr,
            hintText: 'confirm_password_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: "back".tr,
                onPressed: controller.prevPage,
                backgroundColor: AppColors.sapphire,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: "finish".tr,
                onPressed: controller.register,
                backgroundColor: AppColors.green,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
