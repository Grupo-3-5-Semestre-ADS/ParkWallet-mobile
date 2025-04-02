import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/services/AuthService.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _login() {
    final authService = Get.find<AuthService>();
    authService.saveToken('token-jwt-falso');
    Get.offAllNamed('/home');
  }

  void _register() {
    Get.toNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              'assets/images/bottom_waves.svg',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 300,
                    ),

                    const SizedBox(height: 40),

                    // Campo de login
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Insira seu email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Campo de senha
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Insira sua senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Esqueceu a senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // lógica de esqueceu a senha
                        },
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão Entrar
                    AppButton(
                      label: "Entrar",
                      onPressed: _login,
                      backgroundColor: AppColors.sapphire,
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 12),

                    // Botão Cadastrar-se
                    AppButton(
                      label: "Cadastrar-se",
                      onPressed: _register,
                      backgroundColor: AppColors.muted_blue,
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
