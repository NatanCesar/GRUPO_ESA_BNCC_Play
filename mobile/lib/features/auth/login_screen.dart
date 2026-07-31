import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_header.dart';

/// Tela de login do prototipo Figma do BNCC Play.
///
/// Demo de uma tela: valida os campos localmente e avisa por SnackBar que os
/// destinos ainda nao existem. Sem navegacao e sem chamadas de rede.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  String? _emailError;
  String? _senhaError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _clearErrorWhenTyping(isEmail: true));
    _senhaController.addListener(() => _clearErrorWhenTyping(isEmail: false));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Some com o erro assim que o campo deixa de estar vazio.
  void _clearErrorWhenTyping({required bool isEmail}) {
    final controller = isEmail ? _emailController : _senhaController;
    final error = isEmail ? _emailError : _senhaError;
    if (error == null || controller.text.trim().isEmpty) return;

    setState(() {
      if (isEmail) {
        _emailError = null;
      } else {
        _senhaError = null;
      }
    });
  }

  void _entrar() {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    setState(() {
      _emailError = email.isEmpty ? 'Informe seu e-mail' : null;
      _senhaError = senha.isEmpty ? 'Informe sua senha' : null;
    });

    if (_emailError != null || _senhaError != null) return;

    _avisar('Login em desenvolvimento.');
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // O cabecalho e escuro, entao os icones do sistema vao em claro.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'E-mail',
                      controller: _emailController,
                      hint: 'seu@email.com',
                      icon: Icons.email,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Senha',
                      controller: _senhaController,
                      hint: 'Sua senha',
                      icon: Icons.lock,
                      errorText: _senhaError,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _entrar(),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            _avisar('Recuperação de senha em desenvolvimento.'),
                        child: const Text(
                          'Esqueci minha senha',
                          style: AppTheme.link,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Entrar',
                      icon: Icons.login,
                      onPressed: _entrar,
                    ),
                    const SizedBox(height: 20),
                    const _OuDivider(),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Entrar como Aluno',
                      icon: Icons.school,
                      variant: AppButtonVariant.ghost,
                      onPressed: () =>
                          _avisar('Acesso do aluno em desenvolvimento.'),
                    ),
                    const SizedBox(height: 28),
                    // Wrap em vez de Row: em telas estreitas ou com fonte do
                    // sistema ampliada, o convite quebra em duas linhas em vez
                    // de estourar a largura.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text(
                          'Não tem conta?',
                          style: AppTheme.footerText,
                        ),
                        GestureDetector(
                          onTap: () => _avisar('Cadastro em desenvolvimento.'),
                          child: const Text(
                            'Criar conta',
                            style: AppTheme.footerLink,
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sports_esports,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bem-vindo de volta!',
            textAlign: TextAlign.center,
            style: AppTheme.headerTitle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Entre para continuar jogando',
            textAlign: TextAlign.center,
            style: AppTheme.headerSubtitle,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OuDivider extends StatelessWidget {
  const _OuDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}
