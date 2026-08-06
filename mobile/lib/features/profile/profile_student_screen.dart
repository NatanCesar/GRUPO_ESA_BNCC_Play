import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import 'widgets/conteudo_perfil_aluno.dart';

/// Perfil do aluno.
///
/// Usa o mesmo ConteudoPerfilAluno que a aba Perfil na Home, para manter
/// a paridade visual entre a tela dedicada e a aba.
class ProfileStudentScreen extends StatelessWidget {
  const ProfileStudentScreen({super.key});

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
                gradient: AppColors.greenHeaderGradient,
                child: Column(
                  children: [
                    TopBar(
                      titulo: 'Meu Perfil',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const ConteudoPerfilAluno(),
            ],
          ),
        ),
      ),
    );
  }
}
