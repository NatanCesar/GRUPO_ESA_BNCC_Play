import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gradient_header.dart';

/// Home do aluno com acesso ao jogo, ranking e perfil.
class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verificarSessao());
  }

  void _verificarSessao() {
    if (!mounted) return;
    final sessao = Provider.of<SessionScope>(context, listen: false);
    if (sessao.usuario == null) {
      Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
    }
  }

  static const _itens = [
    ItemDeNav(id: 'home', icone: Icons.home, rotulo: 'Inicio'),
    ItemDeNav(
      id: 'jogar',
      icone: Icons.sports_esports,
      rotulo: 'Jogar',
    ),
    ItemDeNav(
      id: 'ranking',
      icone: Icons.leaderboard,
      rotulo: 'Ranking',
    ),
    ItemDeNav(id: 'perfil', icone: Icons.account_circle, rotulo: 'Perfil'),
  ];

  void _selecionar(String id) {
    final sessao = Provider.of<SessionScope>(context, listen: false);
    final usuario = sessao.usuario;

    if (id == 'perfil') {
      Navigator.pushNamed(context, Rotas.profileStudent);
      return;
    }
    if (id == 'home') return;

    if (id == 'jogar') {
      Navigator.pushNamed(
        context,
        Rotas.jogar,
        arguments: {
          'alunoId': usuario!.id,
          'apelido': usuario.usuario,
        },
      );
      return;
    }

    if (id == 'ranking') {
      Navigator.pushNamed(
        context,
        Rotas.ranking,
        arguments: {'alunoId': usuario!.id},
      );
      return;
    }

    if (id == 'sala') {
      Navigator.pushNamed(context, Rotas.sala);
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card de jogar
                    _CardAcao(
                      icone: Icons.sports_esports,
                      titulo: 'Jogar',
                      subtitulo: 'Teste seus conhecimentos',
                      cor: AppColors.green,
                      onTap: () => _selecionar('jogar'),
                    ),
                    const SizedBox(height: 16),
                    // Card de ranking
                    _CardAcao(
                      icone: Icons.leaderboard,
                      titulo: 'Ranking',
                      subtitulo: 'Veja sua posicao',
                      cor: AppColors.purple,
                      onTap: () => _selecionar('ranking'),
                    ),
                    const SizedBox(height: 16),
                    // Card de sala multiplayer
                    _CardAcao(
                      icone: Icons.group,
                      titulo: 'Sala Multiplayer',
                      subtitulo: 'Desafie seus colegas',
                      cor: Colors.orange,
                      onTap: () => _selecionar('sala'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNav(
          itens: _itens,
          ativo: 'home',
          onSelecionar: _selecionar,
          cor: AppColors.green,
        ),
      ),
    );
  }
}

class _CardAcao extends StatelessWidget {
  const _CardAcao({
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
