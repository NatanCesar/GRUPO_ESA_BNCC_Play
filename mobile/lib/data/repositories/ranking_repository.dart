import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/ranking.dart';

/// Acesso a dados do ranking de jogadores.
class RankingRepository {
  RankingRepository({required AppDatabase banco}) : _banco = banco;

  final AppDatabase _banco;

  /// Atualiza o ranking do aluno apos uma partida.
  ///
  /// Se o aluno ainda nao tem entrada, insere. Senao, atualiza
  /// a pontuacao total, total de jogos e taxa de acerto.
  Future<void> atualizarRanking({
    required int alunoId,
    required String apelido,
  }) async {
    final linhas = await _banco.db.query(
      'ranking',
      where: 'aluno_id = ?',
      whereArgs: [alunoId],
      limit: 1,
    );

    final agora = DateTime.now().toUtc();

    final agregados = (await _banco.db.rawQuery(
      '''
      SELECT COUNT(*) AS jogos, COALESCE(SUM(pontuacao), 0) AS xp,
             COALESCE(SUM(acertos), 0) AS acertos,
             COALESCE(SUM(respondidas), 0) AS respostas
      FROM partidas
      WHERE aluno_id = ? AND terminada_em IS NOT NULL
      ''',
      [alunoId],
    )).single;
    final totalJogos = agregados['jogos'] as int;
    final xpTotal = agregados['xp'] as int;
    final totalAcertos = agregados['acertos'] as int;
    final totalRespostas = agregados['respostas'] as int;
    final taxa = totalRespostas > 0
        ? (totalAcertos / totalRespostas) * 100
        : 0.0;

    if (linhas.isEmpty) {
      await _banco.db.insert('ranking', {
        'aluno_id': alunoId,
        'apelido': apelido,
        'pontuacao_total': xpTotal,
        'total_jogos': totalJogos,
        'taxa_acerto': taxa,
        'atualizado_em': agora.toIso8601String(),
      });
    } else {
      await _banco.db.update(
        'ranking',
        {
          'apelido': apelido,
          'pontuacao_total': xpTotal,
          'total_jogos': totalJogos,
          'taxa_acerto': taxa,
          'atualizado_em': agora.toIso8601String(),
        },
        where: 'aluno_id = ?',
        whereArgs: [alunoId],
      );
    }
  }

  /// Lista o ranking geral ordenado por pontuacao.
  Future<List<RankingEntry>> listarGeral({int limite = 50}) async {
    final linhas = await _banco.db.query(
      'ranking',
      orderBy: 'pontuacao_total DESC',
      limit: limite,
    );
    return linhas.map(RankingEntry.deLinha).toList();
  }

  Future<List<RankingEntry>> listarPorEixo(
    String eixo, {
    int limite = 50,
  }) async {
    final linhas = await _banco.db.rawQuery(
      '''
      SELECT u.id AS aluno_id, u.usuario AS apelido,
             SUM(p.pontuacao) AS pontuacao_total,
             COUNT(p.id) AS total_jogos,
             CASE WHEN SUM(p.respondidas) > 0
               THEN SUM(p.acertos) * 100.0 / SUM(p.respondidas)
               ELSE 0 END AS taxa_acerto,
             MAX(p.terminada_em) AS atualizado_em
      FROM partidas p
      JOIN users u ON u.id = p.aluno_id
      WHERE p.eixo = ? AND p.terminada_em IS NOT NULL
      GROUP BY u.id, u.usuario
      ORDER BY pontuacao_total DESC
      LIMIT ?
      ''',
      [eixo, limite],
    );
    return linhas.map(RankingEntry.deLinha).toList();
  }

  /// Devolve a entrada do ranking de um aluno, ou null.
  Future<RankingEntry?> porAluno(int alunoId) async {
    final linhas = await _banco.db.query(
      'ranking',
      where: 'aluno_id = ?',
      whereArgs: [alunoId],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return RankingEntry.deLinha(linhas.single);
  }

  /// Devolve a posicao ordinal do aluno (1, 2, 3...).
  ///
  /// Retorna null se o aluno nao esta no ranking.
  Future<int?> posicaoOrdinal(int alunoId) async {
    final entrada = await porAluno(alunoId);
    if (entrada == null) return null;

    final acima = await _banco.db.rawQuery(
      '''
      SELECT COUNT(*) as total FROM ranking
      WHERE pontuacao_total > ?
    ''',
      [entrada.pontuacaoTotal],
    );

    return (acima.first['total'] as int) + 1;
  }
}
