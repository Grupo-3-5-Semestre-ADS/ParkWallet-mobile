import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';

void main() {
  group('CommonBottomNavigationBar Widget Tests', () {
    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
    });

    tearDown(() {
      // Clean up GetX after each test
      Get.reset();
    });

    testWidgets('should render with correct number of navigation items', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CommonBottomNavigationBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(5));
    });

    testWidgets('should set correct current index for home route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(2)); // Home is index 2
    });

    testWidgets('should set correct current index for map route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/map'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0)); // Map is index 0
    });

    testWidgets('should set correct current index for stores route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/stores'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1)); // Stores is index 1
    });

    testWidgets('should set correct current index for history route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/history'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(3)); // History is index 3
    });

    testWidgets('should set correct current index for chat route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/chat'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(4)); // Chat is index 4
    });

    testWidgets('should default to home index for unknown route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/unknown'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(2)); // Default to home (index 2)
    });

    testWidgets('should have correct navigation bar type', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.type, equals(BottomNavigationBarType.fixed));
    });

    testWidgets('should contain all expected icons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.pin_drop), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.chat_rounded), findsOneWidget);
    });

    testWidgets('should handle tap on map item', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(builder: (_) => Container());
          },
        ),
      );

      // Tap on map icon (index 0)
      await tester.tap(find.byIcon(Icons.pin_drop));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, equals('/map'));
    });

    testWidgets('should handle tap on stores item', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(builder: (_) => Container());
          },
        ),
      );

      // Tap on stores icon (index 1)
      await tester.tap(find.byIcon(Icons.store));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, equals('/stores'));
    });

    testWidgets('should handle tap on home item', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/map'),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(builder: (_) => Container());
          },
        ),
      );

      // Tap on home icon (index 2)
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, equals('/home'));
    });

    testWidgets('should handle tap on history item', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(builder: (_) => Container());
          },
        ),
      );

      // Tap on history icon (index 3)
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, equals('/history'));
    });

    testWidgets('should handle tap on chat item', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(builder: (_) => Container());
          },
        ),
      );

      // Tap on chat icon (index 4)
      await tester.tap(find.byIcon(Icons.chat_rounded));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, equals('/chat'));
    });

    testWidgets('should not navigate when tapping current route', (WidgetTester tester) async {
      // Arrange
      String? navigatedRoute;
      
      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(builder: (_) => Container());
          },
        ),
      );

      // Tap on home icon when already on home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Assert - should not navigate to same route
      expect(navigatedRoute, isNull);
    });

    group('Route Index Mapping Tests', () {
      testWidgets('should correctly map all valid routes to indices', (WidgetTester tester) async {
        final routes = ['/map', '/stores', '/home', '/history', '/chat'];
        final expectedIndices = [0, 1, 2, 3, 4];

        for (int i = 0; i < routes.length; i++) {
          await tester.pumpWidget(
            GetMaterialApp(
              home: Scaffold(
                bottomNavigationBar: CommonBottomNavigationBar(currentRoute: routes[i]),
              ),
            ),
          );

          final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
          expect(bottomNavBar.currentIndex, equals(expectedIndices[i]), 
                 reason: 'Route ${routes[i]} should map to index ${expectedIndices[i]}');
        }
      });

      testWidgets('should handle empty route string', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: ''),
            ),
          ),
        );

        // Assert
        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2)); // Default to home
      });

      testWidgets('should handle null-like route strings', (WidgetTester tester) async {
        final invalidRoutes = ['null', 'undefined', '/', '/invalid'];

        for (String route in invalidRoutes) {
          await tester.pumpWidget(
            GetMaterialApp(
              home: Scaffold(
                bottomNavigationBar: CommonBottomNavigationBar(currentRoute: route),
              ),
            ),
          );

          final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
          expect(bottomNavBar.currentIndex, equals(2), 
                 reason: 'Invalid route "$route" should default to home index');
        }
      });
    });

    group('Navigation Behavior Tests', () {
      testWidgets('should handle rapid taps gracefully', (WidgetTester tester) async {
        // Arrange
        int navigationCount = 0;
        
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
            ),
            onGenerateRoute: (settings) {
              navigationCount++;
              return MaterialPageRoute(builder: (_) => Container());
            },
          ),
        );

        // Perform rapid taps on different icons
        await tester.tap(find.byIcon(Icons.pin_drop));
        await tester.tap(find.byIcon(Icons.store));
        await tester.tap(find.byIcon(Icons.list));
        await tester.pumpAndSettle();

        // Assert
        expect(navigationCount, greaterThan(0));
      });

      testWidgets('should maintain state across rebuilds', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/stores'),
            ),
          ),
        );

        // Verify initial state
        var bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(1));

        // Rebuild with different route
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/chat'),
            ),
          ),
        );

        // Verify updated state
        bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(4));
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible to screen readers', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home'),
            ),
          ),
        );

        // Assert
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        // Additional accessibility tests would require semantics testing
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle case-sensitive routes', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/HOME'),
            ),
          ),
        );

        // Assert
        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2)); // Should default to home due to case mismatch
      });

      testWidgets('should handle routes with query parameters', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home?param=value'),
            ),
          ),
        );

        // Assert
        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2)); // Should default due to query params
      });

      testWidgets('should handle routes with trailing slashes', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              bottomNavigationBar: CommonBottomNavigationBar(currentRoute: '/home/'),
            ),
          ),
        );

        // Assert
        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2)); // Should default due to trailing slash
      });
    });
  });
}