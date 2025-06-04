import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/language_selector_button.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailCtrl = TextEditingController();
    final _isLoading = false.obs;

    return Stack(
      children: [
        WaveBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  Image.asset('assets/images/logo.png', width: 250),

                  const SizedBox(height: 40),

                  Text(
                    'enter_email_to_reset'.trParams({'email': 'email'}),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _emailCtrl,
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

                  const SizedBox(height: 24),

                  Obx(() => AppButton(
                    label: 'send'.tr,
                    onPressed: _isLoading.value
                        ? null
                        : () async {
                      final email = _emailCtrl.text;
                      final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                      if (email.isEmpty) {
                        Get.snackbar("Erro", "O campo de e-mail é obrigatório.");
                        return;
                      }

                      if (!emailRegex.hasMatch(email)) {
                        Get.snackbar("Erro", "Formato de e-mail inválido.");
                        return;
                      }

                      _isLoading.value = true;

                      try {
                        await Future.delayed(const Duration(seconds: 2));
                        Get.snackbar("Sucesso", "Link de recuperação enviado para o e-mail.");
                      } catch (e) {
                        Get.snackbar("Erro", "Erro ao enviar link de recuperação.");
                      } finally {
                        _isLoading.value = false;
                      }
                    },
                    backgroundColor: AppColors.sapphire,
                    textColor: Colors.white,
                    width: 300,
                    isLoading: _isLoading.value,
                  )),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'back_to_login'.tr,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
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
