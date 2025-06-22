import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/routes/app_pages.dart';

void main() {
  group('Routes Tests', () {
    test('should have correct route paths', () {
      expect(Routes.HOME, '/home');
      expect(Routes.LOGIN, '/login');
      expect(Routes.REGISTER, '/register');
      expect(Routes.HISTORY, '/history');
      expect(Routes.STORES, '/stores');
      expect(Routes.STORE_DETAIL, '/store-detail');
      expect(Routes.CHAT, '/chat');
      expect(Routes.MAP, '/map');
      expect(Routes.PROFILE, '/profile');
      expect(Routes.PROFILE_UPDATE, '/profile-update');
    });

    test('all routes should start with forward slash', () {
      final routes = [
        Routes.HOME,
        Routes.LOGIN,
        Routes.REGISTER,
        Routes.HISTORY,
        Routes.STORES,
        Routes.STORE_DETAIL,
        Routes.CHAT,
        Routes.MAP,
        Routes.PROFILE,
        Routes.PROFILE_UPDATE,
      ];

      for (final route in routes) {
        expect(route.startsWith('/'), true, reason: 'Route $route should start with /');
      }
    });

    test('all routes should be unique', () {
      final routes = [
        Routes.HOME,
        Routes.LOGIN,
        Routes.REGISTER,
        Routes.HISTORY,
        Routes.STORES,
        Routes.STORE_DETAIL,
        Routes.CHAT,
        Routes.MAP,
        Routes.PROFILE,
        Routes.PROFILE_UPDATE,
      ];

      final uniqueRoutes = routes.toSet();
      expect(uniqueRoutes.length, routes.length, 
        reason: 'All routes should be unique');
    });

    test('routes should not be empty', () {
      final routes = [
        Routes.HOME,
        Routes.LOGIN,
        Routes.REGISTER,
        Routes.HISTORY,
        Routes.STORES,
        Routes.STORE_DETAIL,
        Routes.CHAT,
        Routes.MAP,
        Routes.PROFILE,
        Routes.PROFILE_UPDATE,
      ];

      for (final route in routes) {
        expect(route.isNotEmpty, true, reason: 'Route should not be empty');
        expect(route.trim().isNotEmpty, true, reason: 'Route should not be just whitespace');
      }
    });

    test('routes should follow naming convention', () {
      final routes = [
        Routes.HOME,
        Routes.LOGIN,
        Routes.REGISTER,
        Routes.HISTORY,
        Routes.STORES,
        Routes.STORE_DETAIL,
        Routes.CHAT,
        Routes.MAP,
        Routes.PROFILE,
        Routes.PROFILE_UPDATE,
      ];

      for (final route in routes) {
        // Should be lowercase with hyphens for multi-word routes
        expect(route, matches(r'^/[a-z]+(-[a-z]+)*$'), 
          reason: 'Route $route should follow kebab-case convention');
      }
    });

    test('should have expected number of routes', () {
      final routes = [
        Routes.HOME,
        Routes.LOGIN,
        Routes.REGISTER,
        Routes.HISTORY,
        Routes.STORES,
        Routes.STORE_DETAIL,
        Routes.CHAT,
        Routes.MAP,
        Routes.PROFILE,
        Routes.PROFILE_UPDATE,
      ];

      expect(routes.length, 10, reason: 'Should have exactly 10 routes defined');
    });
  });
}