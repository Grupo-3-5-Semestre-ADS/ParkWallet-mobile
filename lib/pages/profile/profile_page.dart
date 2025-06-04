import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';         // Ajuste o caminho se necessário
import 'package:park_wallet/pages/profile/controllers/profile_controller.dart';
import 'package:park_wallet/pages/profile/pages/profile_edit_page.dart'; // Ajuste o caminho se necessário
import 'package:park_wallet/pages/widgets/app_button.dart';             // Ajuste o caminho se necessário
import 'package:park_wallet/pages/widgets/language_selector_button.dart';// Ajuste o caminho se necessário
import 'package:park_wallet/pages/widgets/wave_background.dart';         // Ajuste o caminho se necessário

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Assume que ProfileController é injetado via Bindings ou Get.put anteriormente
    final ProfileController controller = Get.find<ProfileController>();

    // Opcional: Chamar _loadUserProfileData se esta página puder ser acessada
    // diretamente sem passar por uma rota que já o fez, ou se você quiser
    // garantir um refresh sempre que ela se tornar visível.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (controller.isLoadingData.value || controller.displayName.value.isEmpty) {
    //      controller._loadUserProfileData();
    //   }
    // });


    return Stack(
      children: [
        WaveBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('my_profile'.tr, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Obx(() { // Obx reagirá a isLoadingData e aos RxStrings (displayName, etc.)
            // Condição de carregamento inicial mais robusta
            if (controller.isLoadingData.value && controller.displayName.value.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            // Se não está carregando e o perfil no serviço ainda é nulo (após tentativa de carregamento)
            if (!controller.isLoadingData.value && controller.profileService.userProfile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'could_not_load_profile_data'.tr, // Mensagem mais específica
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logo.png', width: 180),
                      const SizedBox(height: 30),
                      _buildProfileDetailItem('full_name'.tr, controller.displayName.value),
                      _buildProfileDetailItem('cpf'.tr, controller.displayCpf.value),
                      _buildProfileDetailItem('email'.tr, controller.displayEmail.value),
                      _buildProfileDetailItem('birth_date'.tr, controller.displayBirthDate.value),
                      const SizedBox(height: 40),
                      AppButton(
                        label: 'edit_profile'.tr,
                        onPressed: () {
                          // Antes de navegar, garante que os TextEditControllers no formulário
                          // estão sincronizados com os dados mais recentes (caso o usuário navegue
                          // para trás e para frente sem salvar).
                          // _populateDisplayFieldsAndControllers já faz isso ao carregar.
                          // Se for um caso de uso complexo, pode ser necessário chamar
                          // controller._populateDisplayFieldsAndControllers() aqui também,
                          // ou pelo menos sincronizar os TextEditControllers.
                          Get.to(() => const ProfileEditPage());
                        },
                        backgroundColor: AppColors.sapphire,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        Positioned(
          top: kToolbarHeight / 4,
          right: 16,
          child: LanguageSelectorButton(),
        ),
      ],
    );
  }

  Widget _buildProfileDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15), // Ajuste a opacidade para contraste
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.25)), // Ajuste a opacidade
            ),
            child: Text(
              value.isNotEmpty ? value : 'N/A'.tr, // Traduzir 'N/A' se necessário
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}