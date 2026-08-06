/// Participacao de um aluno em uma partida multiplayer.
///
/// Usado quando o aluno entra em uma sala multiplayer (CT16).
class Participacao {
  Participacao({
    this.id,
    required this.partidaId,
    required this.alunoId,
    required this.apelido,
    required this.pontuacao,
    required this.entrouEm,
  });

  final int? id;
  final int partidaId;
  final int alunoId;
  final String apelido;
  final int pontuacao;
  final DateTime entrouEm;

  Map<String, Object?> paraLinha() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'partida_id': partidaId,
      'aluno_id': alunoId,
      'apelido': apelido,
      'pontuacao': pontuacao,
      'entrou_em': entrouEm.toUtc().toIso8601String(),
    };
  }

  factory Participacao.deLinha(Map<String, Object?> linha) {
    return Participacao(
      id: linha['id'] as int?,
      partidaId: linha['partida_id'] as int,
      alunoId: linha['aluno_id'] as int,
      apelido: linha['apelido'] as String,
      pontuacao: linha['pontuacao'] as int,
      entrouEm: DateTime.parse(linha['entrou_em'] as String),
    );
  }

  Participacao copiarCom({
    int? id,
    int? partidaId,
    int? alunoId,
    String? apelido,
    int? pontuacao,
    DateTime? entrouEm,
  }) {
    return Participacao(
      id: id ?? this.id,
      partidaId: partidaId ?? this.partidaId,
      alunoId: alunoId ?? this.alunoId,
      apelido: apelido ?? this.apelido,
      pontuacao: pontuacao ?? this.pontuacao,
      entrouEm: entrouEm ?? this.entrouEm,
    );
  }
}
