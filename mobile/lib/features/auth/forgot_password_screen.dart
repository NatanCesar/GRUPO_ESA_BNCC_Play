import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';

/// Casca da recuperacao de senha.
///
/// O prototipo tem um fluxo de quatro passos, mas nenhum caso de teste o
/// cobre e o envio de e-mail depende de servidor. Pedir o e-mail aqui
/// simularia um envio que nao acontece, entao a tela apenas explica.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                child: TopBar(
                  titulo: 'Recuperar senha',
                  onVoltar: () => Navigator.maybePop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 56,
                      color: AppColors.purple,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'A recuperação de senha por e-mail depende de servidor e chega numa próxima entrega.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Voltar ao login',
                      icon: Icons.arrow_back,
                      variant: AppButtonVariant.ghost,
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, Rotas.login),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
