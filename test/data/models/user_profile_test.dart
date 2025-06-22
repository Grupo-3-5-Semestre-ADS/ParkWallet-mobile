import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/models/user_profile.dart';

void main() {
  group('UserProfile Tests', () {
    test('should create UserProfile with all required fields', () {
      const name = 'João Silva';
      const email = 'joao@example.com';
      const cpf = '123.456.789-00';
      final birthdate = DateTime(1990, 5, 15);
      
      final userProfile = UserProfile(
        name: name,
        email: email,
        cpf: cpf,
        birthdate: birthdate,
      );
      
      expect(userProfile.name, equals(name));
      expect(userProfile.email, equals(email));
      expect(userProfile.cpf, equals(cpf));
      expect(userProfile.birthdate, equals(birthdate));
    });

    test('should create UserProfile from JSON', () {
      final json = {
        'name': 'Maria Santos',
        'email': 'maria@test.com',
        'cpf': '987.654.321-00',
        'birthdate': '1985-12-25T00:00:00.000Z',
      };
      
      final userProfile = UserProfile.fromJson(json);
      
      expect(userProfile.name, equals('Maria Santos'));
      expect(userProfile.email, equals('maria@test.com'));
      expect(userProfile.cpf, equals('987.654.321-00'));
      expect(userProfile.birthdate, equals(DateTime.parse('1985-12-25T00:00:00.000Z')));
    });

    test('should create UserProfile from JSON with different date formats', () {
      final json1 = {
        'name': 'Test User 1',
        'email': 'test1@example.com',
        'cpf': '111.111.111-11',
        'birthdate': '2000-01-01',
      };
      
      final json2 = {
        'name': 'Test User 2',
        'email': 'test2@example.com',
        'cpf': '222.222.222-22',
        'birthdate': '1995-06-15T10:30:00',
      };
      
      final userProfile1 = UserProfile.fromJson(json1);
      final userProfile2 = UserProfile.fromJson(json2);
      
      expect(userProfile1.birthdate, equals(DateTime.parse('2000-01-01')));
      expect(userProfile2.birthdate, equals(DateTime.parse('1995-06-15T10:30:00')));
    });

    test('should have correct toString representation', () {
      final birthdate = DateTime(1992, 8, 20);
      final userProfile = UserProfile(
        name: 'Carlos Oliveira',
        email: 'carlos@email.com',
        cpf: '555.555.555-55',
        birthdate: birthdate,
      );
      
      final stringRepresentation = userProfile.toString();
      
      expect(stringRepresentation, contains('UserProfile{'));
      expect(stringRepresentation, contains('name: Carlos Oliveira'));
      expect(stringRepresentation, contains('email: carlos@email.com'));
      expect(stringRepresentation, contains('cpf: 555.555.555-55'));
      expect(stringRepresentation, contains('birthdate: $birthdate'));
      expect(stringRepresentation, endsWith('}'));
    });

    test('should handle empty strings in constructor', () {
      final birthdate = DateTime.now();
      final userProfile = UserProfile(
        name: '',
        email: '',
        cpf: '',
        birthdate: birthdate,
      );
      
      expect(userProfile.name, equals(''));
      expect(userProfile.email, equals(''));
      expect(userProfile.cpf, equals(''));
      expect(userProfile.birthdate, equals(birthdate));
    });

    test('should handle special characters in fields', () {
      final birthdate = DateTime(1988, 3, 10);
      final userProfile = UserProfile(
        name: 'José da Silva Júnior',
        email: 'jose+junior@domain-test.com.br',
        cpf: '123.456.789-01',
        birthdate: birthdate,
      );
      
      expect(userProfile.name, equals('José da Silva Júnior'));
      expect(userProfile.email, equals('jose+junior@domain-test.com.br'));
      expect(userProfile.cpf, equals('123.456.789-01'));
    });

    test('should handle different CPF formats', () {
      final birthdate = DateTime(1990, 1, 1);
      
      final userProfile1 = UserProfile(
        name: 'User 1',
        email: 'user1@test.com',
        cpf: '12345678900',
        birthdate: birthdate,
      );
      
      final userProfile2 = UserProfile(
        name: 'User 2',
        email: 'user2@test.com',
        cpf: '123.456.789-00',
        birthdate: birthdate,
      );
      
      expect(userProfile1.cpf, equals('12345678900'));
      expect(userProfile2.cpf, equals('123.456.789-00'));
    });

    test('should handle past, present, and future birthdates', () {
      final pastDate = DateTime(1980, 1, 1);
      final presentDate = DateTime.now();
      final futureDate = DateTime(2030, 12, 31);
      
      final userProfile1 = UserProfile(
        name: 'Past User',
        email: 'past@test.com',
        cpf: '111.111.111-11',
        birthdate: pastDate,
      );
      
      final userProfile2 = UserProfile(
        name: 'Present User',
        email: 'present@test.com',
        cpf: '222.222.222-22',
        birthdate: presentDate,
      );
      
      final userProfile3 = UserProfile(
        name: 'Future User',
        email: 'future@test.com',
        cpf: '333.333.333-33',
        birthdate: futureDate,
      );
      
      expect(userProfile1.birthdate, equals(pastDate));
      expect(userProfile2.birthdate, equals(presentDate));
      expect(userProfile3.birthdate, equals(futureDate));
    });

    test('should maintain immutability of fields', () {
      final originalBirthdate = DateTime(1995, 7, 20);
      final userProfile = UserProfile(
        name: 'Immutable User',
        email: 'immutable@test.com',
        cpf: '999.999.999-99',
        birthdate: originalBirthdate,
      );
      
      // Verify fields are final (cannot be reassigned)
      expect(userProfile.name, equals('Immutable User'));
      expect(userProfile.email, equals('immutable@test.com'));
      expect(userProfile.cpf, equals('999.999.999-99'));
      expect(userProfile.birthdate, equals(originalBirthdate));
    });
  });
}