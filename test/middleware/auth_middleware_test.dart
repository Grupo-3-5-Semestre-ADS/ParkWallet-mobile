import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/middleware/auth_middleware.dart';
import 'package:park_wallet/services/auth_service.dart';

import 'auth_middleware_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('AuthMiddleware Tests', () {
    late AuthMiddleware authMiddleware;
    late MockAuthService mockAuthService;

    setUp(() {
      Get.testMode = true;
      mockAuthService = MockAuthService();
      
      // Register the mock service
      Get.put<AuthService>(mockAuthService);
      
      authMiddleware = AuthMiddleware();
    });

    tearDown(() {
      Get.reset();
    });

    group('Redirect Tests', () {
      test('should return null when user is authenticated', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/home');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should redirect to login when user is not authenticated', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/home');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should redirect to login when accessing protected route without token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/profile');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should redirect to login when accessing stores route without token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/stores');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should redirect to login when accessing map route without token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/map');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should redirect to login when accessing history route without token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/history');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should redirect to login when accessing chat route without token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/chat');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });
    });

    group('Route Handling Tests', () {
      test('should allow access to authenticated routes with valid token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        final protectedRoutes = [
          '/home',
          '/profile',
          '/stores',
          '/map',
          '/history',
          '/chat',
          '/settings',
          '/payment'
        ];
        
        // Act & Assert
        for (final route in protectedRoutes) {
          final result = authMiddleware.redirect(route);
          expect(result, isNull, reason: 'Route $route should be accessible with valid token');
        }
        
        verify(mockAuthService.isTokenValid()).called(protectedRoutes.length);
      });

      test('should redirect all protected routes to login without valid token', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        final protectedRoutes = [
          '/home',
          '/profile',
          '/stores',
          '/map',
          '/history',
          '/chat',
          '/settings',
          '/payment'
        ];
        
        // Act & Assert
        for (final route in protectedRoutes) {
          final result = authMiddleware.redirect(route);
          expect(result, equals('/login'), reason: 'Route $route should redirect to login without valid token');
        }
        
        verify(mockAuthService.isTokenValid()).called(protectedRoutes.length);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle null route', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect(null);
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle empty route', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle route with query parameters', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/home?tab=profile');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle route with fragments', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/home#section1');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle route with trailing slash', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/home/');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle nested routes', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/profile/edit');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle case-sensitive routes', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/HOME');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });
    });

    group('Service Integration Tests', () {
      test('should handle AuthService throwing exception', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenThrow(Exception('Service error'));
        
        // Act
        final result = authMiddleware.redirect('/home');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle AuthService returning null', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(null);
        
        // Act
        final result = authMiddleware.redirect('/home');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should call AuthService only once per redirect call', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        authMiddleware.redirect('/home');
        
        // Assert
        verify(mockAuthService.isTokenValid()).called(1);
        verifyNoMoreInteractions(mockAuthService);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple rapid redirect calls', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        for (int i = 0; i < 100; i++) {
          final result = authMiddleware.redirect('/home');
          expect(result, isNull);
        }
        
        // Assert
        verify(mockAuthService.isTokenValid()).called(100);
      });

      test('should handle alternating authentication states', () {
        // Arrange
        when(mockAuthService.isTokenValid())
            .thenReturn(true)
            .thenReturn(false)
            .thenReturn(true)
            .thenReturn(false);
        
        // Act & Assert
        expect(authMiddleware.redirect('/home'), isNull);
        expect(authMiddleware.redirect('/home'), equals('/login'));
        expect(authMiddleware.redirect('/home'), isNull);
        expect(authMiddleware.redirect('/home'), equals('/login'));
        
        verify(mockAuthService.isTokenValid()).called(4);
      });
    });

    group('Route Priority Tests', () {
      test('should prioritize authentication check over route validation', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(false);
        
        // Act
        final result = authMiddleware.redirect('/invalid-route-that-does-not-exist');
        
        // Assert
        expect(result, equals('/login'));
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle special characters in routes', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final result = authMiddleware.redirect('/home?user=test@example.com&redirect=/profile');
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });

      test('should handle very long routes', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        final longRoute = '/home' + ('a' * 1000);
        
        // Act
        final result = authMiddleware.redirect(longRoute);
        
        // Assert
        expect(result, isNull);
        verify(mockAuthService.isTokenValid()).called(1);
      });
    });

    group('State Management Tests', () {
      test('should maintain consistent behavior across multiple instances', () {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        final middleware1 = AuthMiddleware();
        final middleware2 = AuthMiddleware();
        
        // Act
        final result1 = middleware1.redirect('/home');
        final result2 = middleware2.redirect('/home');
        
        // Assert
        expect(result1, isNull);
        expect(result2, isNull);
        verify(mockAuthService.isTokenValid()).called(2);
      });

      test('should handle concurrent redirect calls', () async {
        // Arrange
        when(mockAuthService.isTokenValid()).thenReturn(true);
        
        // Act
        final futures = List.generate(10, (index) async {
          return authMiddleware.redirect('/home');
        });
        
        final results = await Future.wait(futures);
        
        // Assert
        for (final result in results) {
          expect(result, isNull);
        }
        verify(mockAuthService.isTokenValid()).called(10);
      });
    });
  });
}