import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/aviso_de_ciclo.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gradient_header.dart';

/// Home do aluno. Casca: saúda o usuario logado e leva ao perfil. Os
/// destinos dos ciclos 2 a 4 avisam em vez de ficar mudos.
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
    ItemDeNav(id: 'home', icone: Icons.home, rotulo: 'Início'),
    ItemDeNav(
      id: 'jogar',
      icone: Icons.sports_esports,
      rotulo: 'Jogar',
      habilitado: false,
    ),
    ItemDeNav(
      id: 'ranking',
      icone: Icons.leaderboard,
      rotulo: 'Ranking',
      habilitado: false,
    ),
    ItemDeNav(id: 'perfil', icone: Icons.account_circle, rotulo: 'Perfil'),
  ];

  void _selecionar(String id) {
    if (id == 'perfil') {
      Navigator.pushNamed(context, Rotas.profileStudent);
      return;
    }
    if (id == 'home') return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Disponível na próxima entrega.')),
      );
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
                      'Olá, $primeiroNome!',
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
                child: AvisoDeCiclo(
                  texto:
                      'O jogo, a pontuação e o ranking chegam na próxima entrega.',
                  cor: AppColors.green,
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
