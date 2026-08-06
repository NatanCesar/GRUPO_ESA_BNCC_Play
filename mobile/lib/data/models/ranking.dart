/// Entrada no ranking de jogadores.
///
/// Atualizada ao final de cada partida.
class RankingEntry {
  RankingEntry({
    this.id,
    required this.alunoId,
    required this.apelido,
    required this.pontuacaoTotal,
    required this.totalJogos,
    required this.taxaAcerto,
    required this.atualizadoEm,
  });

  final int? id;
  final int alunoId;
  final String apelido;
  final int pontuacaoTotal;
  final int totalJogos;
  final double taxaAcerto;
  final DateTime atualizadoEm;

  Map<String, Object?> paraLinha() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'aluno_id': alunoId,
      'apelido': apelido,
      'pontuacao_total': pontuacaoTotal,
      'total_jogos': totalJogos,
      'taxa_acerto': taxaAcerto,
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

  factory RankingEntry.deLinha(Map<String, Object?> linha) {
    return RankingEntry(
      id: linha['id'] as int?,
      alunoId: linha['aluno_id'] as int,
      apelido: linha['apelido'] as String,
      pontuacaoTotal: linha['pontuacao_total'] as int,
      totalJogos: linha['total_jogos'] as int,
      taxaAcerto: (linha['taxa_acerto'] as num).toDouble(),
      atualizadoEm: DateTime.parse(linha['atualizado_em'] as String),
    );
  }

  RankingEntry copiarCom({
    int? id,
    int? alunoId,
    String? apelido,
    int? pontuacaoTotal,
    int? totalJogos,
    double? taxaAcerto,
    DateTime? atualizadoEm,
  }) {
    return RankingEntry(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      apelido: apelido ?? this.apelido,
      pontuacaoTotal: pontuacaoTotal ?? this.pontuacaoTotal,
      totalJogos: totalJogos ?? this.totalJogos,
      taxaAcerto: taxaAcerto ?? this.taxaAcerto,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
