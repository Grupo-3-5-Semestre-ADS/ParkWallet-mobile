import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/login/controllers/login_controller.dart';
import 'package:park_wallet/pages/register/controllers/register_controller.dart';
import 'package:park_wallet/pages/register/widgets/register_form_first_page.dart';
import 'package:park_wallet/pages/register/widgets/register_form_second_page.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/language_selector_button.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.white),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 150, // Altura máxima
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.fill, // Estica na horizontal e vertical se necessário
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                'assets/images/bottom_waves.svg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', width: 250),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 300,
                      child: PageView(
                        controller: controller.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) => controller.currentPage.value = index,
                        children: const [
                          RegisterFormFirstPage(),
                          RegisterFormSecondPage(),
                        ],
                      ),
                    ),
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
