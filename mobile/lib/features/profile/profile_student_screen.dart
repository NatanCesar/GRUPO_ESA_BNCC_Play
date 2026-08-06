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

/// Perfil do aluno, com os dados do usuario logado.
///
/// As estatisticas ficam em zero: no ciclo 1 nao ha XP nem partidas.
/// Sem secao de conquistas: nao ha dado de jogo no ciclo 1.
class ProfileStudentScreen extends StatelessWidget {
  const ProfileStudentScreen({super.key});

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
                gradient: AppColors.greenHeaderGradient,
                child: Column(
                  children: [
                    TopBar(
                      titulo: 'Meu Perfil',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 8),
                    const AvatarDePerfil(emoji: 'sports_esports'),
                    const SizedBox(height: 8),
                    Text(usuario.nome, style: AppTheme.headerTitle),
                    const SizedBox(height: 4),
                    Text(
                      '@${usuario.usuario}',
                      style: AppTheme.headerSubtitle,
                    ),
                    const SizedBox(height: 8),
                    AppBadge(
                      rotulo: usuario.papel.rotulo,
                      cor: AppColors.purple,
                    ),
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
                    Row(
                      children: [
                        Expanded(
                          child: CartaoDeEstatistica(
                            icone: Icons.star,
                            valor: '0',
                            rotulo: 'XP Total',
                            cor: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CartaoDeEstatistica(
                            icone: Icons.leaderboard,
                            valor: '—',
                            rotulo: 'Ranking',
                            cor: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CartaoDeEstatistica(
                            icone: Icons.check_circle,
                            valor: '0%',
                            rotulo: 'Acertos',
                            cor: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ItemDeMenu(
                      icone: Icons.person,
                      rotulo: 'Editar Perfil',
                      detalhe: 'Nome, e-mail e usuário',
                      cor: AppColors.green,
                      fundoDoIcone: AppColors.greenLight,
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.editProfile),
                    ),
                    const SizedBox(height: 12),
                    ItemDeMenu(
                      icone: Icons.group,
                      rotulo: 'Minha Turma',
                      detalhe: usuario.turma ?? '',
                      cor: AppColors.green,
                      fundoDoIcone: AppColors.greenLight,
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
