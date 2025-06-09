import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/profile/controllers/profile_controller.dart';
import 'package:park_wallet/pages/profile/pages/profile_edit_page.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/language_selector_button.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    return Stack(
      children: [
        WaveBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black,),
              onPressed: () => Get.back(),
            ),
            title: Text('my_profile'.tr, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Obx(() {
            if (controller.isLoadingData.value && controller.displayName.value.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (!controller.isLoadingData.value && controller.profileService.userProfile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'could_not_load_profile_data'.tr,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.3)),
            ),
            child: Text(
              value.isNotEmpty ? value : 'N/A'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}