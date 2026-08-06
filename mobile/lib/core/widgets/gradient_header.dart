import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cabecalho com gradiente e cantos inferiores arredondados.
///
/// O gradiente sobe ate a borda da tela e o conteudo recebe o recuo da barra
/// de status do sistema. No prototipo Figma esse recuo era uma barra falsa
/// desenhada dentro do frame; aqui quem desenha e o Android.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;

  /// Gradiente da faixa. Default: roxo.
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32, statusBarHeight + 16, 32, 24),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.headerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: child,
    );
  }
}
