import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Campo do prototipo (`InputField`): rotulo acima, caixa lilas de 52px de
/// altura com icone a esquerda.
///
/// Quando [errorText] vem preenchido, a caixa assume o vermelho definido no
/// prototipo para o estado de falha e a mensagem aparece abaixo.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final accent = hasError ? AppColors.danger : AppColors.purple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.fieldLabel),
        const SizedBox(height: 4),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: hasError ? AppColors.dangerLight : AppColors.purpleLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? AppColors.danger.withValues(alpha: 0.38)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: accent),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  onSubmitted: onSubmitted,
                  style: AppTheme.fieldText,
                  cursorColor: AppColors.purple,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTheme.fieldHint,
                  ),
                ),
              ),
              if (hasError)
                const Icon(Icons.cancel, size: 18, color: AppColors.danger),
              if (suffixIcon != null) ...[
                if (hasError) const SizedBox(width: 8),
                suffixIcon!,
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(errorText!, style: AppTheme.fieldError),
        ],
      ],
    );
  }
}
