import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';

/// Porta de entrada do app: leva ao login ou ao cadastro.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: ConstrainedBox(
                // Ocupa a altura toda quando sobra espaco e vira rolagem
                // quando falta, em vez de estourar.
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 96,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BNCC Play',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerTitle.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aprenda computação jogando',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerSubtitle,
                    ),
                    const SizedBox(height: 48),
                    _BotaoClaro(
                      label: 'Entrar',
                      icon: Icons.login,
                      onPressed: () =>
                          Navigator.pushNamed(context, Rotas.login),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Criar conta',
                      icon: Icons.person_add,
                      variant: AppButtonVariant.ghost,
                      onPressed: () =>
                          Navigator.pushNamed(context, Rotas.registerType),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botao branco sobre o gradiente. O AppButton primario e roxo e sumiria
/// no fundo, entao esta variante existe so aqui.
class _BotaoClaro extends StatelessWidget {
  const _BotaoClaro({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.purple),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTheme.buttonLabel.copyWith(color: AppColors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
