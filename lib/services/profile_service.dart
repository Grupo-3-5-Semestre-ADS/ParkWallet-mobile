import 'dart:developer';

import 'package:get/get.dart';
import 'package:park_wallet/data/models/user_profile.dart';
import 'package:park_wallet/repositories/profile_repository.dart';

class ProfileService extends GetxService {
  static UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  final ProfileRepository _profileRepository = ProfileRepository();

  Future<ProfileService> init() async {
    try {
      await _searchUserProfile();
    } catch (e) {
      log('[ProfileService] Erro ao buscar perfil: $e');
    }
    return this;
  }

  Future<void> _searchUserProfile() async {
    final profile = await _profileRepository.fetchUserProfile();
    _userProfile = profile;
    log('[ProfileService] Perfil carregado: ${profile}');
  }

  void clearProfile() {
    _userProfile = null;
  }
  Future<void> refreshProfile() async {
    try {
      await _searchUserProfile();
    } catch (e) {
      log('[ProfileService] Erro ao atualizar perfil: $e');
    }
  }
}
