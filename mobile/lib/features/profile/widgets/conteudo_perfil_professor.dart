import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes.dart';
import '../../../core/session/session_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/gradient_header.dart';
import 'perfil_widgets.dart';

/// Conteudo do perfil do professor, sem Scaffold nem TopBar.
///
/// Usado dentro do PageView como aba, onde o pai ja tem Scaffold+BottomNav.
class ConteudoPerfilProfessor extends StatelessWidget {
  const ConteudoPerfilProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return const SizedBox.shrink();

    // Conteudo sem SingleChildScrollView proprio: as telas que usam este
    // widget ja envolvem o resultado em scroll (ProfileTeacherScreen e a
    // aba Perfil da Home). Aninhar dois SingleChildScrollView causa um
    // espaco em branco entre o GradientHeader e o conteudo abaixo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientHeader(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const AvatarDePerfil(emoji: 'person'),
              const SizedBox(height: 8),
              Text(usuario.nome, style: AppTheme.headerTitle),
              const SizedBox(height: 4),
              Text(usuario.email, style: AppTheme.headerSubtitle),
              const SizedBox(height: 8),
              AppBadge(rotulo: usuario.papel.rotulo, cor: AppColors.green),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: CartaoDeEstatistica(
                      icone: Icons.quiz,
                      valor: '0',
                      rotulo: 'Questões',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CartaoDeEstatistica(
                      icone: Icons.group,
                      valor: '0',
                      rotulo: 'Alunos',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CartaoDeEstatistica(
                      icone: Icons.class_,
                      valor: '0',
                      rotulo: 'Turmas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ItemDeMenu(
                icone: Icons.person,
                rotulo: 'Editar Perfil',
                detalhe: 'Nome, e-mail e usuário',
                onTap: () => Navigator.pushNamed(context, Rotas.editProfile),
              ),
              const SizedBox(height: 12),
              ItemDeMenu(
                icone: Icons.school,
                rotulo: 'Minha Escola',
                detalhe: usuario.escola ?? '',
                onTap: () => Navigator.pushNamed(context, Rotas.editProfile),
              ),
              const SizedBox(height: 24),
              BotaoSair(
                onSair: () {
                  context.read<SessionScope>().encerrar();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Rotas.splash,
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
