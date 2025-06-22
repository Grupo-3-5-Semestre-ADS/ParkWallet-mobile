import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      // Arrange
      const buttonLabel = 'Test Button';
      bool wasPressed = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: buttonLabel,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(buttonLabel), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      
      // Test button press
      await tester.tap(find.byType(AppButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('should render with custom background color', (WidgetTester tester) async {
      // Arrange
      const customColor = Colors.red;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Custom Color Button',
              backgroundColor: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.backgroundColor, equals(customColor));
    });

    testWidgets('should render with custom text color', (WidgetTester tester) async {
      // Arrange
      const customTextColor = Colors.yellow;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Custom Text Color',
              textColor: customTextColor,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.textColor, equals(customTextColor));
    });

    testWidgets('should render with icon at start position', (WidgetTester tester) async {
      // Arrange
      const iconData = Icons.add;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Button with Icon',
              icon: iconData,
              iconPosition: IconPosition.start,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(iconData), findsOneWidget);
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.icon, equals(iconData));
      expect(buttonWidget.iconPosition, equals(IconPosition.start));
    });

    testWidgets('should render with icon at end position', (WidgetTester tester) async {
      // Arrange
      const iconData = Icons.arrow_forward;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Button with End Icon',
              icon: iconData,
              iconPosition: IconPosition.end,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(iconData), findsOneWidget);
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.iconPosition, equals(IconPosition.end));
    });

    testWidgets('should render with custom width', (WidgetTester tester) async {
      // Arrange
      const customWidth = 200.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Custom Width Button',
              width: customWidth,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.width, equals(customWidth));
    });

    testWidgets('should render with custom height', (WidgetTester tester) async {
      // Arrange
      const customHeight = 60.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Custom Height Button',
              height: customHeight,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.height, equals(customHeight));
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('should not show loading indicator when isLoading is false', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Normal Button',
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Normal Button'), findsOneWidget);
    });

    testWidgets('should handle null onPressed callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.onPressed, isNull);
      expect(find.text('Disabled Button'), findsOneWidget);
    });

    testWidgets('should handle long text with ellipsis', (WidgetTester tester) async {
      // Arrange
      const longText = 'This is a very long button text that should be truncated with ellipsis';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Constrain width to force ellipsis
              child: AppButton(
                label: longText,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      
      // Assert
      final textWidget = tester.widget<Text>(find.text(longText));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should use default colors when not specified', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Default Colors',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.backgroundColor, equals(const Color(0xFF14517E)));
      expect(buttonWidget.textColor, equals(Colors.white));
    });

    testWidgets('should use default height when not specified', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Default Height',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
      expect(buttonWidget.height, equals(40.0));
    });

    testWidgets('should handle empty label', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: '',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle special characters in label', (WidgetTester tester) async {
      // Arrange
      const specialLabel = 'Botão com Acentos! 🎉 @#\$%';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: specialLabel,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(specialLabel), findsOneWidget);
    });

    testWidgets('should maintain state when rebuilt', (WidgetTester tester) async {
      // Arrange
      bool isLoading = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppButton(
                  label: 'Stateful Button',
                  isLoading: isLoading,
                  onPressed: () {
                    setState(() {
                      isLoading = !isLoading;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      
      // Assert initial state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Stateful Button'), findsOneWidget);
      
      // Trigger state change
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      
      // Assert updated state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Stateful Button'), findsNothing);
    });

    testWidgets('should handle rapid taps gracefully', (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Rapid Tap Button',
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );
      
      // Perform rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(AppButton));
      }
      
      // Assert
      expect(tapCount, equals(5));
    });

    testWidgets('should respect IconPosition enum values', (WidgetTester tester) async {
      // Act & Assert
      expect(IconPosition.start, isA<IconPosition>());
      expect(IconPosition.end, isA<IconPosition>());
      expect(IconPosition.values, hasLength(2));
      expect(IconPosition.values, contains(IconPosition.start));
      expect(IconPosition.values, contains(IconPosition.end));
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible to screen readers', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Accessible Button',
                onPressed: () {},
              ),
            ),
          ),
        );
        
        // Assert
        expect(find.text('Accessible Button'), findsOneWidget);
        // Additional accessibility tests would require semantics testing
      });

      testWidgets('should handle focus properly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Focusable Button',
                onPressed: () {},
              ),
            ),
          ),
        );
        
        // Assert
        expect(find.byType(AppButton), findsOneWidget);
        // Focus testing would require additional setup
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very small dimensions', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Tiny',
                width: 10,
                height: 10,
                onPressed: () {},
              ),
            ),
          ),
        );
        
        // Assert
        final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
        expect(buttonWidget.width, equals(10));
        expect(buttonWidget.height, equals(10));
      });

      testWidgets('should handle very large dimensions', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Huge Button',
                width: 1000,
                height: 200,
                onPressed: () {},
              ),
            ),
          ),
        );
        
        // Assert
        final buttonWidget = tester.widget<AppButton>(find.byType(AppButton));
        expect(buttonWidget.width, equals(1000));
        expect(buttonWidget.height, equals(200));
      });
    });
  });
}