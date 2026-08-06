import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import 'widgets/conteudo_perfil_professor.dart';

/// Perfil do professor.
///
/// Usa o mesmo ConteudoPerfilProfessor que a aba Perfil na Home, para
/// manter a paridade visual entre a tela dedicada e a aba.
class ProfileTeacherScreen extends StatelessWidget {
  const ProfileTeacherScreen({super.key});

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
                  children: [
                    TopBar(
                      titulo: 'Meu Perfil',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
              const ConteudoPerfilProfessor(),
            ],
          ),
        ),
      ),
    );
  }
}
