import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema claro do app, derivado do prototipo Figma.
///
/// Poppins carrega titulos e botoes; Inter carrega labels e corpo de texto.
abstract final class AppTheme {
  static const poppins = 'Poppins';
  static const inter = 'Inter';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        primary: AppColors.purple,
        secondary: AppColors.green,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(
        fontFamily: inter,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: inter,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  // Estilos nomeados, na mesma granularidade do prototipo.

  static const headerTitle = TextStyle(
    fontFamily: poppins,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    color: Colors.white,
  );

  static const headerSubtitle = TextStyle(
    fontFamily: inter,
    fontSize: 13,
    color: Color(0xB3FFFFFF), // branco 70%
  );

  static const fieldLabel = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: AppColors.textMuted,
  );

  static const fieldText = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const fieldHint = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    color: AppColors.textHint,
  );

  static const fieldError = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.danger,
  );

  static const buttonLabel = TextStyle(
    fontFamily: poppins,
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static const link = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: AppColors.purple,
  );

  static const footerText = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static const footerLink = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.purple,
  );
}
