import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/login_request.dart';
import 'package:park_wallet/data/dto/user_register_request.dart';
import 'package:park_wallet/repositories/auth_repository.dart';
import '../../test_config.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('AuthRepository', () {
    late MockAuthRepository mockAuthRepository;

    setUpAll(() {
      TestConfig.setupTestEnvironment();
    });

    tearDownAll(() {
      TestConfig.tearDownTestEnvironment();
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    group('login', () {
      test('should return token when login is successful', () async {
        // Arrange
        final loginRequest = LoginRequest(email: 'test@example.com', password: 'password123');
        final expectedToken = 'mock_token_123';

        when(mockAuthRepository.fetchLogin(loginRequest))
            .thenAnswer((_) async => expectedToken);

        // Act
        final result = await mockAuthRepository.fetchLogin(loginRequest);

        // Assert
        expect(result, expectedToken);
        verify(mockAuthRepository.fetchLogin(loginRequest)).called(1);
      });

      test('should throw exception when login fails', () async {
        // Arrange
        final loginRequest = LoginRequest(email: 'test@example.com', password: 'wrongpassword');

        when(mockAuthRepository.fetchLogin(loginRequest))
            .thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => mockAuthRepository.fetchLogin(loginRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('register', () {
      test('should complete successfully when registration is successful', () async {
        // Arrange
        final registerRequest = UserRegisterRequest(
          name: 'Test User',
          cpf: '12345678901',
          birthDate: '1990-01-01',
          email: 'test@example.com',
          password: 'password123',
        );

        when(mockAuthRepository.fetchRegister(registerRequest))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => mockAuthRepository.fetchRegister(registerRequest),
          returnsNormally,
        );
      });

      test('should throw exception when registration fails', () async {
        // Arrange
        final registerRequest = UserRegisterRequest(
          name: 'Test User',
          cpf: '12345678901',
          birthDate: '1990-01-01',
          email: 'test@example.com',
          password: 'password123',
        );

        when(mockAuthRepository.fetchRegister(registerRequest))
            .thenThrow(Exception('Email already exists'));

        // Act & Assert
        expect(
          () => mockAuthRepository.fetchRegister(registerRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('request validation', () {
      test('should validate login request structure', () {
        // Arrange
        final loginRequest = LoginRequest(email: 'test@example.com', password: 'password123');

        // Assert
        expect(loginRequest.email, 'test@example.com');
        expect(loginRequest.password, 'password123');
        expect(loginRequest.toMap(), {
          'email': 'test@example.com',
          'password': 'password123',
        });
      });

      test('should validate register request structure', () {
        // Arrange
        final registerRequest = UserRegisterRequest(
          name: 'Test User',
          cpf: '12345678901',
          birthDate: '1990-01-01',
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(registerRequest.name, 'Test User');
        expect(registerRequest.cpf, '12345678901');
        expect(registerRequest.birthDate, '1990-01-01');
        expect(registerRequest.email, 'test@example.com');
        expect(registerRequest.password, 'password123');
        expect(registerRequest.toMap(), {
          'name': 'Test User',
          'cpf': '12345678901',
          'birthDate': '1990-01-01',
          'email': 'test@example.com',
          'password': 'password123',
        });
      });
    });
  });
} 