import 'package:flutter/material.dart';

/// Paleta do prototipo Figma do BNCC Play.
///
/// Os nomes seguem os tokens usados no prototipo (PURPLE, GREEN,
/// PURPLE_LIGHT, ...) para facilitar a conferencia tela a tela.
abstract final class AppColors {
  static const purple = Color(0xFF6C3EF4);
  static const purpleDark = Color(0xFF4A1FA8);
  static const purpleLight = Color(0xFFEDE8FD);

  static const green = Color(0xFF2EAF61);
  static const greenDark = Color(0xFF1A7A44);
  static const greenLight = Color(0xFFE0F5EA);

  static const background = Color(0xFFF5F5F7);
  static const surface = Colors.white;

  static const textPrimary = Color(0xFF1A1A2E);
  static const textMuted = Color(0xFF7B7B9B);
  static const textHint = Color(0xFF9999BB);

  static const divider = Color(0xFFE0DFF5);

  static const danger = Color(0xFFE53935);
  static const dangerLight = Color(0xFFFFEAEC);

  /// Gradiente do cabecalho roxo, equivalente a
  /// `linear-gradient(135deg, PURPLE, #4a1fa8)`.
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleDark],
  );

  /// Gradiente do cabecalho verde para a tela de cadastro de aluno.
  static const headerGradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, greenDark],
  );
}
