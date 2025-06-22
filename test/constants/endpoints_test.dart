import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/constants/endpoints.dart';

void main() {
  group('Endpoints Tests', () {
    test('should have correct base server URI', () {
      expect(Endpoints.uriServidor, isNotEmpty);
      expect(Endpoints.uriServidor, startsWith('http'));
    });

    test('should have all required endpoints defined', () {
      expect(Endpoints.loginEndpoint, isNotEmpty);
      expect(Endpoints.registerEndpoint, isNotEmpty);
      expect(Endpoints.forgotPasswordEndpoint, isNotEmpty);
      expect(Endpoints.profileEndpoint, isNotEmpty);
      expect(Endpoints.balanceEndpoint, isNotEmpty);
      expect(Endpoints.paymentEndpoint, isNotEmpty);
      expect(Endpoints.rechargeEndpoint, isNotEmpty);
      expect(Endpoints.historyEndpoint, isNotEmpty);
      expect(Endpoints.chatEndpoint, isNotEmpty);
      expect(Endpoints.socketEndpoint, isNotEmpty);
      expect(Endpoints.chatApiEndpoint, isNotEmpty);
      expect(Endpoints.productsEndpoint, isNotEmpty);
      expect(Endpoints.storesEndpoint, isNotEmpty);
      expect(Endpoints.storeDetailEndpoint, isNotEmpty);
      expect(Endpoints.storeProductsEndpoint, isNotEmpty);
    });

    test('should have endpoints with correct base URL', () {
      expect(Endpoints.loginEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.registerEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.forgotPasswordEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.profileEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.balanceEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.paymentEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.rechargeEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.historyEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.chatApiEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.productsEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.storesEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.storeDetailEndpoint, contains(Endpoints.uriServidor));
      expect(Endpoints.storeProductsEndpoint, contains(Endpoints.uriServidor));
    });

    test('should have endpoints with correct paths', () {
      expect(Endpoints.loginEndpoint, endsWith('/login'));
      expect(Endpoints.registerEndpoint, endsWith('/register'));
      expect(Endpoints.forgotPasswordEndpoint, endsWith('/forgot-password'));
      expect(Endpoints.profileEndpoint, contains('/api/users/{id}'));
      expect(Endpoints.balanceEndpoint, contains('/api/wallets/{id}'));
      expect(Endpoints.paymentEndpoint, contains('/api/payment/{id}'));
      expect(Endpoints.rechargeEndpoint, contains('/api/recharges/{id}'));
      expect(Endpoints.historyEndpoint, endsWith('/api/transactions/by-user'));
      expect(Endpoints.chatApiEndpoint, endsWith('/api/chats'));
      expect(Endpoints.productsEndpoint, contains('/api/products/{id}'));
      expect(Endpoints.storesEndpoint, endsWith('/api/facilities'));
      expect(Endpoints.storeDetailEndpoint, contains('/api/facilities/{id}'));
      expect(Endpoints.storeProductsEndpoint, contains('/api/facilities/{id}/products'));
    });

    test('should have parametrized endpoints with placeholders', () {
      expect(Endpoints.profileEndpoint, contains('{id}'));
      expect(Endpoints.balanceEndpoint, contains('{id}'));
      expect(Endpoints.paymentEndpoint, contains('{id}'));
      expect(Endpoints.rechargeEndpoint, contains('{id}'));
      expect(Endpoints.productsEndpoint, contains('{id}'));
      expect(Endpoints.storeDetailEndpoint, contains('{id}'));
      expect(Endpoints.storeProductsEndpoint, contains('{id}'));
    });

    test('should have chat and socket endpoints equal to base URI', () {
      expect(Endpoints.chatEndpoint, equals(Endpoints.uriServidor));
      expect(Endpoints.socketEndpoint, equals(Endpoints.uriServidor));
    });
  });
}