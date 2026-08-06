import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';

/// Tela de recuperacao de senha — casca honesta.
///
/// Nao pede e-mail para nao simular um envio que nao acontece.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradientHeader(
              child: TopBar(
                titulo: 'Recuperar senha',
                onVoltar: () => Navigator.maybePop(context),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 48,
                            color: AppColors.purple,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Recuperar senha',
                            style: AppTheme.headerTitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'A recuperação de senha por e-mail depende de servidor e chega numa próxima entrega.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.inter,
                              fontSize: 14,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Voltar ao login',
                      onPressed: () =>
                          Navigator.pushNamed(context, Rotas.login),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
