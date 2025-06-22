import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/dto/login_request.dart';

void main() {
  group('LoginRequest Tests', () {
    test('should create LoginRequest with required fields', () {
      const email = 'test@example.com';
      const password = 'password123';
      
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );
      
      expect(loginRequest.email, equals(email));
      expect(loginRequest.password, equals(password));
    });

    test('should convert to map correctly', () {
      const email = 'user@test.com';
      const password = 'mypassword';
      
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );
      
      final map = loginRequest.toMap();
      
      expect(map, isA<Map<String, dynamic>>());
      expect(map['email'], equals(email));
      expect(map['password'], equals(password));
      expect(map.length, equals(2));
    });

    test('should handle empty email and password', () {
      final loginRequest = LoginRequest(
        email: '',
        password: '',
      );
      
      expect(loginRequest.email, equals(''));
      expect(loginRequest.password, equals(''));
      
      final map = loginRequest.toMap();
      expect(map['email'], equals(''));
      expect(map['password'], equals(''));
    });

    test('should handle special characters in email and password', () {
      const email = 'user+test@example-domain.com';
      const password = 'P@ssw0rd!123';
      
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );
      
      expect(loginRequest.email, equals(email));
      expect(loginRequest.password, equals(password));
      
      final map = loginRequest.toMap();
      expect(map['email'], equals(email));
      expect(map['password'], equals(password));
    });

    test('should allow modification of email and password', () {
      final loginRequest = LoginRequest(
        email: 'initial@email.com',
        password: 'initialPassword',
      );
      
      // Modify fields
      loginRequest.email = 'new@email.com';
      loginRequest.password = 'newPassword';
      
      expect(loginRequest.email, equals('new@email.com'));
      expect(loginRequest.password, equals('newPassword'));
      
      final map = loginRequest.toMap();
      expect(map['email'], equals('new@email.com'));
      expect(map['password'], equals('newPassword'));
    });

    test('should maintain data integrity after multiple toMap calls', () {
      final loginRequest = LoginRequest(
        email: 'consistent@test.com',
        password: 'consistentPassword',
      );
      
      final map1 = loginRequest.toMap();
      final map2 = loginRequest.toMap();
      final map3 = loginRequest.toMap();
      
      expect(map1, equals(map2));
      expect(map2, equals(map3));
      expect(map1['email'], equals('consistent@test.com'));
      expect(map1['password'], equals('consistentPassword'));
    });

    test('should create valid JSON-serializable map', () {
      final loginRequest = LoginRequest(
        email: 'json@test.com',
        password: 'jsonPassword',
      );
      
      final map = loginRequest.toMap();
      
      // Verify all values are JSON-serializable
      expect(map['email'], isA<String>());
      expect(map['password'], isA<String>());
      
      // Verify no null values
      expect(map.values.every((value) => value != null), isTrue);
    });
  });
}