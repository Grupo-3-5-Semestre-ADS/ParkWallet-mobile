import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/global/custom_exception.dart';

void main() {
  group('CustomException Tests', () {
    test('should create exception with message', () {
      const testMessage = 'Test error message';
      final exception = CustomException(testMessage);
      
      expect(exception.message, testMessage);
    });

    test('should return message when toString is called', () {
      const testMessage = 'Another test error';
      final exception = CustomException(testMessage);
      
      expect(exception.toString(), testMessage);
    });

    test('should implement Exception interface', () {
      final exception = CustomException('Test');
      
      expect(exception, isA<Exception>());
    });

    test('should handle empty message', () {
      final exception = CustomException('');
      
      expect(exception.message, '');
      expect(exception.toString(), '');
    });

    test('should handle special characters in message', () {
      const specialMessage = 'Error with special chars: áéíóú ñ @#\$%';
      final exception = CustomException(specialMessage);
      
      expect(exception.message, specialMessage);
      expect(exception.toString(), specialMessage);
    });

    test('should handle multiline message', () {
      const multilineMessage = 'Line 1\nLine 2\nLine 3';
      final exception = CustomException(multilineMessage);
      
      expect(exception.message, multilineMessage);
      expect(exception.toString(), multilineMessage);
    });

    test('should be throwable', () {
      const testMessage = 'Throwable test';
      
      expect(
        () => throw CustomException(testMessage),
        throwsA(isA<CustomException>()),
      );
    });

    test('should catch and verify thrown exception', () {
      const testMessage = 'Caught exception test';
      
      try {
        throw CustomException(testMessage);
      } catch (e) {
        expect(e, isA<CustomException>());
        expect((e as CustomException).message, testMessage);
      }
    });
  });
}