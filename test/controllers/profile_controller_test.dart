import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:park_wallet/data/dto/user_profile_update_request.dart';
import 'package:park_wallet/pages/profile/controllers/profile_controller.dart';
import 'package:park_wallet/repositories/profile_repository.dart';
import 'package:park_wallet/services/profile_service.dart';
import 'package:park_wallet/data/models/user_profile.dart';

import 'profile_controller_test.mocks.dart';

@GenerateMocks([ProfileRepository, ProfileService])
void main() {
  group('ProfileController Tests', () {
    late ProfileController profileController;
    late MockProfileRepository mockProfileRepository;
    late MockProfileService mockProfileService;
    late UserProfile testUserProfile;

    setUp(() {
      Get.testMode = true;
      mockProfileRepository = MockProfileRepository();
      mockProfileService = MockProfileService();
      
      testUserProfile = UserProfile(
        id: 1,
        name: 'João Silva',
        cpf: '12345678901',
        email: 'joao.silva@email.com',
        birthdate: DateTime(1990, 5, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Register the mock service
      Get.put<ProfileService>(mockProfileService);
      
      profileController = ProfileController();
      profileController.profileService = mockProfileService;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(profileController.displayName.value, isEmpty);
        expect(profileController.displayCpf.value, isEmpty);
        expect(profileController.displayEmail.value, isEmpty);
        expect(profileController.displayBirthDate.value, isEmpty);
        expect(profileController.isLoadingData.value, isTrue);
        expect(profileController.isSaving.value, isFalse);
        expect(profileController.selectedDate.value, isNull);
      });

      test('should load user profile data on init', () async {
        // Arrange
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockProfileService.refreshProfile()).called(1);
        expect(profileController.displayName.value, equals('João Silva'));
        expect(profileController.displayEmail.value, equals('joao.silva@email.com'));
        expect(profileController.nameCtrl.text, equals('João Silva'));
        expect(profileController.emailCtrl.text, equals('joao.silva@email.com'));
        expect(profileController.isLoadingData.value, isFalse);
      });

      test('should handle null user profile on init', () async {
        // Arrange
        when(mockProfileService.userProfile).thenReturn(null);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockProfileService.refreshProfile()).called(1);
        expect(profileController.displayName.value, isEmpty);
        expect(profileController.displayEmail.value, isEmpty);
        expect(profileController.nameCtrl.text, isEmpty);
        expect(profileController.emailCtrl.text, isEmpty);
        expect(profileController.isLoadingData.value, isFalse);
      });

      test('should handle error during profile loading', () async {
        // Arrange
        when(mockProfileService.refreshProfile())
            .thenThrow(Exception('Network error'));
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockProfileService.refreshProfile()).called(1);
        expect(profileController.isLoadingData.value, isFalse);
      });
    });

    group('Profile Data Population Tests', () {
      test('should populate display fields and controllers correctly', () async {
        // Arrange
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(profileController.nameCtrl.text, equals('João Silva'));
        expect(profileController.emailCtrl.text, equals('joao.silva@email.com'));
        expect(profileController.displayName.value, equals('João Silva'));
        expect(profileController.displayEmail.value, equals('joao.silva@email.com'));
        expect(profileController.selectedDate.value, equals(DateTime(1990, 5, 15)));
      });

      test('should format CPF correctly for display', () async {
        // Arrange
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(profileController.displayCpf.value, contains('123.456.789-01'));
        expect(profileController.cpfCtrl.text, contains('123.456.789-01'));
      });

      test('should handle user profile with null birthdate', () async {
        // Arrange
        final profileWithoutBirthdate = UserProfile(
          id: 1,
          name: 'João Silva',
          cpf: '12345678901',
          email: 'joao.silva@email.com',
          birthdate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        when(mockProfileService.userProfile).thenReturn(profileWithoutBirthdate);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(profileController.selectedDate.value, isNull);
        expect(profileController.dateCtrl.text, isEmpty);
        expect(profileController.displayBirthDate.value, equals('not_set'));
      });

      test('should format date correctly', () async {
        // Arrange
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(profileController.dateCtrl.text, isNotEmpty);
        expect(profileController.displayBirthDate.value, isNotEmpty);
        expect(profileController.displayBirthDate.value, contains('15'));
        expect(profileController.displayBirthDate.value, contains('05'));
        expect(profileController.displayBirthDate.value, contains('1990'));
      });
    });

    group('Profile Update Tests', () {
      setUp(() async {
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should update profile successfully', () async {
        // Arrange
        profileController.nameCtrl.text = 'João Santos';
        profileController.emailCtrl.text = 'joao.santos@email.com';
        profileController.selectedDate.value = DateTime(1985, 10, 20);
        
        when(mockProfileService.updateProfile(any))
            .thenAnswer((_) async {});
        when(mockProfileService.refreshProfile())
            .thenAnswer((_) async {});
        
        // Act
        await profileController.saveProfile();
        
        // Assert
        verify(mockProfileService.updateProfile(any)).called(1);
        verify(mockProfileService.refreshProfile()).called(2); // Once on init, once after save
        expect(profileController.isSaving.value, isFalse);
      });

      test('should handle profile update error', () async {
        // Arrange
        profileController.nameCtrl.text = 'João Santos';
        
        when(mockProfileService.updateProfile(any))
            .thenThrow(Exception('Update failed'));
        
        // Act
        await profileController.saveProfile();
        
        // Assert
        verify(mockProfileService.updateProfile(any)).called(1);
        expect(profileController.isSaving.value, isFalse);
      });

      test('should set loading state during profile update', () async {
        // Arrange
        profileController.nameCtrl.text = 'João Santos';
        
        when(mockProfileService.updateProfile(any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
        });
        when(mockProfileService.refreshProfile())
            .thenAnswer((_) async {});
        
        // Act
        final future = profileController.saveProfile();
        
        // Assert - should be saving
        expect(profileController.isSaving.value, isTrue);
        
        await future;
        
        // Assert - should not be saving after completion
        expect(profileController.isSaving.value, isFalse);
      });

      test('should create correct UserProfileUpdateRequest', () async {
        // Arrange
        profileController.nameCtrl.text = 'João Santos';
        profileController.emailCtrl.text = 'joao.santos@email.com';
        profileController.selectedDate.value = DateTime(1985, 10, 20);
        
        UserProfileUpdateRequest? capturedRequest;
        when(mockProfileService.updateProfile(any))
            .thenAnswer((invocation) async {
          capturedRequest = invocation.positionalArguments[0] as UserProfileUpdateRequest;
        });
        when(mockProfileService.refreshProfile())
            .thenAnswer((_) async {});
        
        // Act
        await profileController.saveProfile();
        
        // Assert
        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.name, equals('João Santos'));
        expect(capturedRequest!.email, equals('joao.santos@email.com'));
        expect(capturedRequest!.birthDate, equals(DateTime(1985, 10, 20)));
      });
    });

    group('Form Validation Tests', () {
      setUp(() async {
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should validate name field', () {
        // Test empty name
        profileController.nameCtrl.text = '';
        expect(profileController.validateName(''), isNotNull);
        
        // Test valid name
        profileController.nameCtrl.text = 'João Silva';
        expect(profileController.validateName('João Silva'), isNull);
        
        // Test name with numbers
        expect(profileController.validateName('João123'), isNotNull);
        
        // Test very short name
        expect(profileController.validateName('Jo'), isNotNull);
        
        // Test very long name
        final longName = 'A' * 101;
        expect(profileController.validateName(longName), isNotNull);
      });

      test('should validate email field', () {
        // Test empty email
        expect(profileController.validateEmail(''), isNotNull);
        
        // Test valid email
        expect(profileController.validateEmail('test@email.com'), isNull);
        
        // Test invalid email format
        expect(profileController.validateEmail('invalid-email'), isNotNull);
        expect(profileController.validateEmail('test@'), isNotNull);
        expect(profileController.validateEmail('@email.com'), isNotNull);
        
        // Test email with special characters
        expect(profileController.validateEmail('test+tag@email.com'), isNull);
      });

      test('should validate date field', () {
        // Test future date
        final futureDate = DateTime.now().add(const Duration(days: 1));
        expect(profileController.validateDate(futureDate), isNotNull);
        
        // Test valid past date
        final pastDate = DateTime(1990, 5, 15);
        expect(profileController.validateDate(pastDate), isNull);
        
        // Test underage date (less than 18 years)
        final underageDate = DateTime.now().subtract(const Duration(days: 365 * 17));
        expect(profileController.validateDate(underageDate), isNotNull);
        
        // Test very old date
        final veryOldDate = DateTime(1900, 1, 1);
        expect(profileController.validateDate(veryOldDate), isNotNull);
      });

      test('should prevent saving with invalid data', () async {
        // Arrange
        profileController.nameCtrl.text = ''; // Invalid name
        profileController.emailCtrl.text = 'invalid-email'; // Invalid email
        
        // Act
        await profileController.saveProfile();
        
        // Assert
        verifyNever(mockProfileService.updateProfile(any));
        expect(profileController.isSaving.value, isFalse);
      });
    });

    group('Date Handling Tests', () {
      test('should select date correctly', () async {
        // Arrange
        final selectedDate = DateTime(1985, 12, 25);
        
        // Act
        profileController.selectDate(selectedDate);
        
        // Assert
        expect(profileController.selectedDate.value, equals(selectedDate));
        expect(profileController.dateCtrl.text, isNotEmpty);
      });

      test('should clear date correctly', () {
        // Arrange
        profileController.selectedDate.value = DateTime(1990, 5, 15);
        profileController.dateCtrl.text = '15/05/1990';
        
        // Act
        profileController.clearDate();
        
        // Assert
        expect(profileController.selectedDate.value, isNull);
        expect(profileController.dateCtrl.text, isEmpty);
      });

      test('should format date correctly for different locales', () {
        // Test Brazilian format
        final date = DateTime(1990, 5, 15);
        final formattedDate = profileController.formatDate(date);
        
        expect(formattedDate, contains('15'));
        expect(formattedDate, contains('05'));
        expect(formattedDate, contains('1990'));
      });

      test('should handle leap year dates', () {
        // Test leap year date
        final leapYearDate = DateTime(2020, 2, 29);
        
        profileController.selectDate(leapYearDate);
        
        expect(profileController.selectedDate.value, equals(leapYearDate));
        expect(profileController.dateCtrl.text, contains('29'));
        expect(profileController.dateCtrl.text, contains('02'));
        expect(profileController.dateCtrl.text, contains('2020'));
      });
    });

    group('CPF Formatting Tests', () {
      test('should format CPF correctly', () {
        // Test standard CPF
        final formattedCpf = profileController.formatCpfForDisplay('12345678901');
        expect(formattedCpf, equals('123.456.789-01'));
        
        // Test CPF with leading zeros
        final formattedCpfWithZeros = profileController.formatCpfForDisplay('00123456789');
        expect(formattedCpfWithZeros, equals('001.234.567-89'));
      });

      test('should handle invalid CPF formats', () {
        // Test short CPF
        final shortCpf = profileController.formatCpfForDisplay('123456789');
        expect(shortCpf, equals('123456789')); // Should return as-is if invalid
        
        // Test long CPF
        final longCpf = profileController.formatCpfForDisplay('123456789012');
        expect(longCpf, equals('123456789012')); // Should return as-is if invalid
        
        // Test empty CPF
        final emptyCpf = profileController.formatCpfForDisplay('');
        expect(emptyCpf, equals(''));
      });

      test('should handle CPF with special characters', () {
        // Test already formatted CPF
        final alreadyFormatted = profileController.formatCpfForDisplay('123.456.789-01');
        expect(alreadyFormatted, equals('123.456.789-01'));
        
        // Test CPF with mixed characters
        final mixedCpf = profileController.formatCpfForDisplay('123abc456def789');
        expect(mixedCpf, equals('123abc456def789')); // Should return as-is if invalid
      });
    });

    group('Email Management Tests', () {
      setUp(() async {
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile()).thenAnswer((_) async {});
        
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should track original email correctly', () {
        expect(profileController.originalEmail, equals('joao.silva@email.com'));
      });

      test('should detect email changes', () {
        // Initially no change
        expect(profileController.hasEmailChanged, isFalse);
        
        // Change email
        profileController.emailCtrl.text = 'new.email@test.com';
        expect(profileController.hasEmailChanged, isTrue);
        
        // Revert to original
        profileController.emailCtrl.text = 'joao.silva@email.com';
        expect(profileController.hasEmailChanged, isFalse);
      });

      test('should handle email update failure gracefully', () async {
        // Arrange
        profileController.emailCtrl.text = 'new.email@test.com';
        
        when(mockProfileService.updateProfile(any))
            .thenThrow(Exception('Email already exists'));
        
        // Act
        await profileController.saveProfile();
        
        // Assert
        expect(profileController.isSaving.value, isFalse);
        // Email should remain changed in the field for user to correct
        expect(profileController.emailCtrl.text, equals('new.email@test.com'));
      });
    });

    group('Edge Cases and Integration Tests', () {
      test('should handle very long names', () async {
        // Arrange
        final longName = 'A' * 200;
        profileController.nameCtrl.text = longName;
        
        // Act & Assert
        expect(profileController.validateName(longName), isNotNull);
      });

      test('should handle special characters in name', () {
        // Test names with accents
        expect(profileController.validateName('José María'), isNull);
        expect(profileController.validateName('François'), isNull);
        expect(profileController.validateName('Müller'), isNull);
        
        // Test names with hyphens and apostrophes
        expect(profileController.validateName('Mary-Jane'), isNull);
        expect(profileController.validateName("O'Connor"), isNull);
      });

      test('should handle concurrent save operations', () async {
        // Arrange
        when(mockProfileService.updateProfile(any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
        });
        when(mockProfileService.refreshProfile())
            .thenAnswer((_) async {});
        
        profileController.nameCtrl.text = 'New Name';
        
        // Act - try to save multiple times concurrently
        final future1 = profileController.saveProfile();
        final future2 = profileController.saveProfile();
        final future3 = profileController.saveProfile();
        
        await Future.wait([future1, future2, future3]);
        
        // Assert - should handle gracefully
        expect(profileController.isSaving.value, isFalse);
      });

      test('should handle memory management correctly', () {
        // Arrange
        final controller = ProfileController();
        
        // Act
        controller.onInit();
        controller.onClose();
        
        // Assert - no memory leaks or exceptions
        expect(controller.isClosed, isTrue);
        expect(controller.nameCtrl.text, isEmpty);
        expect(controller.emailCtrl.text, isEmpty);
        expect(controller.dateCtrl.text, isEmpty);
      });

      test('should maintain state consistency during errors', () async {
        // Arrange
        when(mockProfileService.userProfile).thenReturn(testUserProfile);
        when(mockProfileService.refreshProfile())
            .thenThrow(Exception('Network error'));
        
        // Act
        profileController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert - should handle gracefully
        expect(profileController.isLoadingData.value, isFalse);
        expect(profileController.isSaving.value, isFalse);
      });

      test('should handle profile refresh after successful update', () async {
        // Arrange
        profileController.nameCtrl.text = 'Updated Name';
        
        final updatedProfile = UserProfile(
          id: 1,
          name: 'Updated Name',
          cpf: '12345678901',
          email: 'joao.silva@email.com',
          birthdate: DateTime(1990, 5, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        when(mockProfileService.updateProfile(any))
            .thenAnswer((_) async {});
        when(mockProfileService.refreshProfile())
            .thenAnswer((_) async {});
        when(mockProfileService.userProfile)
            .thenReturn(updatedProfile);
        
        // Act
        await profileController.saveProfile();
        
        // Assert
        verify(mockProfileService.updateProfile(any)).called(1);
        verify(mockProfileService.refreshProfile()).called(2); // Init + after save
      });
    });
  });
}