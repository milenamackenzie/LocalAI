import 'package:flutter/material.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Gradient? cardGradient;
  final Color? successColor;
  final Color? warningColor;

  const CustomThemeExtension({
    this.cardGradient,
    this.successColor,
    this.warningColor,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Gradient? cardGradient,
    Color? successColor,
    Color? warningColor,
  }) {
    return CustomThemeExtension(
      cardGradient: cardGradient ?? this.cardGradient,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      cardGradient: Gradient.lerp(cardGradient, other.cardGradient, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
    );
  }
}
