import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/features/library/utils/cover_palette.dart';

void main() {
  group('CoverPalette.forTitle', () {
    test('different titles can yield different gradients', () {
      // Sample many titles; with hue ∈ [0, 360) we expect a wide spread.
      final firstStops = <Color>{};
      for (var i = 0; i < 200; i++) {
        firstStops.add(CoverPalette.forTitle('title-$i', isDark: false).first);
      }
      expect(firstStops.length, greaterThanOrEqualTo(50));
    });
    test('returns a 3-color gradient', () {
      final colors = CoverPalette.forTitle('any', isDark: false);
      expect(colors.length, 3);
    });

    test('returns 3 colors for the dark variant too', () {
      final colors = CoverPalette.forTitle('any', isDark: true);
      expect(colors.length, 3);
    });

    test('light and dark variants for the same title differ', () {
      const title = 'The Sound of the Mountain';
      final light = CoverPalette.forTitle(title, isDark: false);
      final dark = CoverPalette.forTitle(title, isDark: true);
      expect(light, isNot(equals(dark)));
    });

    test('same title returns identical gradient on repeat calls', () {
      const title = 'Stable';
      final a = CoverPalette.forTitle(title, isDark: false);
      final b = CoverPalette.forTitle(title, isDark: false);
      expect(a, equals(b));
    });
  });

  group('CoverPalette.titleColor', () {
    test('returns near-black on light, off-white on dark', () {
      final light = CoverPalette.titleColor(isDark: false);
      final dark = CoverPalette.titleColor(isDark: true);
      // Crude luminance check via R+G+B sum.
      int sum(Color c) =>
          ((c.r * 255).round()) +
          ((c.g * 255).round()) +
          ((c.b * 255).round());
      expect(sum(light), lessThan(sum(dark)));
    });
  });

  group('CoverPalette.titleFontSize', () {
    test('returns 24 for titles ≤ 18 chars', () {
      expect(CoverPalette.titleFontSize(''), 24);
      expect(CoverPalette.titleFontSize('a'), 24);
      expect(CoverPalette.titleFontSize('123456789012345678'), 24); // 18
    });

    test('returns 20 for titles 19–34 chars', () {
      expect(CoverPalette.titleFontSize('1234567890123456789'), 20); // 19
      expect(CoverPalette.titleFontSize('a' * 34), 20);
    });

    test('returns 17 for titles 35–55 chars', () {
      expect(CoverPalette.titleFontSize('a' * 35), 17);
      expect(CoverPalette.titleFontSize('a' * 55), 17);
    });

    test('returns 14 for titles > 55 chars', () {
      expect(CoverPalette.titleFontSize('a' * 56), 14);
      expect(CoverPalette.titleFontSize('a' * 200), 14);
    });
  });
}
