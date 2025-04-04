import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/global/language_controller.dart';
import 'package:park_wallet/pages/login/controllers/login_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/language_selector_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _loginCtrl = Get.find<LoginController>();
    final _languageCtrl = Get.find<LanguageController>();

    return Stack(
      children: [
        Container(color: AppColors.white),

        // SVG waves no fundo
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                'assets/images/bottom_waves.svg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ),

        // Botão de idioma no canto superior direito

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

                    AppButton(
                      label: "login_in".tr,
                      onPressed: _loginCtrl.login,
                      backgroundColor: AppColors.sapphire,
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 12),

                    AppButton(
                      label: "sign_in".tr,
                      onPressed: _loginCtrl.register,
                      backgroundColor: AppColors.muted_blue,
                      textColor: Colors.white,
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
