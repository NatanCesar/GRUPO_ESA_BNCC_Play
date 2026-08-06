import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/questao_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/eixo_bncc.dart';
import '../../data/models/questao.dart';
import '../../data/models/dificuldade.dart';
import '../dashboard/dashboard_screen.dart';
import '../questions/axis_selection_screen.dart';
import '../questions/question_list_screen.dart';
import '../profile/widgets/conteudo_perfil_professor.dart';

/// Item de aba na barra inferior.
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

/// Home do professor com 4 abas reais (PageView).
///
/// Abas:
/// - 0: Home (visao geral)
/// - 1: Questoes (lista por eixo)
/// - 2: Dashboard
/// - 3: Perfil
class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
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
      id: 'questoes',
      icone: Icons.quiz_outlined,
      iconeAtivo: Icons.quiz,
      rotulo: 'Questões',
    ),
    _Aba(
      id: 'dashboard',
      icone: Icons.bar_chart_outlined,
      iconeAtivo: Icons.bar_chart,
      rotulo: 'Dashboard',
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

    if (usuario == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final telas = [
      const _AbaHomeProfessor(),
      const _AbaQuestoesProfessor(),
      const DashboardScreenPlaceholder(),
      const _AbaPerfilProfessor(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _indiceAtual = index),
        physics: const NeverScrollableScrollPhysics(),
        children: telas,
      ),
      bottomNavigationBar: _BottomNav(
        abas: _abas,
        ativo: _indiceAtual,
        onSelecionar: _onTabSelecionada,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
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
            color: ativo ? AppColors.purple : AppColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(
            aba.rotulo,
            style: TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 11,
              fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
              color: ativo ? AppColors.purple : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget wrapper para DashboardScreen com guarda de acesso.
class DashboardScreenPlaceholder extends StatelessWidget {
  const DashboardScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return const SizedBox.shrink();
    return DashboardScreen(professorId: usuario.id!);
  }
}

// ============================================================================
// ABA 1: HOME - Visao geral com stats e acoes rapidas
// ============================================================================

class _AbaHomeProfessor extends StatefulWidget {
  const _AbaHomeProfessor();

  @override
  State<_AbaHomeProfessor> createState() => _AbaHomeProfessorState();
}

class _AbaHomeProfessorState extends State<_AbaHomeProfessor> {
  int _totalQuestoes = 0;
  int _totalAlunos = 0;
  int _totalTurmas = 0;
  List<Questao> _questoesRecentes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    if (!mounted) return;
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return;

    final questaoRepo = context.read<QuestaoRepository>();
    final users = context.read<UserRepository>();

    try {
      final todas = await questaoRepo.listarPorProfessor(usuario.id!);
      final alunos = await users.listarAlunos();
      final turmas = <String>{};
      for (final u in alunos) {
        if (u.turma != null && u.turma!.isNotEmpty) turmas.add(u.turma!);
      }

      if (mounted) {
        setState(() {
          _totalQuestoes = todas.length;
          _totalAlunos = alunos.length;
          _totalTurmas = turmas.length;
          _questoesRecentes = todas.take(10).toList();
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
                child: _HeaderProfessor(primeiroNome: primeiroNome),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icone: Icons.quiz,
                          valor: '$_totalQuestoes',
                          label: 'Questões',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icone: Icons.group,
                          valor: '$_totalAlunos',
                          label: 'Alunos',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icone: Icons.school,
                          valor: '$_totalTurmas',
                          label: 'Turmas',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Ações Rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
                      icone: Icons.filter_alt_outlined,
                      titulo: 'Selecionar Eixo',
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.axisSelection,
                      ),
                    ),
                    _AcaoRapida(
                      icone: Icons.add_circle_outline,
                      titulo: 'Cadastrar Questão',
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.questionCreate,
                      ),
                    ),
                    _AcaoRapida(
                      icone: Icons.list_alt_outlined,
                      titulo: 'Minhas Questões',
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.questionList,
                        arguments: EixoBNCC.tecnologia,
                      ),
                    ),
                    _AcaoRapida(
                      icone: Icons.bar_chart,
                      titulo: 'Dashboard',
                      onTap: () {
                        // Trocar para aba Dashboard.
                        final state = context
                            .findAncestorStateOfType<_HomeTeacherScreenState>();
                        state?._onTabSelecionada(2);
                      },
                    ),
                  ],
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Questoes Recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuestaoCard(q: _questoesRecentes[index]),
                    ),
                    childCount: _questoesRecentes.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderProfessor extends StatelessWidget {
  const _HeaderProfessor({required this.primeiroNome});

  final String primeiroNome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
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
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
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
    required this.valor,
    required this.label,
  });

  final IconData icone;
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
          Icon(icone, color: AppColors.purple, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
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
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: AppColors.purple, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestaoCard extends StatelessWidget {
  const _QuestaoCard({required this.q});

  final Questao q;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          Rotas.questionEdit,
          arguments: q.id,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: AppColors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.enunciado,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Badge(label: _eixoLabel(q.eixo), cor: _eixoCor(q.eixo)),
                        const SizedBox(width: 6),
                        _Badge(label: _difLabel(q.dificuldade), cor: _difCor(q.dificuldade)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  String _eixoLabel(EixoBNCC eixo) {
    switch (eixo) {
      case EixoBNCC.tecnologia:
        return 'Tecnologia';
      case EixoBNCC.culturaDigital:
        return 'Cultura';
      case EixoBNCC.impacto:
        return 'Impacto';
    }
  }

  Color _eixoCor(EixoBNCC eixo) {
    switch (eixo) {
      case EixoBNCC.tecnologia:
        return AppColors.purple;
      case EixoBNCC.culturaDigital:
        return Colors.blue;
      case EixoBNCC.impacto:
        return Colors.green;
    }
  }

  String _difLabel(Dificuldade d) {
    switch (d) {
      case Dificuldade.facil:
        return 'Fácil';
      case Dificuldade.medio:
        return 'Médio';
      case Dificuldade.dificil:
        return 'Difícil';
    }
  }

  Color _difCor(Dificuldade d) {
    switch (d) {
      case Dificuldade.facil:
        return Colors.green;
      case Dificuldade.medio:
        return Colors.orange;
      case Dificuldade.dificil:
        return Colors.red;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.cor});

  final String label;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: cor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// ABA 2: QUESTOES - lista resumida por eixo
// ============================================================================

class _AbaQuestoesProfessor extends StatelessWidget {
  const _AbaQuestoesProfessor();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minhas Questões',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selecione um eixo para gerenciar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _EixoBotao(
                    icone: Icons.laptop_chromebook,
                    titulo: 'Tecnologia e Computação',
                    cor: AppColors.purple,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Rotas.questionList,
                      arguments: EixoBNCC.tecnologia,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EixoBotao(
                    icone: Icons.public,
                    titulo: 'Cultura Digital',
                    cor: Colors.blue,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Rotas.questionList,
                      arguments: EixoBNCC.culturaDigital,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EixoBotao(
                    icone: Icons.balance,
                    titulo: 'Impacto Social e Ética',
                    cor: Colors.green,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Rotas.questionList,
                      arguments: EixoBNCC.impacto,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        Rotas.questionCreate,
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Cadastrar Nova Questão'),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EixoBotao extends StatelessWidget {
  const _EixoBotao({
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ABA 4: PERFIL - usa o mesmo conteudo que ProfileTeacherScreen
// ============================================================================

class _AbaPerfilProfessor extends StatelessWidget {
  const _AbaPerfilProfessor();

  @override
  Widget build(BuildContext context) {
    // ConteudoPerfilProfessor nao tem Scaffold proprio, ideal para usar
    // dentro do PageView do pai.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: false,
          bottom: false,
          child: ConteudoPerfilProfessor(),
        ),
      ),
    );
  }
}
