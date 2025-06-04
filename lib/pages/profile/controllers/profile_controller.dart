import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/data/dto/user_profile_update_request.dart'; // Ajuste o caminho se necessário
import 'package:park_wallet/repositories/profile_repository.dart';      // Ajuste o caminho se necessário
import 'package:park_wallet/services/profile_service.dart';          // Ajuste o caminho se necessário
// Placeholder para seu modelo UserProfile, se ProfileService não o expuser diretamente
// import 'package:park_wallet/models/user_profile.dart'; // Exemplo

class ProfileController extends GetxController {
  // Repositories and Services
  final ProfileRepository _profileRepository = ProfileRepository();
  final ProfileService profileService = Get.find<ProfileService>();

  // Para o Formulário de Edição
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController cpfCtrl = TextEditingController(); // Usado para preenchimento inicial
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // Para Exibição na ProfilePage (reativo)
  RxString displayName = ''.obs;
  RxString displayCpf = ''.obs;
  RxString displayEmail = ''.obs;
  RxString displayBirthDate = ''.obs;

  String _originalEmail = ""; // Último e-mail salvo com sucesso
  String _emailBeforeEditAttempt = ""; // Valor do campo de e-mail antes de tentar salvar

  // State
  RxBool isLoadingData = true.obs;
  RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfileData();
  }

  Future<void> _populateDisplayFieldsAndControllers() async {
    // Assume que profileService.userProfile é o seu modelo de dados do usuário
    // Se UserProfile não for diretamente acessível, ajuste conforme necessário.
    // Exemplo: final UserProfile? userProfile = profileService.getCurrentUserProfile();
    final userProfile = profileService.userProfile;

    if (userProfile != null) {
      // Popula TextEditingControllers para o formulário
      nameCtrl.text = userProfile.name;
      cpfCtrl.text = _formatCpfForDisplay(userProfile.cpf);
      emailCtrl.text = userProfile.email;
      _originalEmail = userProfile.email;
      _emailBeforeEditAttempt = userProfile.email;

      // Popula RxStrings para exibição
      displayName.value = userProfile.name;
      displayCpf.value = _formatCpfForDisplay(userProfile.cpf);
      displayEmail.value = userProfile.email;

      if (userProfile.birthdate != null) {
        selectedDate.value = userProfile.birthdate;
        final formattedDate = formatDate(userProfile.birthdate!);
        dateCtrl.text = formattedDate;
        displayBirthDate.value = formattedDate;
      } else {
        selectedDate.value = null;
        dateCtrl.text = '';
        displayBirthDate.value = 'not_set'.tr;
      }
    } else {
      // Limpa campos de exibição e controladores se não houver perfil
      nameCtrl.clear();
      cpfCtrl.clear();
      emailCtrl.clear();
      dateCtrl.clear();
      selectedDate.value = null;
      _originalEmail = "";
      _emailBeforeEditAttempt = "";

      displayName.value = '';
      displayCpf.value = '';
      displayEmail.value = '';
      displayBirthDate.value = 'not_set'.tr;
    }
  }

  Future<void> _loadUserProfileData() async {
    isLoadingData.value = true;
    log('[ProfileController] Carregando dados do perfil do usuário...');
    try {
      await profileService.refreshProfile(); // Busca os dados mais recentes
      await _populateDisplayFieldsAndControllers(); // Popula controladores e campos de exibição
    } catch (e, s) {
      log('[ProfileController] Erro ao carregar dados do perfil: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'problem_loading_your_data'.tr);
    } finally {
      isLoadingData.value = false;
      log('[ProfileController] Carregamento finalizado. isLoadingData: ${isLoadingData.value}');
    }
  }

  String _formatCpfForDisplay(String cpf) {
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
    }
    return cpf;
  }

  Future<void> saveProfile() async {
    _emailBeforeEditAttempt = emailCtrl.text.trim(); // Captura o e-mail atual do campo

    if (!_validateForm()) {
      return;
    }

    final String currentEmailInField = emailCtrl.text.trim(); // Usa o valor após _validateForm (que pode ter ajustado)
    final bool emailWasEffectivelyChangedByUser = (currentEmailInField != _originalEmail);

    if (emailWasEffectivelyChangedByUser) {
      Get.dialog(
        AlertDialog(
          title: Text('confirm_email_change_title'.tr),
          content: Text('confirm_email_change_message'.trParams({
            'newEmail': currentEmailInField,
            'oldEmail': _originalEmail,
          })),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Descarta o diálogo, não prossegue com o salvamento
                // Opcional: reverter o campo de e-mail para _originalEmail se o usuário cancelar aqui
                // emailCtrl.text = _originalEmail;
              },
              child: Text('cancel_button'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Descarta o diálogo
                _proceedWithSave(currentEmailInField, emailWasEffectivelyChangedByUser);
              },
              child: Text('confirm_button'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      _proceedWithSave(currentEmailInField, emailWasEffectivelyChangedByUser);
    }
  }

  Future<void> _proceedWithSave(String emailToSend, bool emailActuallyChangedDuringThisEditSession) async {
    isSaving.value = true;

    if (selectedDate.value == null && dateCtrl.text.isNotEmpty) {
      Get.snackbar('error'.tr, 'invalid_birth_date'.tr);
      isSaving.value = false;
      return;
    }
    if (selectedDate.value == null && dateCtrl.text.isEmpty) {
      Get.snackbar('error'.tr, 'birth_date_cannot_be_empty'.tr);
      isSaving.value = false;
      return;
    }

    final request = UserProfileUpdateRequest(
      name: nameCtrl.text.trim(),
      birthDate: _formatBirthdateForApi(selectedDate.value!),
      email: emailToSend,
    );

    try {
      log('[ProfileController] Payload da requisição de atualização: ${request.toJson()}');
      await _profileRepository.updateUserProfile(request);
      await profileService.refreshProfile(); // Atualiza os dados no serviço

      await _populateDisplayFieldsAndControllers(); // Re-popula todos os campos (controladores e RxStrings)

      Get.snackbar(
        'success'.tr,
        'profile_updated_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (emailActuallyChangedDuringThisEditSession) {
        Get.dialog(
          AlertDialog(
            title: Text('attention'.tr),
            content: Text('email_updated_login_notice'.trParams({
              'newEmail': emailToSend,
            })),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Fecha este diálogo de "Atenção"
                },
                child: Text('ok'.tr),
              ),
            ],
          ),
          barrierDismissible: false,
        ).then((_) {
          // Este bloco executa APÓS o diálogo de "Atenção" ser fechado.
          // Agora, navega de volta da ProfileEditPage para ProfilePage.
          Get.back();
        });
      } else {
        Get.back(); // Navega de volta da ProfileEditPage.
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_update_profile_try_again'.trParams({'error': e.toString()}));
      log('[ProfileController] Erro em _proceedWithSave(): $e');
    } finally {
      isSaving.value = false;
    }
  }

  void cancel() {
    // Reverte campos para o último estado salvo com sucesso
    _populateDisplayFieldsAndControllers().then((_) => Get.back());
    // Get.back();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'not_set'.tr; // Ou string vazia ''
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatBirthdateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'name_cannot_be_empty'.tr);
      return false;
    }
    if (nameCtrl.text.trim().length < 3) {
      Get.snackbar('error'.tr, 'name_min_3_chars'.tr);
      return false;
    }

    // Validação de e-mail usando _emailBeforeEditAttempt para garantir que validamos o que foi digitado
    final emailTrimmed = _emailBeforeEditAttempt; // Ou emailCtrl.text.trim() se preferir validar o estado atual do controller
    if (emailTrimmed.isEmpty) {
      Get.snackbar('error'.tr, 'email_cannot_be_empty'.tr);
      return false;
    }
    if (!GetUtils.isEmail(emailTrimmed)) {
      Get.snackbar('error'.tr, 'invalid_email_format'.tr);
      return false;
    }
    // Se a validação passou, podemos garantir que emailCtrl.text está limpo para o envio
    emailCtrl.text = emailTrimmed;


    if (dateCtrl.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'birth_date_cannot_be_empty'.tr);
      return false;
    }
    try {
      final parts = dateCtrl.text.split('/');
      if (parts.length != 3 || parts[0].length != 2 || parts[1].length != 2 || parts[2].length != 4) {
        Get.snackbar('invalid_date'.tr, 'date_format_dd_mm_yyyy'.tr);
        return false;
      }
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (year < 1900 || year > DateTime.now().year || month < 1 || month > 12 || day < 1 || day > 31) {
        Get.snackbar('invalid_date'.tr, 'please_enter_valid_date'.tr);
        return false;
      }
      final parsedDate = DateTime(year, month, day);

      if (parsedDate.isAfter(DateTime.now())) {
        Get.snackbar('invalid_date'.tr, 'birth_date_cannot_be_future'.tr);
        return false;
      }
      selectedDate.value = parsedDate;
    } catch (e) {
      Get.snackbar('invalid_date'.tr, 'please_enter_valid_date_format_dd_mm_yyyy'.tr);
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    cpfCtrl.dispose();
    emailCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }
}