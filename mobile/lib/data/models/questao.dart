import 'eixo_bncc.dart';
import 'dificuldade.dart';

/// Questao do quiz BNCC.
class Questao {
  const Questao({
    this.id,
    required this.enunciado,
    required this.opcaoA,
    required this.opcaoB,
    required this.opcaoC,
    required this.opcaoD,
    required this.respostaCorreta,
    required this.eixo,
    required this.dificuldade,
    this.categoria = 'Geral',
    required this.professorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final int? id;
  final String enunciado;
  final String opcaoA;
  final String opcaoB;
  final String opcaoC;
  final String opcaoD;
  final String respostaCorreta; // 'A', 'B', 'C' ou 'D'
  final EixoBNCC eixo;
  final Dificuldade dificuldade;
  final String categoria;
  final int professorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Map<String, Object?> paraLinha() {
    return <String, Object?>{
      'enunciado': enunciado,
      'opcao_a': opcaoA,
      'opcao_b': opcaoB,
      'opcao_c': opcaoC,
      'opcao_d': opcaoD,
      'resposta_correta': respostaCorreta,
      'eixo': eixo.valor,
      'dificuldade': dificuldade.valor,
      'categoria': categoria,
      'professor_id': professorId,
      'criado_em': criadoEm.toUtc().toIso8601String(),
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

  static Questao deLinha(Map<String, Object?> linha) {
    return Questao(
      id: linha['id'] as int?,
      enunciado: linha['enunciado'] as String,
      opcaoA: linha['opcao_a'] as String,
      opcaoB: linha['opcao_b'] as String,
      opcaoC: linha['opcao_c'] as String,
      opcaoD: linha['opcao_d'] as String,
      respostaCorreta: linha['resposta_correta'] as String,
      eixo: EixoBNCC.dePersistencia(linha['eixo'] as String),
      dificuldade: Dificuldade.dePersistencia(linha['dificuldade'] as String),
      categoria: linha['categoria'] as String? ?? 'Geral',
      professorId: linha['professor_id'] as int,
      criadoEm: DateTime.parse(linha['criado_em'] as String),
      atualizadoEm: DateTime.parse(linha['atualizado_em'] as String),
    );
  }

  Questao copiarCom({
    String? enunciado,
    String? opcaoA,
    String? opcaoB,
    String? opcaoC,
    String? opcaoD,
    String? respostaCorreta,
    EixoBNCC? eixo,
    Dificuldade? dificuldade,
    String? categoria,
    DateTime? atualizadoEm,
  }) {
    return Questao(
      id: id,
      enunciado: enunciado ?? this.enunciado,
      opcaoA: opcaoA ?? this.opcaoA,
      opcaoB: opcaoB ?? this.opcaoB,
      opcaoC: opcaoC ?? this.opcaoC,
      opcaoD: opcaoD ?? this.opcaoD,
      respostaCorreta: respostaCorreta ?? this.respostaCorreta,
      eixo: eixo ?? this.eixo,
      dificuldade: dificuldade ?? this.dificuldade,
      categoria: categoria ?? this.categoria,
      professorId: professorId,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// Retorna a opcao correta como texto completo.
  String get opcaoCorreta {
    switch (respostaCorreta) {
      case 'A':
        return opcaoA;
      case 'B':
        return opcaoB;
      case 'C':
        return opcaoC;
      case 'D':
        return opcaoD;
      default:
        throw StateError('Resposta inválida: $respostaCorreta');
    }
  }
}
