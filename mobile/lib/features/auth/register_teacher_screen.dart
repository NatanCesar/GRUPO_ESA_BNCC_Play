import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/user_repository.dart';
import 'register_controller.dart';

/// Cadastro de professor. Cinco campos, nem um a mais: CT03 cobra
/// minimizacao de dados.
class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _usuario = TextEditingController();
  final _escola = TextEditingController();
  final _senha = TextEditingController();

  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(
      usuarios: context.read<UserRepository>(),
      sessao: context.read<SessionScope>(),
      papel: Papel.professor,
    )..addListener(_aoMudar);
  }

  void _aoMudar() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_aoMudar);
    _controller.dispose();
    for (final campo in [_nome, _email, _usuario, _escola, _senha]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _criarConta() async {
    final novo = await _controller.cadastrar(
      nome: _nome.text,
      email: _email.text,
      usuario: _usuario.text,
      senha: _senha.text,
      escola: _escola.text,
    );
    if (novo == null || !mounted) return;
    Navigator.pushReplacementNamed(context, Rotas.homeTeacher);
  }

  @override
  Widget build(BuildContext context) {
    final erros = _controller.erros;

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
                    TopBar(
                      titulo: 'Cadastro Professor',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text('👩‍🏫', style: TextStyle(fontSize: 34)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Crie sua conta gratuita e comece a ensinar de forma gamificada',
                            style: AppTheme.headerSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Nome completo',
                      controller: _nome,
                      hint: 'Maria Silva',
                      icon: Icons.person,
                      errorText: erros['nome'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail institucional',
                      controller: _email,
                      hint: 'maria@escola.edu.br',
                      icon: Icons.email,
                      errorText: erros['email'],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nome de usuário',
                      controller: _usuario,
                      hint: 'mariasilva',
                      icon: Icons.alternate_email,
                      errorText: erros['usuario'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Escola',
                      controller: _escola,
                      hint: 'E.E. Monteiro Lobato',
                      icon: Icons.school,
                      errorText: erros['escola'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Senha',
                      controller: _senha,
                      hint: 'Mínimo 8 caracteres',
                      icon: Icons.lock,
                      errorText: erros['senha'],
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _criarConta(),
                    ),
                    const SizedBox(height: 24),
                    if (_controller.erroGeral != null) ...[
                      _AvisoDeErro(mensagem: _controller.erroGeral!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: 'Criar Conta',
                      icon: Icons.how_to_reg,
                      onPressed: _criarConta,
                      loading: _controller.carregando,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text('Já tem conta?', style: AppTheme.footerText),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, Rotas.login),
                          child: const Text('Entrar', style: AppTheme.footerLink),
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

/// Caixa vermelha de erro da operacao, acima do botao de acao.
class _AvisoDeErro extends StatelessWidget {
  const _AvisoDeErro({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(mensagem, style: AppTheme.fieldError)),
        ],
      ),
    );
  }
}
