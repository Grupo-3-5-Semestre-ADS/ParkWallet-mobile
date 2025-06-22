import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/pages/widgets/store_item_tile.dart';

void main() {
  group('StoreItemTile Widget Tests', () {
    late Store testStore;
    late Store testStoreWithImage;
    late Store testStoreWithLongName;

    setUp(() {
      testStore = Store(
        id: 1,
        name: 'Test Store',
        type: 'Restaurant',
        description: 'Test store description',
      );

      testStoreWithImage = Store(
        id: 2,
        name: 'Store with Image',
        type: 'Cafe',
        description: 'Store with image description',
        image: 'assets/images/test_store.png',
      );

      testStoreWithLongName = Store(
        id: 3,
        name: 'This is a very long store name that should be truncated with ellipsis',
        type: 'Supermarket',
        description: 'Long name store description',
      );
    });

    testWidgets('should render store tile with basic information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);
      expect(find.byType(StoreItemTile), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should display default store icon when no image provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should display image when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStoreWithImage),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.store), findsNothing);
      
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect((imageWidget.image as AssetImage).assetName, equals('assets/images/test_store.png'));
    });

    testWidgets('should handle onTap callback when provided', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(
              item: testStore,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should always show arrow forward icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('should show arrow forward icon even with onTap callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(
              item: testStore,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('should truncate long store names with ellipsis', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to force ellipsis
              child: StoreItemTile(item: testStoreWithLongName),
            ),
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text(testStoreWithLongName.name));
      expect(titleText.overflow, equals(TextOverflow.ellipsis));
      expect(titleText.maxLines, equals(1));
    });

    testWidgets('should truncate long store types with ellipsis', (WidgetTester tester) async {
      // Arrange
      final storeWithLongType = Store(
        id: 4,
        name: 'Test Store',
        type: 'This is a very long store type that should be truncated',
        description: 'Test description',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to force ellipsis
              child: StoreItemTile(item: storeWithLongType),
            ),
          ),
        ),
      );

      // Assert
      final subtitleText = tester.widget<Text>(find.text(storeWithLongType.type));
      expect(subtitleText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle empty store name', (WidgetTester tester) async {
      // Arrange
      final emptyNameStore = Store(
        id: 5,
        name: '',
        type: 'Restaurant',
        description: 'Empty name store',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: emptyNameStore),
          ),
        ),
      );

      // Assert
      expect(find.text(''), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);
    });

    testWidgets('should handle empty store type', (WidgetTester tester) async {
      // Arrange
      final emptyTypeStore = Store(
        id: 6,
        name: 'Test Store',
        type: '',
        description: 'Empty type store',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: emptyTypeStore),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle special characters in store name and type', (WidgetTester tester) async {
      // Arrange
      final specialCharStore = Store(
        id: 7,
        name: 'Café & Açaí \"Premium\" 🍇☕',
        type: 'Restaurante & Lanchonete',
        description: 'Special character store',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: specialCharStore),
          ),
        ),
      );

      // Assert
      expect(find.text('Café & Açaí \"Premium\" 🍇☕'), findsOneWidget);
      expect(find.text('Restaurante & Lanchonete'), findsOneWidget);
    });

    testWidgets('should have correct styling for title and subtitle', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text('Test Store'));
      expect(titleText.style?.fontSize, equals(14));
      expect(titleText.style?.fontWeight, equals(FontWeight.w500));

      final subtitleText = tester.widget<Text>(find.text('Restaurant'));
      expect(subtitleText.style?.fontSize, equals(11));
    });

    testWidgets('should have correct ListTile properties', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.dense, isTrue);
      expect(listTile.contentPadding, equals(const EdgeInsets.symmetric(horizontal: 12)));
    });

    testWidgets('should have correct container styling for leading widget', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(40));
      expect(container.constraints?.maxHeight, equals(40));
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('should handle image with correct ClipRRect properties', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStoreWithImage),
          ),
        ),
      );

      // Assert
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(8)));
      
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, equals(40));
      expect(image.height, equals(40));
      expect(image.fit, equals(BoxFit.cover));
    });

    testWidgets('should handle multiple rapid taps', (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(
              item: testStore,
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      // Perform multiple rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(ListTile));
      }

      // Assert
      expect(tapCount, equals(5));
    });

    testWidgets('should handle null onTap gracefully', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreItemTile(item: testStore),
          ),
        ),
      );

      // Assert - should not throw when tapped
      await tester.tap(find.byType(ListTile));
      expect(find.byType(StoreItemTile), findsOneWidget);
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible to screen readers', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StoreItemTile(item: testStore),
            ),
          ),
        );

        // Assert
        expect(find.text('Test Store'), findsOneWidget);
        expect(find.text('Restaurant'), findsOneWidget);
        // Additional accessibility tests would require semantics testing
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very long store names gracefully', (WidgetTester tester) async {
        // Arrange
        final veryLongNameStore = Store(
          id: 8,
          name: 'A' * 1000, // Very long name
          type: 'Restaurant',
          description: 'Very long name store',
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StoreItemTile(item: veryLongNameStore),
            ),
          ),
        );

        // Assert
        expect(find.text('A' * 1000), findsOneWidget);
        expect(find.text('Restaurant'), findsOneWidget);
      });

      testWidgets('should handle stores with numeric names', (WidgetTester tester) async {
        // Arrange
        final numericNameStore = Store(
          id: 9,
          name: '12345',
          type: '67890',
          description: 'Numeric name store',
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StoreItemTile(item: numericNameStore),
            ),
          ),
        );

        // Assert
        expect(find.text('12345'), findsOneWidget);
        expect(find.text('67890'), findsOneWidget);
      });

      testWidgets('should handle stores with whitespace names', (WidgetTester tester) async {
        // Arrange
        final whitespaceStore = Store(
          id: 10,
          name: '   Spaced Store   ',
          type: '   Spaced Type   ',
          description: 'Whitespace store',
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StoreItemTile(item: whitespaceStore),
            ),
          ),
        );

        // Assert
        expect(find.text('   Spaced Store   '), findsOneWidget);
        expect(find.text('   Spaced Type   '), findsOneWidget);
      });
    });

    group('Visual Layout Tests', () {
      testWidgets('should maintain consistent layout with different content lengths', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  StoreItemTile(item: testStore),
                  StoreItemTile(item: testStoreWithLongName),
                  StoreItemTile(item: testStoreWithImage),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(StoreItemTile), findsNWidgets(3));
        expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
      });
    });
  });
}