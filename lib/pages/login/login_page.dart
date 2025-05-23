import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/login/controllers/login_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/language_selector_button.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _loginCtrl = Get.find<LoginController>();

    return Stack(
      children: [
        WaveBackground(),
        // Formulário
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

                    // Logo
                    Image.asset('assets/images/logo.png', width: 300),

                    const SizedBox(height: 40),

                    // Campo de email
                    TextField(
                      controller: _loginCtrl.emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'email'.tr,
                        hintText: 'insert_email'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: "",
                      ),
                      maxLength: 255,
                    ),

                    const SizedBox(height: 16),

                    // Campo de senha
                    TextField(
                      controller: _loginCtrl.passwordCtrl,
                      obscureText: true,

                      decoration: InputDecoration(
                        labelText: 'password'.tr,
                        hintText: 'insert_password'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: "",
                      ),
                      maxLength: 255,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'forgot_password'.tr,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Obx(() => AppButton(
                      label: "login_in".tr,
                      onPressed: _loginCtrl.isLoading.value ? null : _loginCtrl.login,
                      backgroundColor: AppColors.sapphire,
                      textColor: Colors.white,
                      width: 300,
                      isLoading: _loginCtrl.isLoading.value, // NOVO
                    )),

                    const SizedBox(height: 12),

                    AppButton(
                      label: "sign_in".tr,
                      onPressed: _loginCtrl.register,
                      backgroundColor: AppColors.muted_blue,
                      textColor: Colors.white,
                      width: 300,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 40,
          right: 16,
          child: LanguageSelectorButton(),
        ),
      ],
    );
  }


}
