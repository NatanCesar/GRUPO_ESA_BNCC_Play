import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Etiqueta arredondada do prototipo (`Badge`).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.rotulo,
    this.cor = AppColors.purple,
  });

  final String rotulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        rotulo,
        style: const TextStyle(
          fontFamily: AppTheme.inter,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}
