import 'dart:ui';

import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  /// Parse color from hex string
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert color to hex string
  static String toHex(Color color, {bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Lighten color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// Adjust opacity
  static Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    return color.withOpacity(opacity);
  }

  /// Get contrasting color (black or white)
  static Color getContrastingColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Blend two colors
  static Color blend(Color color1, Color color2, [double ratio = 0.5]) {
    assert(ratio >= 0 && ratio <= 1);

    final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
    final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
    final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
    final a = (color1.alpha * (1 - ratio) + color2.alpha * ratio).round();

    return Color.fromARGB(a, r, g, b);
  }

  /// Create gradient colors
  static List<Color> createGradient(
    Color startColor,
    Color endColor,
    int steps,
  ) {
    if (steps < 2) return [startColor];

    final colors = <Color>[];
    for (int i = 0; i < steps; i++) {
      final ratio = i / (steps - 1);
      colors.add(blend(startColor, endColor, ratio));
    }

    return colors;
  }

  /// Check if color is dark
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// Check if color is light
  static bool isLight(Color color) {
    return color.computeLuminance() >= 0.5;
  }
}