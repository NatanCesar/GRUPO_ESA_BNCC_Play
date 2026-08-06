import 'package:flutter/foundation.dart';

import '../../core/session/session_scope.dart';
import '../../core/validation/validators.dart';
import '../../data/models/app_user.dart';
import '../../data/models/papel.dart';
import '../../data/errors.dart';
import '../../data/repositories/user_repository.dart';

/// Estado das duas telas de cadastro. O que muda entre elas e o [papel] e o
/// campo extra: escola para professor, turma para aluno.
class RegisterController extends ChangeNotifier {
  RegisterController({
    required UserRepository usuarios,
    required SessionScope sessao,
    required this.papel,
  })  : _usuarios = usuarios,
        _sessao = sessao;

  final UserRepository _usuarios;
  final SessionScope _sessao;
  final Papel papel;

  final Map<String, String?> erros = <String, String?>{};
  bool carregando = false;
  String? erroGeral;

  Future<AppUser?> cadastrar({
    required String nome,
    required String email,
    required String usuario,
    required String senha,
    String? escola,
    String? turma,
  }) async {
    erros
      ..clear()
      ..addAll({
        'nome': Validators.nome(nome),
        'email': Validators.email(email),
        'usuario': Validators.usuario(usuario),
        'senha': Validators.senha(senha),
        if (papel == Papel.professor) 'escola': Validators.escola(escola),
        if (papel == Papel.aluno) 'turma': Validators.turma(turma),
      });
    erros.removeWhere((_, mensagem) => mensagem == null);
    erroGeral = null;

    if (erros.isNotEmpty) {
      notifyListeners();
      return null;
    }

    carregando = true;
    notifyListeners();

    try {
      final novo = await _usuarios.cadastrar(
        nome: nome,
        email: email,
        usuario: usuario,
        senha: senha,
        papel: papel,
        escola: escola,
        turma: turma,
      );
      // Cadastrar ja entra: o prototipo leva direto para a home.
      _sessao.abrir(novo);
      return novo;
    } on ErroDeDominio catch (e) {
      erroGeral = e.mensagem;
      return null;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void limparErros() {
    if (erros.isEmpty && erroGeral == null) return;
    erros.clear();
    erroGeral = null;
    notifyListeners();
  }
}
