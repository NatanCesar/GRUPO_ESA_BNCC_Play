import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';

/// Escolha entre cadastro de professor e de aluno.
class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(onVoltar: () => Navigator.maybePop(context)),
                    const SizedBox(height: 8),
                    Text(
                      'Quem é você?',
                      style: AppTheme.headerTitle.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Escolha seu perfil para começar',
                      style: AppTheme.headerSubtitle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    _CartaoDePerfil(
                      emoji: 'person',
                      titulo: 'Sou Professor(a)',
                      descricao:
                          'Cadastre questões, acompanhe turmas e visualize relatórios pedagógicos',
                      cor: AppColors.purple,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.registerTeacher,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CartaoDePerfil(
                      emoji: 'sports_esports',
                      titulo: 'Sou Aluno(a)',
                      descricao:
                          'Jogue, aprenda, suba no ranking e desafie seus colegas',
                      cor: AppColors.green,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.registerStudent,
                      ),
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

class _CartaoDePerfil extends StatelessWidget {
  const _CartaoDePerfil({
    required this.emoji,
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.onTap,
  });

  final String emoji;
  final String titulo;
  final String descricao;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_iconeDoEmoji(emoji), size: 30, color: cor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontFamily: AppTheme.poppins,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Começar',
                          style: TextStyle(
                            fontFamily: AppTheme.inter,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: cor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: cor),
                      ],
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

  IconData _iconeDoEmoji(String nome) {
    switch (nome) {
      case 'person':
        return Icons.person;
      case 'sports_esports':
        return Icons.sports_esports;
      default:
        return Icons.person;
    }
  }
}
