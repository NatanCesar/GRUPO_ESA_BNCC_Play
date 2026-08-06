import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import 'widgets/perfil_widgets.dart';

/// Perfil do professor, com os dados do usuario logado.
///
/// As estatisticas ficam em zero: no ciclo 1 nao ha questoes nem turmas.
/// Numero fixo inventado passaria por bug quando o dado real chegasse.
class ProfileTeacherScreen extends StatelessWidget {
  const ProfileTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return const Scaffold(body: SizedBox.shrink());

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
                    const SizedBox(height: 8),
                    const AvatarDePerfil(emoji: '👩‍🏫'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.editProfile),
                    ),
                    const SizedBox(height: 12),
                    ItemDeMenu(
                      icone: Icons.school,
                      rotulo: 'Minha Escola',
                      detalhe: usuario.escola ?? '',
                      onTap: () {},
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
          ),
        ),
      ),
    );
  }
}
