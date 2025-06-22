import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/constants/app_colors.dart';

void main() {
  group('AppColors Tests', () {
    test('should have correct color values', () {
      // Test red color
      expect(AppColors.red, const Color(0xFFe42528));
      
      // Test cancel red color
      expect(AppColors.cancelRed, const Color(0xFFc34744));
      
      // Test white color
      expect(AppColors.white, const Color(0xFFFFFFFF));
      
      // Test sapphire color
      expect(AppColors.sapphire, const Color(0xFF14517E));
      
      // Test muted blue color
      expect(AppColors.muted_blue, const Color(0xFF3b7098));
      
      // Test green color
      expect(AppColors.green, const Color(0xFF118418));
      
      // Test very light grey color
      expect(AppColors.very_light_grey, const Color(0xFFf7f7f7));
    });

    test('colors should be different from each other', () {
      // Ensure all colors are unique
      final colors = [
        AppColors.red,
        AppColors.cancelRed,
        AppColors.white,
        AppColors.sapphire,
        AppColors.muted_blue,
        AppColors.green,
        AppColors.very_light_grey,
      ];
      
      final uniqueColors = colors.toSet();
      expect(uniqueColors.length, colors.length);
    });

    test('colors should have valid alpha values', () {
      // All colors should be fully opaque (alpha = 255)
      expect(AppColors.red.alpha, 255);
      expect(AppColors.cancelRed.alpha, 255);
      expect(AppColors.white.alpha, 255);
      expect(AppColors.sapphire.alpha, 255);
      expect(AppColors.muted_blue.alpha, 255);
      expect(AppColors.green.alpha, 255);
      expect(AppColors.very_light_grey.alpha, 255);
    });
  });
}