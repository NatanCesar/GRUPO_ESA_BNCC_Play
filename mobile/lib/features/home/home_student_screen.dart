import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_header.dart';
import '../ranking/ranking_screen.dart';
import '../sala/sala_screen.dart';
import '../profile/profile_student_screen.dart';

/// Home do aluno com navegacao por abas reais.
class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  int _indiceAtual = 0;
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

    final telas = [
      _HomeTab(usuario: usuario),
      const SizedBox(), // Placeholder - navegacao sera via botoes
      RankingScreen(alunoId: usuario.id!),
      const ProfileStudentScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _indiceAtual = index),
        physics: const NeverScrollableScrollPhysics(),
        children: telas,
      ),
      bottomNavigationBar: _BottomNavAluno(
        ativo: _indiceAtual,
        onSelecionar: _onTabSelecionada,
      ),
    );
  }
}

/// Conteudo da aba Home do aluno.
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.usuario});

  final dynamic usuario;

  @override
  Widget build(BuildContext context) {
    final primeiroNome = usuario.nome.split(' ').first;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ola, $primeiroNome!',
                      style: AppTheme.headerTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario.turma ?? '',
                      style: AppTheme.headerSubtitle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card principal de jogar
                    _CardJogar(
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.jogar,
                        arguments: {
                          'alunoId': usuario.id,
                          'apelido': usuario.usuario,
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cards secundarios
                    Row(
                      children: [
                        Expanded(
                          child: _CardSecundario(
                            icone: Icons.leaderboard,
                            titulo: 'Ranking',
                            cor: AppColors.purple,
                            onTap: () => Navigator.pushNamed(
                              context,
                              Rotas.ranking,
                              arguments: {'alunoId': usuario.id},
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CardSecundario(
                            icone: Icons.group,
                            titulo: 'Sala',
                            cor: Colors.orange,
                            onTap: () => Navigator.pushNamed(
                              context,
                              Rotas.sala,
                            ),
                          ),
                        ),
                      ],
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '+XP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Jogar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Teste seus conhecimentos sobre a BNCC',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSecundario extends StatelessWidget {
  const _CardSecundario({
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: cor, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
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

class _BottomNavAluno extends StatelessWidget {
  const _BottomNavAluno({
    required this.ativo,
    required this.onSelecionar,
  });

  final int ativo;
  final ValueChanged<int> onSelecionar;

  static const _itens = [
    (icone: Icons.home_outlined, iconeAtivo: Icons.home, rotulo: 'Inicio'),
    (icone: Icons.sports_esports_outlined, iconeAtivo: Icons.sports_esports, rotulo: 'Jogar'),
    (icone: Icons.leaderboard_outlined, iconeAtivo: Icons.leaderboard, rotulo: 'Ranking'),
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
            color: ativo ? AppColors.green : AppColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
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
