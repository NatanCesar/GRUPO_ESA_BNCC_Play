import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes.dart';
import '../../../core/session/session_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_badge.dart';
import 'perfil_widgets.dart';

/// Conteudo do perfil do aluno, sem Scaffold nem TopBar.
///
/// Usado dentro do PageView como aba, onde o pai ja tem Scaffold+BottomNav.
class ConteudoPerfilAluno extends StatelessWidget {
  const ConteudoPerfilAluno({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const AvatarDePerfil(emoji: 'sports_esports'),
              const SizedBox(height: 8),
              Text(usuario.nome, style: AppTheme.headerTitle),
              const SizedBox(height: 4),
              Text('@${usuario.usuario}', style: AppTheme.headerSubtitle),
              const SizedBox(height: 8),
              AppBadge(rotulo: usuario.papel.rotulo, cor: AppColors.purple),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        valor: '-',
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
                  detalhe: 'Nome, e-mail e usuario',
                  cor: AppColors.green,
                  fundoDoIcone: AppColors.greenLight,
                  onTap: () => Navigator.pushNamed(context, Rotas.editProfile),
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
    );
  }
}
