/// Sessao de jogo do aluno — uma partida de quiz.
///
/// Contem a pontuacao, streak e stats da sessao.
class Partida {
  Partida({
    this.id,
    required this.alunoId,
    this.eixo,
    required this.pontuacao,
    required this.streak,
    required this.respondidas,
    required this.acertos,
    required this.iniciadaEm,
    this.terminadaEm,
  });

  final int? id;
  final int alunoId;
  final String? eixo;
  final int pontuacao;
  final int streak;
  final int respondidas;
  final int acertos;
  final DateTime iniciadaEm;
  final DateTime? terminadaEm;

  /// Percentual de acerto (0-100).
  double get acertoPercentual =>
      respondidas == 0 ? 0 : (acertos / respondidas) * 100;

  bool get emAndamento => terminadaEm == null;

  Map<String, Object?> paraLinha() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'aluno_id': alunoId,
      'eixo': eixo,
      'pontuacao': pontuacao,
      'streak': streak,
      'respondidas': respondidas,
      'acertos': acertos,
      'iniciada_em': iniciadaEm.toUtc().toIso8601String(),
      'terminada_em': terminadaEm?.toUtc().toIso8601String(),
    };
  }

  factory Partida.deLinha(Map<String, Object?> linha) {
    return Partida(
      id: linha['id'] as int?,
      alunoId: linha['aluno_id'] as int,
      eixo: linha['eixo'] as String?,
      pontuacao: linha['pontuacao'] as int,
      streak: linha['streak'] as int,
      respondidas: linha['respondidas'] as int,
      acertos: linha['acertos'] as int,
      iniciadaEm: DateTime.parse(linha['iniciada_em'] as String),
      terminadaEm: linha['terminada_em'] == null
          ? null
          : DateTime.parse(linha['terminada_em'] as String),
    );
  }

  Partida copiarCom({
    int? id,
    int? alunoId,
    String? eixo,
    int? pontuacao,
    int? streak,
    int? respondidas,
    int? acertos,
    DateTime? iniciadaEm,
    DateTime? terminadaEm,
  }) {
    return Partida(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      eixo: eixo ?? this.eixo,
      pontuacao: pontuacao ?? this.pontuacao,
      streak: streak ?? this.streak,
      respondidas: respondidas ?? this.respondidas,
      acertos: acertos ?? this.acertos,
      iniciadaEm: iniciadaEm ?? this.iniciadaEm,
      terminadaEm: terminadaEm ?? this.terminadaEm,
    );
  }
}
