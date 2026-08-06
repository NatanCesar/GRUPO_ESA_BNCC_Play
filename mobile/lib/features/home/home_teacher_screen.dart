import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../data/repositories/questao_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/eixo_bncc.dart';
import '../../data/models/questao.dart';
import '../../data/models/dificuldade.dart';

/// Home do professor com layout conforme prototipo.
///
/// Estrutura:
/// - Header com saudacao e avatar
/// - Cards de stats (Questoes, Alunos, Turmas)
/// - Acoes rapidas (Selecionar Eixo, Cadastrar Questao, Minhas Questoes, Dashboard)
/// - Lista de Questoes Recentes
class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
  Map<EixoBNCC, int> _contagemPorEixo = {};
  int _totalQuestoes = 0;
  int _totalAlunos = 0;
  int _totalTurmas = 0;
  List<Questao> _questoesRecentes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarSessao();
      _carregarTudo();
    });
  }

  void _verificarSessao() {
    if (!mounted) return;
    final sessao = Provider.of<SessionScope>(context, listen: false);
    if (sessao.usuario == null) {
      Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
    }
  }

  Future<void> _carregarTudo() async {
    if (!mounted) return;
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return;

    final questaoRepo = context.read<QuestaoRepository>();

    try {
      // Stats de questoes.
      final contagens = await questaoRepo.contarPorEixo(usuario.id!);
      final todas = await questaoRepo.listarPorProfessor(usuario.id!);

      // Stats de alunos.
      final usuarios = context.read<UserRepository>();
      final alunos = await usuarios.listarAlunos();
      final turmasUnicas = <String>{};
      for (final u in alunos) {
        if (u.turma != null && u.turma!.isNotEmpty) {
          turmasUnicas.add(u.turma!);
        }
      }

      if (mounted) {
        setState(() {
          _contagemPorEixo = contagens;
          _totalQuestoes = todas.length;
          _totalAlunos = alunos.length;
          _totalTurmas = turmasUnicas.length;
          _questoesRecentes = todas.take(5).toList();
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  static const _itens = [
    ItemDeNav(id: 'home', icone: Icons.home, rotulo: 'Inicio'),
    ItemDeNav(id: 'questoes', icone: Icons.quiz, rotulo: 'Questoes'),
    ItemDeNav(id: 'dashboard', icone: Icons.bar_chart, rotulo: 'Dashboard'),
    ItemDeNav(id: 'perfil', icone: Icons.account_circle, rotulo: 'Perfil'),
  ];

  void _selecionar(String id) {
    if (id == 'questoes') {
      Navigator.pushNamed(context, Rotas.axisSelection);
      return;
    }
    if (id == 'dashboard') {
      final sessao = context.read<SessionScope>();
      Navigator.pushNamed(
        context,
        Rotas.dashboard,
        arguments: {'professorId': sessao.usuario!.id},
      );
      return;
    }
    if (id == 'perfil') {
      Navigator.pushNamed(context, Rotas.profileTeacher);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessao = Provider.of<SessionScope>(context);
    final usuario = sessao.usuario;

    if (usuario == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final primeiroNome = usuario.nome.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _carregarTudo,
        child: CustomScrollView(
          slivers: [
            // Header com avatar
            SliverToBoxAdapter(
              child: _HeaderProfessor(
                primeiroNome: primeiroNome,
                perfilUrl: usuario.avatar,
              ),
            ),

            // Cards de stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icone: Icons.quiz,
                        label: 'Questoes',
                        valor: '$_totalQuestoes',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icone: Icons.group,
                        label: 'Alunos',
                        valor: '$_totalAlunos',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icone: Icons.school,
                        label: 'Turmas',
                        valor: '$_totalTurmas',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Acoes rapidas
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Acoes Rapidas',
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
                childAspectRatio: 1.4,
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
                    titulo: 'Cadastrar Questao',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Rotas.questionCreate,
                    ),
                  ),
                  _AcaoRapida(
                    icone: Icons.list_alt_outlined,
                    titulo: 'Minhas Questoes',
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
                      final s = context.read<SessionScope>();
                      Navigator.pushNamed(
                        context,
                        Rotas.dashboard,
                        arguments: {'professorId': s.usuario!.id},
                      );
                    },
                  ),
                ],
              ),
            ),

            // Questoes Recentes
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
              sliver: _questoesRecentes.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: const Text(
                          'Nenhuma questao cadastrada ainda',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : SliverList(
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
      bottomNavigationBar: BottomNav(
        itens: _itens,
        ativo: 'home',
        onSelecionar: _selecionar,
        cor: AppColors.purple,
      ),
    );
  }
}

class _HeaderProfessor extends StatelessWidget {
  const _HeaderProfessor({
    required this.primeiroNome,
    this.perfilUrl,
  });

  final String primeiroNome;
  final String? perfilUrl;

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
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
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
    required this.label,
    required this.valor,
  });

  final IconData icone;
  final String label;
  final String valor;

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
            offset: const Offset(0, 2),
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
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Badge(
                          label: _eixoLabel(q.eixo),
                          cor: _eixoCor(q.eixo),
                        ),
                        const SizedBox(width: 6),
                        _Badge(
                          label: _difLabel(q.dificuldade),
                          cor: _difCor(q.dificuldade),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
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
        return 'Facil';
      case Dificuldade.medio:
        return 'Medio';
      case Dificuldade.dificil:
        return 'Dificil';
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
