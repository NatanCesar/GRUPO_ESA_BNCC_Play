import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes.dart';
import '../../../core/session/session_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/ranking_repository.dart';
import 'perfil_widgets.dart';

/// Conteudo do perfil do aluno, sem Scaffold nem TopBar.
///
/// Usado dentro do PageView como aba, onde o pai ja tem Scaffold+BottomNav.
class ConteudoPerfilAluno extends StatefulWidget {
  const ConteudoPerfilAluno({super.key});

  @override
  State<ConteudoPerfilAluno> createState() => ConteudoPerfilAlunoState();
}

/// State publico para permitir refresh a partir da Home.
class ConteudoPerfilAlunoState extends State<ConteudoPerfilAluno> {
  int? _xpTotal;
  int? _posicao;
  double? _taxaAcerto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  /// Recarrega os KPIs do aluno a partir do banco.
  ///
  /// Pode ser chamado de fora (ex.: quando o aluno volta de uma partida).
  void recarregar() {
    if (!mounted) return;
    _carregar();
  }

  Future<void> _carregar() async {
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return;

    final repo = RankingRepository(banco: context.read<AppDatabase>());
    try {
      final entrada = await repo.porAluno(usuario.id!);
      final pos = await repo.posicaoOrdinal(usuario.id!);
      if (!mounted) return;
      setState(() {
        _xpTotal = entrada?.pontuacaoTotal ?? 0;
        _posicao = pos;
        _taxaAcerto = entrada?.taxaAcerto ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return const SizedBox.shrink();

    final xp = _xpTotal?.toString() ?? '0';
    final ranking = _posicao != null ? '#$_posicao' : '-';
    final acerto = _taxaAcerto != null
        ? '${_taxaAcerto!.toStringAsFixed(0)}%'
        : '0%';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header com gradiente verde (tema do aluno)
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.greenHeaderGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
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
              ),
            ),
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
                        valor: xp,
                        rotulo: 'XP Total',
                        cor: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CartaoDeEstatistica(
                        icone: Icons.leaderboard,
                        valor: ranking,
                        rotulo: 'Ranking',
                        cor: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CartaoDeEstatistica(
                        icone: Icons.check_circle,
                        valor: acerto,
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
                  onTap: () async {
                    await Navigator.pushNamed(context, Rotas.editProfile);
                    if (mounted) _carregar();
                  },
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
