import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/profile/controllers/profile_controller.dart';
import 'package:park_wallet/pages/profile/widgets/progile_form_first_page.dart';
import 'package:park_wallet/pages/widgets/language_selector_button.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class ProfileEditPage extends GetView<ProfileController> {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The controller is already found/managed by GetX,
    // typically because ProfileDisplayPage (or its binding) put it.

    return Stack(
      children: [
        WaveBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('update_profile'.tr, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white), // Back button will be white
            leading: IconButton( // Explicit back button to ensure consistent behavior
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', width: 180),
                    const SizedBox(height: 30),
                    // Use the existing form widget
                    const ProfileUpdateForm(), // This widget uses GetView<ProfileController>
                  ],
                ),
              ),
            ),
          ),
        ),
        // LanguageSelectorButton might be optional here if present on the display page
        // Or keep it if you want language selection on both screens.
        Positioned(
          top: kToolbarHeight / 4,
          right: 16,
          child: LanguageSelectorButton(),
        ),
      ],
    );
  }
}