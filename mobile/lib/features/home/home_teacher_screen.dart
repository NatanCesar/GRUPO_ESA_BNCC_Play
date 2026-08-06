import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_header.dart';
import '../../data/repositories/questao_repository.dart';
import '../../data/repositories/estatistica_repository.dart';
import '../../data/models/eixo_bncc.dart';
import '../dashboard/dashboard_screen.dart';
import '../questions/question_list_screen.dart';
import '../profile/profile_teacher_screen.dart';

/// Home do professor com navegacao por abas reais.
class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
  int _indiceAtual = 0;
  late List<Widget> _telas;
  late PageController _pageController;

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

    // Inicializa as telas com acesso ao contexto (apos sessao verificada).
    _telas = [
      _HomeTab(usuarioId: usuario.id!),
      _QuestoesTab(usuarioId: usuario.id!),
      DashboardScreen(professorId: usuario.id!),
      const ProfileTeacherScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _indiceAtual = index),
        physics: const NeverScrollableScrollPhysics(),
        children: _telas,
      ),
      bottomNavigationBar: _BottomNavProfessor(
        ativo: _indiceAtual,
        onSelecionar: _onTabSelecionada,
      ),
    );
  }
}

/// Conteudo da aba Home (diferente da pagina de questoes).
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.usuarioId});

  final int usuarioId;

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
        body: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GradientHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ola, $primeiroNome!',
                        style: AppTheme.headerTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario.escola ?? '',
                        style: AppTheme.headerSubtitle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visao Geral',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gerencie suas questoes e acompanhe o desempenho dos alunos.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cards de acao rapida
                      _AcaoRapidaCard(
                        icone: Icons.add_circle_outline,
                        titulo: 'Cadastrar Questao',
                        subtitulo: 'Adicione novas perguntas ao banco',
                        cor: AppColors.purple,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Rotas.questionCreate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AcaoRapidaCard(
                        icone: Icons.analytics_outlined,
                        titulo: 'Ver Estatisticas',
                        subtitulo: 'Acompanhe o desempenho dos alunos',
                        cor: Colors.blue,
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _AcaoRapidaCard(
                        icone: Icons.quiz_outlined,
                        titulo: 'Minhas Questoes',
                        subtitulo: 'Veja todas as suas perguntas',
                        cor: Colors.green,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Rotas.questionList,
                          arguments: EixoBNCC.tecnologia,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aba de questoes (navegacao por eixo).
class _QuestoesTab extends StatefulWidget {
  const _QuestoesTab({required this.usuarioId});

  final int usuarioId;

  @override
  State<_QuestoesTab> createState() => _QuestoesTabState();
}

class _QuestoesTabState extends State<_QuestoesTab> {
  Map<EixoBNCC, int> _contagens = {};

  @override
  void initState() {
    super.initState();
    _carregarContagens();
  }

  Future<void> _carregarContagens() async {
    final repository = context.read<QuestaoRepository>();
    try {
      final contagens = await repository.contarPorEixo(widget.usuarioId);
      if (mounted) {
        setState(() => _contagens = contagens);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _carregarContagens,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GradientHeader(
                  child: const Text(
                    'Minhas Questoes',
                    style: AppTheme.headerTitle,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Selecione um eixo para ver ou cadastrar questoes',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EixoCard(
                      icone: '💻',
                      titulo: 'Tecnologia e Computacao',
                      quantidade: _contagens[EixoBNCC.tecnologia] ?? 0,
                      cor: AppColors.purple,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.questionList,
                        arguments: EixoBNCC.tecnologia,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EixoCard(
                      icone: '🌐',
                      titulo: 'Cultura Digital',
                      quantidade: _contagens[EixoBNCC.culturaDigital] ?? 0,
                      cor: Colors.blue,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.questionList,
                        arguments: EixoBNCC.culturaDigital,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EixoCard(
                      icone: '⚖️',
                      titulo: 'Impacto Social e Etica',
                      quantidade: _contagens[EixoBNCC.impacto] ?? 0,
                      cor: Colors.green,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.questionList,
                        arguments: EixoBNCC.impacto,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavProfessor extends StatelessWidget {
  const _BottomNavProfessor({
    required this.ativo,
    required this.onSelecionar,
  });

  final int ativo;
  final ValueChanged<int> onSelecionar;

  static const _itens = [
    (icone: Icons.home_outlined, iconeAtivo: Icons.home, rotulo: 'Inicio'),
    (icone: Icons.quiz_outlined, iconeAtivo: Icons.quiz, rotulo: 'Questoes'),
    (icone: Icons.bar_chart_outlined, iconeAtivo: Icons.bar_chart, rotulo: 'Dashboard'),
    (icone: Icons.person_outline, iconeAtivo: Icons.person, rotulo: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _itens.length; i++)
                Expanded(
                  child: _ItemNav(
                    icone: _itens[i].icone,
                    iconeAtivo: _itens[i].iconeAtivo,
                    rotulo: _itens[i].rotulo,
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
    required this.icone,
    required this.iconeAtivo,
    required this.rotulo,
    required this.ativo,
    required this.onTap,
  });

  final IconData icone;
  final IconData iconeAtivo;
  final String rotulo;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ativo ? iconeAtivo : icone,
            size: 24,
            color: ativo ? AppColors.purple : AppColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
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

class _AcaoRapidaCard extends StatelessWidget {
  const _AcaoRapidaCard({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EixoCard extends StatelessWidget {
  const _EixoCard({
    required this.icone,
    required this.titulo,
    required this.quantidade,
    required this.cor,
    required this.onTap,
  });

  final String icone;
  final String titulo;
  final int quantidade;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
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
                child: Center(
                  child: Text(icone, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$quantidade ${quantidade == 1 ? 'questao' : 'questoes'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
