import 'package:flutter/material.dart';

class ColorUtils {
  static String toHex(Color color) {
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final argb = (a << 24) | (r << 16) | (g << 8) | b;
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color fromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
