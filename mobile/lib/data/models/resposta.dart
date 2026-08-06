class RespostaDetalhada {
  const RespostaDetalhada({
    required this.partidaId,
    required this.questaoId,
    required this.enunciado,
    required this.respostaAluno,
    required this.respostaCorreta,
    required this.correta,
    required this.respondidaEm,
  });

  final int partidaId;
  final int questaoId;
  final String enunciado;
  final String respostaAluno;
  final String respostaCorreta;
  final bool correta;
  final DateTime respondidaEm;

  factory RespostaDetalhada.deLinha(Map<String, Object?> linha) {
    return RespostaDetalhada(
      partidaId: linha['partida_id'] as int,
      questaoId: linha['questao_id'] as int,
      enunciado: linha['enunciado'] as String,
      respostaAluno: linha['resposta_aluno'] as String,
      respostaCorreta: linha['resposta_correta'] as String,
      correta: linha['correta'] == 1,
      respondidaEm: DateTime.parse(linha['respondida_em'] as String),
    );
  }
}
