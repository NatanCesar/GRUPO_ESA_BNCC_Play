import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gradient_header.dart';
import '../../data/repositories/questao_repository.dart';
import '../../data/models/eixo_bncc.dart';

/// Home do professor com acesso a gestao de questoes.
class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
  Map<EixoBNCC, int> _contagens = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarSessao();
      _carregarContagens();
    });
  }

  void _verificarSessao() {
    if (!mounted) return;
    final sessao = Provider.of<SessionScope>(context, listen: false);
    if (sessao.usuario == null) {
      Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
    }
  }

  Future<void> _carregarContagens() async {
    final sessao = context.read<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return;

    final repository = context.read<QuestaoRepository>();
    try {
      final contagens = await repository.contarPorEixo(usuario.id!);
      if (mounted) {
        setState(() => _contagens = contagens);
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  static const _itens = [
    ItemDeNav(id: 'home', icone: Icons.home, rotulo: 'Inicio'),
    ItemDeNav(id: 'questoes', icone: Icons.quiz, rotulo: 'Questoes'),
    ItemDeNav(id: 'dashboard', icone: Icons.bar_chart, rotulo: 'Dashboard'),
    ItemDeNav(id: 'perfil', icone: Icons.account_circle, rotulo: 'Perfil'),
  ];

  void _selecionar(String id) {
    if (id == 'perfil') {
      Navigator.pushNamed(context, Rotas.profileTeacher);
      return;
    }
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
    if (id == 'home') return;
  }

  @override
  Widget build(BuildContext context) {
    final sessao = Provider.of<SessionScope>(context);
    final usuario = sessao.usuario;

    if (usuario == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final primeiroNome = usuario.nome.split(' ').first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _carregarContagens,
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
                        'Gerenciar Questoes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selecione um eixo para ver ou cadastrar questoes',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEixoCard(
                        icone: '💻',
                        titulo: 'Tecnologia e Computacao',
                        quantidade: _contagens[EixoBNCC.tecnologia] ?? 0,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Rotas.questionList,
                          arguments: EixoBNCC.tecnologia,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEixoCard(
                        icone: '🌐',
                        titulo: 'Cultura Digital',
                        quantidade: _contagens[EixoBNCC.culturaDigital] ?? 0,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Rotas.questionList,
                          arguments: EixoBNCC.culturaDigital,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEixoCard(
                        icone: '⚖️',
                        titulo: 'Impacto Social e Etica',
                        quantidade: _contagens[EixoBNCC.impacto] ?? 0,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Rotas.questionList,
                          arguments: EixoBNCC.impacto,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, Rotas.axisSelection),
                          icon: const Icon(Icons.add),
                          label: const Text('Selecionar Eixo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNav(
          itens: _itens,
          ativo: 'home',
          onSelecionar: _selecionar,
        ),
      ),
    );
  }

  Widget _buildEixoCard({
    required String icone,
    required String titulo,
    required int quantidade,
    required VoidCallback onTap,
  }) {
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
                  color: AppColors.purpleLight,
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
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
