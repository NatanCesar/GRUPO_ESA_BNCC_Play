/// Estatisticas agregadas para o dashboard do professor.
class EstatisticaGeral {
  EstatisticaGeral({
    this.totalAlunos = 0,
    this.totalPartidas = 0,
    this.totalRespostas = 0,
    this.totalAcertos = 0,
    this.somaPontuacao = 0,
  });

  final int totalAlunos;
  final int totalPartidas;
  final int totalRespostas;
  final int totalAcertos;
  final int somaPontuacao;

  /// Pontuacao media por partida.
  double get mediaPontuacao =>
      totalPartidas > 0 ? somaPontuacao / totalPartidas : 0;

  /// Taxa de acerto media (0-100).
  double get taxaAcertoMedia =>
      totalRespostas > 0 ? (totalAcertos / totalRespostas) * 100 : 0;

  factory EstatisticaGeral.deLinha(Map<String, Object?> linha) {
    return EstatisticaGeral(
      totalAlunos: linha['total_alunos'] as int? ?? 0,
      totalPartidas: linha['total_partidas'] as int? ?? 0,
      totalRespostas: linha['total_respostas'] as int? ?? 0,
      totalAcertos: linha['total_acertos'] as int? ?? 0,
      somaPontuacao: linha['soma_pontuacao'] as int? ?? 0,
    );
  }

  EstatisticaGeral copiarCom({
    int? totalAlunos,
    int? totalPartidas,
    int? totalRespostas,
    int? totalAcertos,
    int? somaPontuacao,
  }) {
    return EstatisticaGeral(
      totalAlunos: totalAlunos ?? this.totalAlunos,
      totalPartidas: totalPartidas ?? this.totalPartidas,
      totalRespostas: totalRespostas ?? this.totalRespostas,
      totalAcertos: totalAcertos ?? this.totalAcertos,
      somaPontuacao: somaPontuacao ?? this.somaPontuacao,
    );
  }
}

/// Estatistica de uma questao especifica.
class EstatisticaQuestao {
  EstatisticaQuestao({
    required this.questaoId,
    required this.enunciado,
    required this.totalRespostas,
    required this.totalAcertos,
  });

  final int questaoId;
  final String enunciado;
  final int totalRespostas;
  final int totalAcertos;

  /// Taxa de acerto (0-100).
  double get taxaAcerto =>
      totalRespostas > 0 ? (totalAcertos / totalRespostas) * 100 : 0;
}
