import 'package:flutter/material.dart';
import 'package:schooly/common/utils.dart';

class SColors {
  static Color getBackgroundColor(BuildContext context) {
    if (Utils.isDarkMode(context)) {
      return const Color.fromRGBO(43, 46, 56, 1);
    }

    return Colors.white;
  }

  static Color getInvertedBackgroundColor(BuildContext context) {
    if (Utils.isDarkMode(context)) {
      return Colors.white;
    }

    return const Color.fromRGBO(43, 46, 56, 1);
  }
  
  static Color getGreyscaleColor(BuildContext context) {
    if (Utils.isDarkMode(context)) {
      return const Color.fromRGBO(128, 128, 128, 1);
    }

    return const Color.fromRGBO(206, 206, 206, 1);
  }

  static Color getInvertedGreyscaleColor(BuildContext context) {
    if (Utils.isDarkMode(context)) {
      return const Color.fromRGBO(206, 206, 206, 1);
    }

    return const Color.fromRGBO(128, 128, 128, 1);
  }

  // static Color getWidgetBackgroundColor(BuildContext context) 
  //   => Utils.isDarkMode(context) 
  //     ? Colors.grey.shade700 
  //     : Colors.white;

  static LinearGradient getScaffoldGradient(BuildContext context) {
    double darkenAmount = Utils.isDarkMode(context) ? 0.1 : 0;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        const Color.fromRGBO(255,144,235,1).darken(darkenAmount),
        const Color.fromRGBO(109, 31, 118, 1).darken(darkenAmount)
      ]
    );
  }
}

extension SColor on Color {
  Color darken([ double amount = .1 ]) {
    assert (amount >= 0 && amount <= 1);

    final HSLColor hsl = HSLColor.fromColor(this);
    final HSLColor hslDarkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDarkened.toColor();
  }

  Color lighten([ double amount = .1 ]) {
    assert (amount >= 0 && amount <= 1);

    final HSLColor hsl = HSLColor.fromColor(this);
    final HSLColor hslLightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLightened.toColor();
  }

  Color get toShadow {
    return withOpacity(0.75);
  }
}