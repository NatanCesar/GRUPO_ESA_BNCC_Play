import 'papel.dart';

/// Usuario do app.
///
/// Nao carrega hash nem salt de proposito: o que sai do repositorio para a
/// interface nao deve ter como vazar credencial. O hash entra por parametro
/// em [paraLinha] e fica so no banco.
class AppUser {
  const AppUser({
    this.id,
    required this.nome,
    required this.email,
    required this.usuario,
    required this.papel,
    this.escola,
    this.turma,
    this.avatar,
    this.professorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final int? id;
  final String nome;
  final String email;
  final String usuario;
  final Papel papel;
  final String? escola;
  final String? turma;
  final String? avatar;
  final int? professorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Map<String, Object?> paraLinha({
    required String senhaHash,
    required String salt,
  }) {
    return <String, Object?>{
      'nome': nome,
      'email': email,
      'usuario': usuario,
      'senha_hash': senhaHash,
      'salt': salt,
      'papel': papel.valor,
      'escola': escola,
      'turma': turma,
      'avatar': avatar,
      'professor_id': professorId,
      'criado_em': criadoEm.toUtc().toIso8601String(),
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

  static AppUser deLinha(Map<String, Object?> linha) {
    return AppUser(
      id: linha['id'] as int?,
      nome: linha['nome'] as String,
      email: linha['email'] as String,
      usuario: linha['usuario'] as String,
      papel: Papel.dePersistencia(linha['papel'] as String),
      escola: linha['escola'] as String?,
      turma: linha['turma'] as String?,
      avatar: linha['avatar'] as String?,
      professorId: linha['professor_id'] as int?,
      criadoEm: DateTime.parse(linha['criado_em'] as String),
      atualizadoEm: DateTime.parse(linha['atualizado_em'] as String),
    );
  }

  AppUser copiarCom({
    String? nome,
    String? email,
    String? usuario,
    String? escola,
    String? turma,
    String? avatar,
    int? professorId,
    DateTime? atualizadoEm,
  }) {
    return AppUser(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      usuario: usuario ?? this.usuario,
      papel: papel,
      escola: escola ?? this.escola,
      turma: turma ?? this.turma,
      avatar: avatar ?? this.avatar,
      professorId: professorId ?? this.professorId,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
