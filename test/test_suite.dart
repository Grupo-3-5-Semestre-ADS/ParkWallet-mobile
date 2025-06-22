import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'widget_test.dart' as widget_tests;
import 'constants/app_colors_test.dart' as app_colors_tests;
import 'constants/endpoints_test.dart' as endpoints_tests;
import 'global/language_controller_test.dart' as language_controller_tests;
import 'global/custom_exception_test.dart' as custom_exception_tests;
import 'routes/app_routes_test.dart' as app_routes_tests;
import 'services/auth_service_test.dart' as auth_service_tests;
import 'data/dto/login_request_test.dart' as login_request_tests;
import 'data/dto/transaction_test.dart' as transaction_tests;
import 'data/dto/transaction_item_test.dart' as transaction_item_tests;
import 'data/models/product_test.dart' as product_tests;
import 'data/models/user_profile_test.dart' as user_profile_tests;
import 'data/models/store_test.dart' as store_tests;

void main() {
  group('ParkWallet Test Suite', () {
    // Widget Tests
    group('Widget Tests', widget_tests.main);
    
    // Constants Tests
    group('App Colors Tests', app_colors_tests.main);
    group('Endpoints Tests', endpoints_tests.main);
    
    // Global Tests
    group('Language Controller Tests', language_controller_tests.main);
    group('Custom Exception Tests', custom_exception_tests.main);
    
    // Routes Tests
    group('App Routes Tests', app_routes_tests.main);
    
    // Services Tests
    group('Auth Service Tests', auth_service_tests.main);
    
    // Data DTO Tests
    group('Login Request Tests', login_request_tests.main);
    group('Transaction Tests', transaction_tests.main);
    group('Transaction Item Tests', transaction_item_tests.main);
    
    // Data Models Tests
    group('Product Tests', product_tests.main);
    group('User Profile Tests', user_profile_tests.main);
    group('Store Tests', store_tests.main);
  });
}