import 'package:sqflite/sqflite.dart';

import '../../core/security/password_hasher.dart';
import '../../data/db/app_database.dart';
import '../../data/models/app_user.dart';
import '../../data/errors.dart';
import 'user_repository.dart';

/// Autenticacao local com bloqueio por tentativas.
///
/// O contador vive em `login_attempts`, chaveado por e-mail, e nao em
/// memoria: fechar o app nao pode ser o jeito de escapar do bloqueio.
class AuthRepository {
  AuthRepository({
    required AppDatabase banco,
    required UserRepository usuarios,
    PasswordHasher hasher = const PasswordHasher(),
    DateTime Function() agora = DateTime.now,
  })  : _db = banco.db,
        _usuarios = usuarios,
        _hasher = hasher,
        _agora = agora;

  static const int maxTentativas = 5;
  static const Duration duracaoDoBloqueio = Duration(seconds: 60);

  final Database _db;
  final UserRepository _usuarios;
  final PasswordHasher _hasher;
  final DateTime Function() _agora;

  Future<AppUser> entrar({
    required String email,
    required String senha,
  }) async {
    final chave = email.trim().toLowerCase();

    final restante = await _segundosDeBloqueio(chave);
    if (restante > 0) {
      throw LoginBloqueadoException(restante);
    }

    final usuario = await _usuarios.porEmail(chave);
    if (usuario == null) {
      throw const CredenciaisInvalidasException();
    }

    final credencial = await _credencialDe(usuario.id!);
    final confere = _hasher.confere(
      senha,
      hash: credencial.$1,
      salt: credencial.$2,
    );

    if (!confere) {
      await _registrarFalha(chave);
      throw const CredenciaisInvalidasException();
    }

    await _limparTentativas(chave);
    return usuario;
  }

  Future<(String, String)> _credencialDe(int id) async {
    final linhas = await _db.query(
      'users',
      columns: ['senha_hash', 'salt'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    final linha = linhas.single;
    return (linha['senha_hash'] as String, linha['salt'] as String);
  }

  Future<int> _segundosDeBloqueio(String email) async {
    final linhas = await _db.query(
      'login_attempts',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (linhas.isEmpty) return 0;

    final ate = linhas.first['bloqueado_ate'] as String?;
    if (ate == null) return 0;

    final fim = DateTime.parse(ate);
    final falta = fim.difference(_agora().toUtc()).inSeconds;
    return falta > 0 ? falta : 0;
  }

  Future<void> _registrarFalha(String email) async {
    final linhas = await _db.query(
      'login_attempts',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    final falhas = linhas.isEmpty ? 1 : (linhas.first['falhas'] as int) + 1;

    if (falhas >= maxTentativas) {
      final ate = _agora().toUtc().add(duracaoDoBloqueio);
      await _gravarTentativa(email, falhas: 0, bloqueadoAte: ate);
      return;
    }

    await _gravarTentativa(email, falhas: falhas, bloqueadoAte: null);
  }

  Future<void> _gravarTentativa(
    String email, {
    required int falhas,
    required DateTime? bloqueadoAte,
  }) {
    return _db.insert(
      'login_attempts',
      {
        'email': email,
        'falhas': falhas,
        'bloqueado_ate': bloqueadoAte?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _limparTentativas(String email) {
    return _db.delete('login_attempts', where: 'email = ?', whereArgs: [email]);
  }
}
