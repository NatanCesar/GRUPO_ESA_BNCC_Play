import 'package:flutter/foundation.dart';

import '../../core/session/session_scope.dart';
import '../../core/validation/validators.dart';
import '../../data/models/papel.dart';
import '../../data/errors.dart';
import '../../data/repositories/user_repository.dart';

/// Estado da edicao de perfil, para os dois papeis.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required UserRepository usuarios,
    required SessionScope sessao,
  })  : _usuarios = usuarios,
        _sessao = sessao;

  final UserRepository _usuarios;
  final SessionScope _sessao;

  final Map<String, String?> erros = <String, String?>{};
  bool carregando = false;
  String? erroGeral;
  bool salvo = false;

  Future<bool> salvar({
    required String nome,
    required String email,
    required String usuario,
    String? escola,
    String? turma,
  }) async {
    salvo = false;

    // A sessao e conferida antes de qualquer escrita: expirada, nada muda.
    final atual = _sessao.usuario;
    if (atual == null) {
      erroGeral = const SessaoExpiradaException().mensagem;
      notifyListeners();
      return false;
    }

    erros
      ..clear()
      ..addAll({
        'nome': Validators.nome(nome),
        'email': Validators.email(email),
        'usuario': Validators.usuario(usuario),
        if (atual.papel == Papel.professor) 'escola': Validators.escola(escola),
        if (atual.papel == Papel.aluno) 'turma': Validators.turma(turma),
      });
    erros.removeWhere((_, mensagem) => mensagem == null);
    erroGeral = null;

    if (erros.isNotEmpty) {
      notifyListeners();
      return false;
    }

    carregando = true;
    notifyListeners();

    try {
      final atualizado = await _usuarios.atualizar(
        atual.copiarCom(
          nome: nome,
          email: email,
          usuario: usuario,
          escola: escola,
          turma: turma,
        ),
      );
      _sessao.abrir(atualizado);
      salvo = true;
      return true;
    } on ErroDeDominio catch (e) {
      erroGeral = e.mensagem;
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
