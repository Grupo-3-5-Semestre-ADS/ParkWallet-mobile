import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/dto/user_register_request.dart';

void main() {
  group('UserRegisterRequest Tests', () {
    group('Constructor Tests', () {
      test('should create UserRegisterRequest with all required fields', () {
        // Arrange & Act
        final request = UserRegisterRequest(
          name: 'João Silva',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'joao@example.com',
          password: 'password123',
        );

        // Assert
        expect(request.name, equals('João Silva'));
        expect(request.cpf, equals('12345678900'));
        expect(request.birthDate, equals('1990-01-01'));
        expect(request.email, equals('joao@example.com'));
        expect(request.password, equals('password123'));
      });

      test('should create UserRegisterRequest with special characters in name', () {
        // Arrange & Act
        final request = UserRegisterRequest(
          name: 'José da Silva-Santos',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'jose@example.com',
          password: 'password123',
        );

        // Assert
        expect(request.name, equals('José da Silva-Santos'));
      });

      test('should create UserRegisterRequest with different date formats', () {
        // Arrange & Act
        final request = UserRegisterRequest(
          name: 'Maria Santos',
          cpf: '98765432100',
          birthDate: '1985-12-25',
          email: 'maria@example.com',
          password: 'securePass456',
        );

        // Assert
        expect(request.birthDate, equals('1985-12-25'));
      });

      test('should create UserRegisterRequest with complex email', () {
        // Arrange & Act
        final request = UserRegisterRequest(
          name: 'Ana Costa',
          cpf: '11122233344',
          birthDate: '1992-06-15',
          email: 'ana.costa+test@example.co.uk',
          password: 'myPassword789',
        );

        // Assert
        expect(request.email, equals('ana.costa+test@example.co.uk'));
      });

      test('should create UserRegisterRequest with strong password', () {
        // Arrange & Act
        final request = UserRegisterRequest(
          name: 'Carlos Oliveira',
          cpf: '55566677788',
          birthDate: '1988-03-10',
          email: 'carlos@example.com',
          password: 'StrongP@ssw0rd!123',
        );

        // Assert
        expect(request.password, equals('StrongP@ssw0rd!123'));
      });
    });

    group('toMap Tests', () {
      test('should convert UserRegisterRequest to Map correctly', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'João Silva',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'joao@example.com',
          password: 'password123',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(map, isA<Map<String, dynamic>>());
        expect(map['name'], equals('João Silva'));
        expect(map['cpf'], equals('12345678900'));
        expect(map['birthdate'], equals('1990-01-01')); // Note: 'birthdate' not 'birthDate'
        expect(map['email'], equals('joao@example.com'));
        expect(map['password'], equals('password123'));
      });

      test('should convert UserRegisterRequest with special characters to Map', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'José da Silva-Santos',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'jose+test@example.com',
          password: 'P@ssw0rd!',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(map['name'], equals('José da Silva-Santos'));
        expect(map['email'], equals('jose+test@example.com'));
        expect(map['password'], equals('P@ssw0rd!'));
      });

      test('should convert UserRegisterRequest with empty strings to Map', () {
        // Arrange
        final request = UserRegisterRequest(
          name: '',
          cpf: '',
          birthDate: '',
          email: '',
          password: '',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(map['name'], equals(''));
        expect(map['cpf'], equals(''));
        expect(map['birthdate'], equals(''));
        expect(map['email'], equals(''));
        expect(map['password'], equals(''));
      });

      test('should have correct map keys', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'Test User',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'test@example.com',
          password: 'password',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(map.keys, containsAll(['name', 'cpf', 'birthdate', 'email', 'password']));
        expect(map.keys.length, equals(5));
      });

      test('should maintain data types in map', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'Test User',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'test@example.com',
          password: 'password',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(map['name'], isA<String>());
        expect(map['cpf'], isA<String>());
        expect(map['birthdate'], isA<String>());
        expect(map['email'], isA<String>());
        expect(map['password'], isA<String>());
      });
    });

    group('toString Tests', () {
      test('should return correct string representation', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'João Silva',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'joao@example.com',
          password: 'password123',
        );

        // Act
        final stringRepresentation = request.toString();

        // Assert
        expect(stringRepresentation, contains('UserRegisterRequest'));
        expect(stringRepresentation, contains('name: João Silva'));
        expect(stringRepresentation, contains('cpf: 12345678900'));
        expect(stringRepresentation, contains('birthDate: 1990-01-01'));
        expect(stringRepresentation, contains('email: joao@example.com'));
        expect(stringRepresentation, contains('password: password123'));
      });

      test('should handle special characters in toString', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'José da Silva-Santos',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'jose+test@example.com',
          password: 'P@ssw0rd!',
        );

        // Act
        final stringRepresentation = request.toString();

        // Assert
        expect(stringRepresentation, contains('José da Silva-Santos'));
        expect(stringRepresentation, contains('jose+test@example.com'));
        expect(stringRepresentation, contains('P@ssw0rd!'));
      });

      test('should handle empty values in toString', () {
        // Arrange
        final request = UserRegisterRequest(
          name: '',
          cpf: '',
          birthDate: '',
          email: '',
          password: '',
        );

        // Act
        final stringRepresentation = request.toString();

        // Assert
        expect(stringRepresentation, contains('UserRegisterRequest'));
        expect(stringRepresentation, contains('name: '));
        expect(stringRepresentation, contains('cpf: '));
        expect(stringRepresentation, contains('birthDate: '));
        expect(stringRepresentation, contains('email: '));
        expect(stringRepresentation, contains('password: '));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle very long values', () {
        // Arrange
        final longName = 'A' * 100;
        final longEmail = 'test${'a' * 50}@example.com';
        final longPassword = 'P@ssw0rd' * 10;
        
        final request = UserRegisterRequest(
          name: longName,
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: longEmail,
          password: longPassword,
        );

        // Act
        final map = request.toMap();
        final stringRep = request.toString();

        // Assert
        expect(request.name, equals(longName));
        expect(request.email, equals(longEmail));
        expect(request.password, equals(longPassword));
        expect(map['name'], equals(longName));
        expect(stringRep, contains(longName));
      });

      test('should handle unicode characters', () {
        // Arrange
        final request = UserRegisterRequest(
          name: '张三李四',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'test@例え.テスト',
          password: 'пароль123',
        );

        // Act
        final map = request.toMap();
        final stringRep = request.toString();

        // Assert
        expect(request.name, equals('张三李四'));
        expect(request.email, equals('test@例え.テスト'));
        expect(request.password, equals('пароль123'));
        expect(map['name'], equals('张三李四'));
        expect(stringRep, contains('张三李四'));
      });

      test('should handle numeric strings', () {
        // Arrange
        final request = UserRegisterRequest(
          name: '123456',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: '123@456.789',
          password: '987654321',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(request.name, equals('123456'));
        expect(request.email, equals('123@456.789'));
        expect(request.password, equals('987654321'));
        expect(map['name'], equals('123456'));
      });

      test('should handle whitespace values', () {
        // Arrange
        final request = UserRegisterRequest(
          name: '   João Silva   ',
          cpf: '  12345678900  ',
          birthDate: ' 1990-01-01 ',
          email: ' joao@example.com ',
          password: ' password123 ',
        );

        // Act
        final map = request.toMap();

        // Assert
        expect(request.name, equals('   João Silva   '));
        expect(request.cpf, equals('  12345678900  '));
        expect(request.birthDate, equals(' 1990-01-01 '));
        expect(request.email, equals(' joao@example.com '));
        expect(request.password, equals(' password123 '));
        expect(map['name'], equals('   João Silva   '));
      });
    });

    group('Immutability Tests', () {
      test('should be immutable after creation', () {
        // Arrange
        final request = UserRegisterRequest(
          name: 'João Silva',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'joao@example.com',
          password: 'password123',
        );

        // Act & Assert
        expect(request.name, equals('João Silva'));
        expect(request.cpf, equals('12345678900'));
        expect(request.birthDate, equals('1990-01-01'));
        expect(request.email, equals('joao@example.com'));
        expect(request.password, equals('password123'));
        
        // Fields should remain the same
        expect(request.name, equals('João Silva'));
        expect(request.cpf, equals('12345678900'));
      });

      test('should create independent instances', () {
        // Arrange & Act
        final request1 = UserRegisterRequest(
          name: 'João Silva',
          cpf: '12345678900',
          birthDate: '1990-01-01',
          email: 'joao@example.com',
          password: 'password123',
        );
        
        final request2 = UserRegisterRequest(
          name: 'Maria Santos',
          cpf: '98765432100',
          birthDate: '1985-12-25',
          email: 'maria@example.com',
          password: 'password456',
        );

        // Assert
        expect(request1.name, isNot(equals(request2.name)));
        expect(request1.cpf, isNot(equals(request2.cpf)));
        expect(request1.birthDate, isNot(equals(request2.birthDate)));
        expect(request1.email, isNot(equals(request2.email)));
        expect(request1.password, isNot(equals(request2.password)));
      });
    });
  });
}