import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/aviso_de_erro.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/user_repository.dart';
import 'register_controller.dart';

/// Cadastro de aluno. Cinco campos: nome, email, usuario, turma, senha.
class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _usuario = TextEditingController();
  final _turma = TextEditingController();
  final _senha = TextEditingController();
  bool _senhaVisivel = false;

  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(
      usuarios: context.read<UserRepository>(),
      sessao: context.read<SessionScope>(),
      papel: Papel.aluno,
    )..addListener(_aoMudar);
  }

  void _aoMudar() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_aoMudar);
    _controller.dispose();
    for (final campo in [_nome, _email, _usuario, _turma, _senha]) {
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
      turma: _turma.text,
    );
    if (novo == null || !mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Rotas.homeStudent, (_) => false);
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
                gradient: AppColors.greenHeaderGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(
                      titulo: 'Cadastro Aluno',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.school, size: 32, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Entre para o universo da computação com diversão',
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
                      hint: 'João Santos',
                      icon: Icons.person,
                      errorText: erros['nome'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail',
                      controller: _email,
                      hint: 'joao@email.com',
                      icon: Icons.email,
                      errorText: erros['email'],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nome de usuário',
                      controller: _usuario,
                      hint: 'joaosantos',
                      icon: Icons.alternate_email,
                      errorText: erros['usuário'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Turma',
                      controller: _turma,
                      hint: '9º Ano A',
                      icon: Icons.group,
                      errorText: erros['turma'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Senha',
                      controller: _senha,
                      hint: 'Mínimo 8 caracteres',
                      icon: Icons.lock,
                      errorText: erros['senha'],
                      obscureText: !_senhaVisivel,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _criarConta(),
                      suffixIcon: IconButton(
                        key: const Key('toggle-password-visibility'),
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: AppColors.purple,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                        tooltip: _senhaVisivel
                            ? 'Esconder senha'
                            : 'Mostrar senha',
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_controller.erroGeral != null) ...[
                      AvisoDeErro(mensagem: _controller.erroGeral!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: 'Criar Conta',
                      icon: Icons.how_to_reg,
                      onPressed: _criarConta,
                      variant: AppButtonVariant.green,
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
                          child: Text(
                            'Entrar',
                            style: AppTheme.footerLink.copyWith(
                              color: AppColors.green,
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
