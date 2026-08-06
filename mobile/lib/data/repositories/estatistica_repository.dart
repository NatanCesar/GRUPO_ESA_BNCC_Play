import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/estatistica.dart';

/// Acesso a dados de estatisticas agregadas para o dashboard.
class EstatisticaRepository {
  EstatisticaRepository({required AppDatabase banco}) : _banco = banco;

  final AppDatabase _banco;

  /// Gera estatisticas gerais de todos os alunos do professor.
  ///
  /// Agrega dados de partidas, respostas e pontuacoes.
  Future<EstatisticaGeral> gerarEstatisticasGerais(int professorId) async {
    // Busca alunos do professor.
    final alunos = await _banco.db.rawQuery(
      '''
      SELECT id FROM users
      WHERE papel = 'aluno' AND professor_id = ?
    ''',
      [professorId],
    );

    if (alunos.isEmpty) {
      return EstatisticaGeral();
    }

    final ids = alunos.map((a) => a['id'] as int).toList();
    final placeholders = List.filled(ids.length, '?').join(',');

    // Estatisticas de partidas.
    final partidasStats = await _banco.db.rawQuery('''
      SELECT
        COUNT(*) as total_partidas,
        COALESCE(SUM(pontuacao), 0) as soma_pontuacao,
        COALESCE(SUM(respondidas), 0) as total_respostas,
        COALESCE(SUM(acertos), 0) as total_acertos
      FROM partidas
      WHERE aluno_id IN ($placeholders)
        AND terminada_em IS NOT NULL
    ''', ids);

    if (partidasStats.isEmpty) {
      return EstatisticaGeral(
        totalAlunos: ids.length,
        totalPartidas: 0,
        totalRespostas: 0,
        totalAcertos: 0,
        somaPontuacao: 0,
      );
    }

    final stats = partidasStats.single;

    return EstatisticaGeral(
      totalAlunos: ids.length,
      totalPartidas: stats['total_partidas'] as int? ?? 0,
      totalRespostas: stats['total_respostas'] as int? ?? 0,
      totalAcertos: stats['total_acertos'] as int? ?? 0,
      somaPontuacao: stats['soma_pontuacao'] as int? ?? 0,
    );
  }

  /// Lista os alunos com melhor desempenho.
  Future<List<({int alunoId, String nome, int pontuacao, double taxa})>>
  alunosComMelhorDesempenho(int professorId, {int limite = 10}) async {
    final alunos = await _banco.db.rawQuery(
      '''
      SELECT
        r.aluno_id,
        u.nome,
        r.pontuacao_total,
        r.taxa_acerto
      FROM ranking r
      JOIN users u ON u.id = r.aluno_id
      WHERE u.papel = 'aluno' AND u.professor_id = ?
      ORDER BY r.pontuacao_total DESC
      LIMIT ?
    ''',
      [professorId, limite],
    );

    return alunos.map((linha) {
      return (
        alunoId: linha['aluno_id'] as int,
        nome: linha['nome'] as String,
        pontuacao: linha['pontuacao_total'] as int,
        taxa: (linha['taxa_acerto'] as num).toDouble(),
      );
    }).toList();
  }

  /// Contagem de alunos por eixo baseado nas partidas.
  Future<Map<String, int>> contarAlunosPorEixo(int professorId) async {
    final resultado = await _banco.db.rawQuery(
      '''
      SELECT eixo, COUNT(DISTINCT aluno_id) as total
      FROM partidas p
      JOIN users u ON u.id = p.aluno_id
      WHERE p.eixo IS NOT NULL AND u.professor_id = ?
      GROUP BY eixo
    ''',
      [professorId],
    );

    final mapa = <String, int>{'tecnologia': 0, 'cultura': 0, 'impacto': 0};

    for (final linha in resultado) {
      final eixo = linha['eixo'] as String?;
      if (eixo != null && mapa.containsKey(eixo)) {
        mapa[eixo] = linha['total'] as int;
      }
    }

    return mapa;
  }

  /// Questoes mais faceis (alta taxa de acerto).
  Future<List<EstatisticaQuestao>> questoesMaisFaceis({
    required int professorId,
    int limite = 5,
    double minTaxa = 70,
  }) async {
    return _questoesPorTaxa(
      professorId: professorId,
      limite: limite,
      crescente: false,
      corte: minTaxa,
    );
  }

  /// Questoes mais dificeis (baixa taxa de acerto).
  Future<List<EstatisticaQuestao>> questoesMaisDificeis({
    required int professorId,
    int limite = 5,
    double maxTaxa = 40,
  }) async {
    return _questoesPorTaxa(
      professorId: professorId,
      limite: limite,
      crescente: true,
      corte: maxTaxa,
    );
  }

  Future<List<EstatisticaQuestao>> _questoesPorTaxa({
    required int professorId,
    required int limite,
    required bool crescente,
    required double corte,
  }) async {
    final operador = crescente ? '<=' : '>=';
    final ordem = crescente ? 'ASC' : 'DESC';
    final linhas = await _banco.db.rawQuery(
      '''
      SELECT q.id AS questao_id, q.enunciado,
             COUNT(r.id) AS total_respostas,
             COALESCE(SUM(r.correta), 0) AS total_acertos
      FROM questoes q
      JOIN respostas r ON r.questao_id = q.id
      WHERE q.professor_id = ?
      GROUP BY q.id, q.enunciado
      HAVING (SUM(r.correta) * 100.0 / COUNT(r.id)) $operador ?
      ORDER BY (SUM(r.correta) * 1.0 / COUNT(r.id)) $ordem
      LIMIT ?
      ''',
      [professorId, corte, limite],
    );
    return linhas
        .map(
          (linha) => EstatisticaQuestao(
            questaoId: linha['questao_id'] as int,
            enunciado: linha['enunciado'] as String,
            totalRespostas: linha['total_respostas'] as int,
            totalAcertos: linha['total_acertos'] as int,
          ),
        )
        .toList();
  }
}
