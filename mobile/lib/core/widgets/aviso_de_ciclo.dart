import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Aviso de que funcionalidade chega em ciclo futuro.
///
/// Mostra um icone de construcao em uma caixa de superficie.
class AvisoDeCiclo extends StatelessWidget {
  const AvisoDeCiclo({
    super.key,
    required this.texto,
    this.cor = AppColors.purple,
  });

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.construction, color: cor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 13,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
