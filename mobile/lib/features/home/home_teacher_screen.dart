import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/aviso_de_ciclo.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gradient_header.dart';

/// Home do professor. Casca: saúda o usuario logado e leva ao perfil. Os
/// destinos dos ciclos 2 a 4 avisam em vez de ficar mudos.
class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
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
      id: 'questoes',
      icone: Icons.quiz,
      rotulo: 'Questões',
      habilitado: false,
    ),
    ItemDeNav(
      id: 'dashboard',
      icone: Icons.bar_chart,
      rotulo: 'Dashboard',
      habilitado: false,
    ),
    ItemDeNav(id: 'perfil', icone: Icons.account_circle, rotulo: 'Perfil'),
  ];

  void _selecionar(String id) {
    if (id == 'perfil') {
      Navigator.pushNamed(context, Rotas.profileTeacher);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $primeiroNome!',
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: AvisoDeCiclo(
                  texto:
                      'Cadastro de questões, dashboard e relatórios chegam nas próximas entregas.',
                ),
              ),
            ],
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
}
