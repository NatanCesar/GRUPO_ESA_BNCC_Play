import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_header.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_controller.dart';

/// Tela de login com autenticacao real.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
      auth: context.read<AuthRepository>(),
      sessao: context.read<SessionScope>(),
    );
    _controller.onChanged = _onControllerChanged;
    _emailCtrl.addListener(_controller.limparErro);
    _senhaCtrl.addListener(_controller.limparErro);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_controller.limparErro);
    _senhaCtrl.removeListener(_controller.limparErro);
    _controller.onChanged = null;
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final usuario = await _controller.entrar(
      email: _emailCtrl.text,
      senha: _senhaCtrl.text,
    );
    if (usuario == null || !mounted) return;

    final sessao = context.read<SessionScope>();
    sessao.abrir(usuario);

    final destino = usuario.papel == Papel.professor
        ? Rotas.homeTeacher
        : Rotas.homeStudent;
    Navigator.pushNamedAndRemoveUntil(context, destino, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                    if (_controller.erroGeral != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _controller.erroGeral!,
                                style: AppTheme.fieldError,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    AppTextField(
                      label: 'E-mail',
                      controller: _emailCtrl,
                      hint: 'seu@email.com',
                      icon: Icons.email,
                      errorText: _controller.erroEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Senha',
                      controller: _senhaCtrl,
                      hint: 'Sua senha',
                      icon: Icons.lock,
                      errorText: _controller.erroSenha,
                      obscureText: !_senhaVisivel,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _entrar(),
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
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, Rotas.forgotPassword),
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
                      loading: _controller.carregando,
                      onPressed: _entrar,
                    ),
                    const SizedBox(height: 28),
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
                          onTap: () =>
                              Navigator.pushNamed(context, Rotas.registerType),
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
            width: 88,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const AppLogo.mark(key: Key('login-logo')),
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
