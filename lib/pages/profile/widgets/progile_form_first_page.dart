// lib/pages/profile/widgets/profile_update_form.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/constants/input_formatters/date_input_formatter.dart';
import 'package:park_wallet/pages/profile/controllers/profile_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';

class ProfileUpdateForm extends GetView<ProfileController> {
  const ProfileUpdateForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingData.value && controller.nameCtrl.text.isEmpty) { // Check if truly loading initial data
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: controller.nameCtrl,
            decoration: InputDecoration(
              labelText: 'full_name'.tr,
              hintText: 'full_name_hint'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: "",
            ),
            maxLength: 255,
          ),
          const SizedBox(height: 16),
          // Birth Date Field
          TextField(
            controller: controller.dateCtrl,
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              DateInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'birth_date'.tr,
              hintText: 'dd_mm_yyyy'.tr,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  // ... (date picker logic remains the same)
                  try {
                    DateTime initialDatePickerDate = DateTime.now().subtract(const Duration(days: 365 * 18));
                    if (controller.selectedDate.value != null &&
                        controller.selectedDate.value!.isBefore(DateTime.now())) {
                      initialDatePickerDate = controller.selectedDate.value!;
                    } else {
                      final text = controller.dateCtrl.text;
                      final parts = text.split('/');
                      if (parts.length == 3) {
                        final day = int.tryParse(parts[0]);
                        final month = int.tryParse(parts[1]);
                        final year = int.tryParse(parts[2]);
                        if (day != null && month != null && year != null) {
                          final tempDate = DateTime(year, month, day);
                          if (tempDate.isBefore(DateTime.now())) {
                            initialDatePickerDate = tempDate;
                          }
                        }
                      }
                    }

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDatePickerDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: Get.locale,
                    );

                    if (picked != null) {
                      controller.selectedDate.value = picked;
                      controller.dateCtrl.text = controller.formatDate(picked);
                    }
                  } catch (e) {
                    log('Erro ao abrir o calendário: $e');
                    Get.snackbar('error'.tr, 'could_not_open_date_selector'.tr);
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              // Basic reactive parsing attempt for selectedDate for live validation
              final parts = value.split('/');
              if (parts.length == 3 &&
                  parts[0].length == 2 &&
                  parts[1].length == 2 &&
                  parts[2].length == 4) {
                try {
                  final day = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final year = int.parse(parts[2]);
                  final parsedDate = DateTime(year, month, day);
                  if (parsedDate.isBefore(DateTime.now().add(const Duration(days:1))) && parsedDate.year > 1899) {
                    // controller.selectedDate.value = parsedDate; // Let validation in controller handle final assignment
                  }
                } catch (_) {}
              } else {
                // If format is incorrect, clear selectedDate or handle as invalid
                // controller.selectedDate.value = null; // Or rely on save validation
              }
            },
          ),
          const SizedBox(height: 16),
          // Email Field (Editable)
          TextField(
            controller: controller.emailCtrl,
            keyboardType: TextInputType.emailAddress, // Set keyboard type
            decoration: InputDecoration(
              labelText: 'email'.tr,
              hintText: 'enter_your_email'.tr, // Add a hint
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // Removed readOnly and fillColor
            ),
          ),
          const SizedBox(height: 30),
          Obx(
                () => Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: "cancel".tr,
                    onPressed: controller.isSaving.value ? null : controller.cancel,
                    backgroundColor: AppColors.red,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: controller.isSaving.value ? "saving...".tr : "save".tr,
                    onPressed: controller.isSaving.value ? null : controller.saveProfile,
                    backgroundColor: AppColors.sapphire,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}