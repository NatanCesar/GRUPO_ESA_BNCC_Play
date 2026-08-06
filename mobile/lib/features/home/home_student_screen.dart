import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/ranking_repository.dart';
import '../../data/models/ranking.dart';
import '../ranking/ranking_screen.dart';

class _Aba {
  const _Aba({
    required this.id,
    required this.icone,
    required this.iconeAtivo,
    required this.rotulo,
  });
  final String id;
  final IconData icone;
  final IconData iconeAtivo;
  final String rotulo;
}

/// Home do aluno com 4 abas reais (PageView).
class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  int _indiceAtual = 0;
  late PageController _pageController;

  static const _abas = [
    _Aba(
      id: 'home',
      icone: Icons.home_outlined,
      iconeAtivo: Icons.home,
      rotulo: 'Inicio',
    ),
    _Aba(
      id: 'jogar',
      icone: Icons.sports_esports_outlined,
      iconeAtivo: Icons.sports_esports,
      rotulo: 'Jogar',
    ),
    _Aba(
      id: 'ranking',
      icone: Icons.leaderboard_outlined,
      iconeAtivo: Icons.leaderboard,
      rotulo: 'Ranking',
    ),
    _Aba(
      id: 'perfil',
      icone: Icons.person_outline,
      iconeAtivo: Icons.person,
      rotulo: 'Perfil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verificarSessao());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _verificarSessao() {
    if (!mounted) return;
    final sessao = Provider.of<SessionScope>(context, listen: false);
    if (sessao.usuario == null) {
      Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
    }
  }

  void _onTabSelecionada(int index) {
    setState(() => _indiceAtual = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessao = Provider.of<SessionScope>(context);
    final usuario = sessao.usuario;
    if (usuario == null) return const Scaffold(body: SizedBox.shrink());

    final telas = [
      const _AbaHomeAluno(),
      _AbaJogarAluno(usuario: usuario),
      _AbaRankingAluno(usuarioId: usuario.id!),
      _AbaPerfilAluno(usuario: usuario),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _indiceAtual = i),
        physics: const NeverScrollableScrollPhysics(),
        children: telas,
      ),
      bottomNavigationBar: _BottomNavAluno(
        abas: _abas,
        ativo: _indiceAtual,
        onSelecionar: _onTabSelecionada,
      ),
    );
  }
}

class _BottomNavAluno extends StatelessWidget {
  const _BottomNavAluno({
    required this.abas,
    required this.ativo,
    required this.onSelecionar,
  });

  final List<_Aba> abas;
  final int ativo;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < abas.length; i++)
                Expanded(
                  child: _ItemNav(
                    aba: abas[i],
                    ativo: ativo == i,
                    onTap: () => onSelecionar(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  const _ItemNav({
    required this.aba,
    required this.ativo,
    required this.onTap,
  });

  final _Aba aba;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ativo ? aba.iconeAtivo : aba.icone,
            size: 24,
            color: ativo ? AppColors.green : AppColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(
            aba.rotulo,
            style: TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 11,
              fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
              color: ativo ? AppColors.green : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ABA 1: HOME (visao geral com card jogar + stats + grid)
// ============================================================================

class _AbaHomeAluno extends StatefulWidget {
  const _AbaHomeAluno();

  @override
  State<_AbaHomeAluno> createState() => _AbaHomeAlunoState();
}

class _AbaHomeAlunoState extends State<_AbaHomeAluno> {
  RankingEntry? _minhaEntrada;
  int? _minhaPosicao;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return;

    final repo = context.read<RankingRepository>();
    try {
      final entrada = await repo.porAluno(usuario.id!);
      final pos = await repo.posicaoOrdinal(usuario.id!);
      if (mounted) {
        setState(() {
          _minhaEntrada = entrada;
          _minhaPosicao = pos;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final sessao = Provider.of<SessionScope>(context);
    final usuario = sessao.usuario;
    if (usuario == null) return const SizedBox.shrink();

    final primeiroNome = usuario.nome.split(' ').first;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _carregar,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ola,',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${primeiroNome.toUpperCase()}.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white
                                      .withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          if (usuario.turma != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.school,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  usuario.turma!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _CardJogar(
                    onTap: () => Navigator.pushNamed(
                      context,
                      Rotas.jogar,
                      arguments: {
                        'alunoId': usuario.id,
                        'apelido': usuario.usuario,
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icone: Icons.star,
                          cor: Colors.amber,
                          valor: '${_minhaEntrada?.pontuacaoTotal ?? 0}',
                          label: 'XP Total',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icone: Icons.emoji_events,
                          cor: AppColors.green,
                          valor: _minhaPosicao != null ? '#$_minhaPosicao' : '-',
                          label: 'Ranking',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icone: Icons.percent,
                          cor: Colors.blue,
                          valor: '${(_minhaEntrada?.taxaAcerto ?? 0).toStringAsFixed(0)}%',
                          label: 'Acerto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Acoes Rapidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _AcaoRapida(
                      icone: Icons.leaderboard,
                      titulo: 'Ver Ranking',
                      cor: AppColors.green,
                      onTap: () {
                        final state = context
                            .findAncestorStateOfType<_HomeStudentScreenState>();
                        state?._onTabSelecionada(2);
                      },
                    ),
                    _AcaoRapida(
                      icone: Icons.group,
                      titulo: 'Sala Multiplayer',
                      cor: Colors.orange,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.sala,
                      ),
                    ),
                  ],
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardJogar extends StatelessWidget {
  const _CardJogar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sports_esports,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Jogar Agora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teste seus conhecimentos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icone,
    required this.cor,
    required this.valor,
    required this.label,
  });

  final IconData icone;
  final Color cor;
  final String valor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcaoRapida extends StatelessWidget {
  const _AcaoRapida({
    required this.icone,
    required this.titulo,
    required this.cor,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ABA 2: JOGAR - tela propria para selecao de jogo
// ============================================================================

class _AbaJogarAluno extends StatelessWidget {
  const _AbaJogarAluno({required this.usuario});

  final dynamic usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        title: const Text('Jogar'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card destaque jogar agora
            Material(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pushNamed(
                  context,
                  Rotas.jogar,
                  arguments: {
                    'alunoId': usuario.id,
                    'apelido': usuario.usuario,
                  },
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.sports_esports,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Iniciar Partida',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '5 perguntas aleatorias',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Escolha por eixo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // Cards para escolher eixo (visivel ao aluno futuramente)
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ABA 3: RANKING (wrapper simples para evitar Scaffold duplo)
// ============================================================================

class _AbaRankingAluno extends StatelessWidget {
  const _AbaRankingAluno({required this.usuarioId});

  final int usuarioId;

  @override
  Widget build(BuildContext context) {
    return RankingScreen(alunoId: usuarioId);
  }
}

// ============================================================================
// ABA 4: PERFIL (placeholder inline)
// ============================================================================

class _AbaPerfilAluno extends StatelessWidget {
  const _AbaPerfilAluno({required this.usuario});

  final dynamic usuario;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.person, size: 48, color: AppColors.green),
            ),
            const SizedBox(height: 16),
            Text(
              usuario.nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              usuario.email,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Rotas.editProfile),
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
