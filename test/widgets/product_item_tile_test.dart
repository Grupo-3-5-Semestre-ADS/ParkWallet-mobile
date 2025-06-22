import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/models/product.dart';
import 'package:park_wallet/pages/widgets/product_item_tile.dart';

void main() {
  group('ProductItemTile Widget Tests', () {
    late Product testProduct;
    late Product testProductWithImage;
    late Product testProductWithLongName;

    setUp(() {
      testProduct = Product(
        id: 1,
        name: 'Test Product',
        price: 15.99,
        description: 'Test description',
        storeId: 1,
      );

      testProductWithImage = Product(
        id: 2,
        name: 'Product with Image',
        price: 25.50,
        description: 'Product with image description',
        storeId: 1,
        image: 'assets/images/test_product.png',
      );

      testProductWithLongName = Product(
        id: 3,
        name: 'This is a very long product name that should be truncated with ellipsis',
        price: 99.99,
        description: 'Long name product description',
        storeId: 1,
      );
    });

    testWidgets('should render product tile with basic information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: testProduct),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('R\$ 15.99'), findsOneWidget);
      expect(find.byType(ProductItemTile), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should display default icon when no image provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: testProduct),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.fastfood), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should display image when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: testProductWithImage),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.fastfood), findsNothing);
      
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect((imageWidget.image as AssetImage).assetName, equals('assets/images/test_product.png'));
    });

    testWidgets('should handle onTap callback when provided', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(
              item: testProduct,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should show shopping cart icon when onTap is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(
              item: testProduct,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
    });

    testWidgets('should not show shopping cart icon when onTap is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: testProduct),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add_shopping_cart), findsNothing);
    });

    testWidgets('should truncate long product names with ellipsis', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to force ellipsis
              child: ProductItemTile(item: testProductWithLongName),
            ),
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text(testProductWithLongName.name));
      expect(titleText.overflow, equals(TextOverflow.ellipsis));
      expect(titleText.maxLines, equals(1));
    });

    testWidgets('should format price correctly with two decimal places', (WidgetTester tester) async {
      // Arrange
      final productWithWholePrice = Product(
        id: 4,
        name: 'Whole Price Product',
        price: 10.0,
        description: 'Test description',
        storeId: 1,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: productWithWholePrice),
          ),
        ),
      );

      // Assert
      expect(find.text('R\$ 10.00'), findsOneWidget);
    });

    testWidgets('should handle zero price', (WidgetTester tester) async {
      // Arrange
      final freeProduct = Product(
        id: 5,
        name: 'Free Product',
        price: 0.0,
        description: 'Free product description',
        storeId: 1,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: freeProduct),
          ),
        ),
      );

      // Assert
      expect(find.text('R\$ 0.00'), findsOneWidget);
    });

    testWidgets('should handle high price values', (WidgetTester tester) async {
      // Arrange
      final expensiveProduct = Product(
        id: 6,
        name: 'Expensive Product',
        price: 999.99,
        description: 'Expensive product description',
        storeId: 1,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: expensiveProduct),
          ),
        ),
      );

      // Assert
      expect(find.text('R\$ 999.99'), findsOneWidget);
    });

    testWidgets('should handle empty product name', (WidgetTester tester) async {
      // Arrange
      final emptyNameProduct = Product(
        id: 7,
        name: '',
        price: 5.99,
        description: 'Empty name product',
        storeId: 1,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: emptyNameProduct),
          ),
        ),
      );

      // Assert
      expect(find.text(''), findsOneWidget);
      expect(find.text('R\$ 5.99'), findsOneWidget);
    });

    testWidgets('should handle special characters in product name', (WidgetTester tester) async {
      // Arrange
      final specialCharProduct = Product(
        id: 8,
        name: 'Açaí & Café \"Premium\" 🍇☕',
        price: 12.50,
        description: 'Special character product',
        storeId: 1,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: specialCharProduct),
          ),
        ),
      );

      // Assert
      expect(find.text('Açaí & Café \"Premium\" 🍇☕'), findsOneWidget);
    });

    testWidgets('should have correct styling for title and subtitle', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: testProduct),
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text('Test Product'));
      expect(titleText.style?.fontSize, equals(14));
      expect(titleText.style?.fontWeight, equals(FontWeight.w500));

      final subtitleText = tester.widget<Text>(find.text('R\$ 15.99'));
      expect(subtitleText.style?.fontSize, equals(11));
      expect(subtitleText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should have correct ListTile properties', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(item: testProduct),
          ),
        ),
      );

      // Assert
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.dense, isTrue);
      expect(listTile.contentPadding, equals(const EdgeInsets.symmetric(horizontal: 12)));
    });

    testWidgets('should handle multiple rapid taps', (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductItemTile(
              item: testProduct,
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

    group('Accessibility Tests', () {
      testWidgets('should be accessible to screen readers', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductItemTile(item: testProduct),
            ),
          ),
        );

        // Assert
        expect(find.text('Test Product'), findsOneWidget);
        expect(find.text('R\$ 15.99'), findsOneWidget);
        // Additional accessibility tests would require semantics testing
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very small prices', (WidgetTester tester) async {
        // Arrange
        final cheapProduct = Product(
          id: 9,
          name: 'Cheap Product',
          price: 0.01,
          description: 'Very cheap product',
          storeId: 1,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductItemTile(item: cheapProduct),
            ),
          ),
        );

        // Assert
        expect(find.text('R\$ 0.01'), findsOneWidget);
      });

      testWidgets('should handle price with many decimal places', (WidgetTester tester) async {
        // Arrange
        final preciseProduct = Product(
          id: 10,
          name: 'Precise Product',
          price: 15.999999,
          description: 'Product with precise price',
          storeId: 1,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductItemTile(item: preciseProduct),
            ),
          ),
        );

        // Assert
        expect(find.text('R\$ 16.00'), findsOneWidget); // Should round to 2 decimal places
      });
    });
  });
}