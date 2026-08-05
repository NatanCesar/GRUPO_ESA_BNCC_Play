import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/erros.dart';
import 'package:bncc_play_mobile/data/repositories/session_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

/// Resultado de login ou cadastro: token de sessao e perfil do usuario.
class AuthResultado {
  const AuthResultado({required this.token, required this.perfil});
  final String token;
  final dynamic perfil; // AppUser — import ciclico se nomeado
}

/// Controlador de autenticacao.
///
/// Orquestra [UserRepository] e [SessionRepository], traduzindo erros de
/// dominio em exceptions de negocio para a tela.
class AuthController {
  AuthController({
    required AppDatabase banco,
    required PasswordHasher hasher,
  })  : _banco = banco,
        _hasher = hasher;

  final AppDatabase _banco;
  final PasswordHasher _hasher;

  late final UserRepository _users = UserRepository(
    banco: _banco,
    hasher: _hasher,
  );

  /// Cadastra e abre sessao em um unico passo.
  Future<AuthResultado> cadastrar({
    required String nome,
    required String email,
    required String usuario,
    required String senha,
    required Papel papel,
    String? escola,
    String? turma,
  }) async {
    final user = await _users.cadastrar(
      nome: nome,
      email: email,
      usuario: usuario,
      senha: senha,
      papel: papel,
      escola: escola,
      turma: turma,
    );

    final sessao = await SessionRepository.abrir(
      banco: _banco,
      usuarioId: user.id!,
      papel: user.papel.valor,
    );

    return AuthResultado(token: sessao.token, perfil: user);
  }

  /// Valida credenciais e abre sessao.
  Future<AuthResultado> login({
    required String email,
    required String senha,
  }) async {
    final user = await _users.porEmail(email);

    if (user == null) {
      throw const CredenciaisInvalidasException();
    }

    // Busca hash e salt direto no banco para poder comparar.
    final linhas = await _banco.db.query(
      'users',
      columns: ['senha_hash', 'salt'],
      where: 'id = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    final linha = linhas.single;

    final confere = _hasher.confere(
      senha,
      hash: linha['senha_hash'] as String,
      salt: linha['salt'] as String,
    );

    if (!confere) {
      throw const CredenciaisInvalidasException();
    }

    final sessao = await SessionRepository.abrir(
      banco: _banco,
      usuarioId: user.id!,
      papel: user.papel.valor,
    );

    return AuthResultado(token: sessao.token, perfil: user);
  }

  /// Encerra a sessao ativa.
  Future<void> logout({required int usuarioId}) async {
    await SessionRepository.fechar(banco: _banco, usuarioId: usuarioId);
  }

  /// Valida token de sessao.
  Future<void> validarToken({
    required int usuarioId,
    required String token,
  }) async {
    await SessionRepository.validar(
      banco: _banco,
      usuarioId: usuarioId,
      token: token,
    );
  }
}
