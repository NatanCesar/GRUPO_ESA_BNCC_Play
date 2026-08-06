import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/aviso_de_erro.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/user_repository.dart';
import 'profile_controller.dart';

/// Edicao de cadastro, para professor e aluno.
///
/// O campo extra segue o papel do usuario logado: escola para professor,
/// turma para aluno. Senha nao se altera por aqui.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _usuario = TextEditingController();
  final _extra = TextEditingController();

  late final ProfileController _controller;
  bool _preenchido = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(
      usuarios: context.read<UserRepository>(),
      sessao: context.read<SessionScope>(),
    )..addListener(_aoMudar);
  }

  void _aoMudar() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_aoMudar);
    _controller.dispose();
    for (final campo in [_nome, _email, _usuario, _extra]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    final papel = context.read<SessionScope>().usuario?.papel;
    final ok = await _controller.salvar(
      nome: _nome.text,
      email: _email.text,
      usuario: _usuario.text,
      escola: papel == Papel.professor ? _extra.text : null,
      turma: papel == Papel.aluno ? _extra.text : null,
    );
    if (!ok || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Dados atualizados')));
  }

  @override
  Widget build(BuildContext context) {
    final sessao = Provider.of<SessionScope>(context);
    final usuario = sessao.usuario;

    if (usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    // Preenche uma vez so: repetir a cada build apagaria o que o usuario
    // digitou.
    if (!_preenchido) {
      _nome.text = usuario.nome;
      _email.text = usuario.email;
      _usuario.text = usuario.usuario;
      _extra.text = usuario.escola ?? usuario.turma ?? '';
      _preenchido = true;
    }

    final ehProfessor = usuario.papel == Papel.professor;
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
                gradient: ehProfessor
                    ? AppColors.headerGradient
                    : AppColors.greenHeaderGradient,
                child: TopBar(
                  titulo: 'Editar Perfil',
                  onVoltar: () => Navigator.maybePop(context),
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
                      icon: Icons.person,
                      errorText: erros['nome'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail',
                      controller: _email,
                      icon: Icons.email,
                      errorText: erros['email'],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nome de usuário',
                      controller: _usuario,
                      icon: Icons.alternate_email,
                      errorText: erros['usuario'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: ehProfessor ? 'Escola' : 'Turma',
                      controller: _extra,
                      icon: ehProfessor ? Icons.school : Icons.group,
                      errorText: erros[ehProfessor ? 'escola' : 'turma'],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _salvar(),
                    ),
                    const SizedBox(height: 24),
                    if (_controller.erroGeral != null) ...[
                      AvisoDeErro(mensagem: _controller.erroGeral!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: 'Salvar',
                      icon: Icons.save,
                      variant: ehProfessor
                          ? AppButtonVariant.primary
                          : AppButtonVariant.green,
                      onPressed: _salvar,
                      loading: _controller.carregando,
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
