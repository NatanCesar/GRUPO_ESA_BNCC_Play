import 'package:sqflite/sqflite.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/core/validation/sanitizer.dart';
import 'package:bncc_play_mobile/core/validation/validators.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/errors.dart';

/// Acesso a dados do usuario no banco local.
///
/// Nao expõe hash nem salt: `AppUser` e construit a partir da linha sem
/// esses campos.
class UserRepository {
  const UserRepository({
    required this._banco,
    required this._hasher,
  });

  final AppDatabase _banco;
  final PasswordHasher _hasher;

  /// Cadastra um novo usuario.
  ///
  /// Lança [EmailJaCadastradoException] se o e-mail já estiver no banco.
  /// Lança [UsuarioJaCadastradoException] se o nome de usuário já estiver
  /// em uso.
  Future<AppUser> cadastrar({
    required String nome,
    required String email,
    required String usuario,
    required String senha,
    required Papel papel,
    String? escola,
    String? turma,
  }) async {
    final erros = <String>[];

    if (Validators.nome(nome) != null) {
      erros.add(Validators.nome(nome)!);
    }
    if (Validators.email(email) != null) {
      erros.add(Validators.email(email)!);
    }
    if (Validators.usuario(usuario) != null) {
      erros.add(Validators.usuario(usuario)!);
    }
    if (Validators.senha(senha) != null) {
      erros.add(Validators.senha(senha)!);
    }

    if (papel == Papel.professor) {
      if (Validators.escola(escola) != null) {
        erros.add('Informe sua escola');
      }
    }
    if (papel == Papel.aluno) {
      if (Validators.turma(turma) != null) {
        erros.add('Informe sua turma');
      }
    }

    if (erros.isNotEmpty) throw ArgumentError(erros.join('; '));

    final normalizado = email.trim().toLowerCase();
    final agora = DateTime.now().toUtc();

    final limpo = _limpar({
      'nome': nome,
      'usuario': usuario,
      if (escola != null) 'escola': escola,
      if (turma != null) 'turma': turma,
    });

    final cifrada = _hasher.cifrar(senha);

    try {
      final id = await _banco.db.insert('users', {
        ...limpo,
        'email': normalizado,
        'senha_hash': cifrada.hash,
        'salt': cifrada.salt,
        'papel': papel.valor,
        'criado_em': agora.toIso8601String(),
        'atualizado_em': agora.toIso8601String(),
      });

      return (await porId(id))!;
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed: users.email')) {
        throw const EmailJaCadastradoException();
      }
      if (e.toString().contains('UNIQUE constraint failed: users.usuario')) {
        throw const UsuarioJaCadastradoException();
      }
      rethrow;
    }
  }

  /// Devolve o usuario cujo e-mail e [email], ignorando espacos e caixa.
  Future<AppUser?> porEmail(String email) async {
    final normalizado = email.trim().toLowerCase();
    final linhas = await _banco.db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizado],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return AppUser.deLinha(linhas.single);
  }

  /// Devolve o usuario de id [id], ou null se nao existir.
  Future<AppUser?> porId(int id) async {
    final linhas = await _banco.db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return AppUser.deLinha(linhas.single);
  }

  /// Lista todos os usuarios cadastrados.
  Future<List<AppUser>> buscarTodos() async {
    final linhas = await _banco.db.query('users');
    return linhas.map(AppUser.deLinha).toList();
  }

  /// Lista alunos cadastrados.
  Future<List<AppUser>> listarAlunos() async {
    final linhas = await _banco.db.query(
      'users',
      where: 'papel = ?',
      whereArgs: ['aluno'],
    );
    return linhas.map(AppUser.deLinha).toList();
  }

  /// Atualiza os dados de [usuario].
  ///
  /// [usuario] precisa de [AppUser.id] preenchido. Lança [ArgumentError]
  /// caso contrario.
  Future<AppUser> atualizar(AppUser usuario) async {
    final id = usuario.id;
    if (id == null) throw ArgumentError('Atualizar exige id preenchido');

    final erros = <String>[];
    if (Validators.email(usuario.email) != null) {
      erros.add(Validators.email(usuario.email)!);
    }
    if (Validators.usuario(usuario.usuario) != null) {
      erros.add(Validators.usuario(usuario.usuario)!);
    }
    if (usuario.papel == Papel.professor) {
      if (Validators.escola(usuario.escola) != null) {
        erros.add('Informe sua escola');
      }
    }
    if (erros.isNotEmpty) throw ArgumentError(erros.join('; '));

    final agora = DateTime.now().toUtc();

    final limpo = _limpar({
      'nome': usuario.nome,
      'usuario': usuario.usuario,
      if (usuario.escola != null) 'escola': usuario.escola!,
      if (usuario.turma != null) 'turma': usuario.turma!,
    });

    try {
      await _banco.db.update(
        'users',
        {
          ...limpo,
          'email': usuario.email.trim().toLowerCase(),
          'atualizado_em': agora.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed: users.email')) {
        throw const EmailJaCadastradoException();
      }
      rethrow;
    }

    return (await porId(id))!;
  }

  /// Aplica [Sanitizer.limpar] a cada campo de texto em [campos].
  Map<String, String> _limpar(Map<String, String> campos) {
    return Map.fromEntries(
      campos.entries.map((e) => MapEntry(e.key, Sanitizer.limpar(e.value))),
    );
  }
}
