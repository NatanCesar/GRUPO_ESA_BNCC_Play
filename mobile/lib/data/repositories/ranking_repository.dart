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
    required int xpAdicional,
    required int acertos,
    required int total,
  }) async {
    final linhas = await _banco.db.query(
      'ranking',
      where: 'aluno_id = ?',
      whereArgs: [alunoId],
      limit: 1,
    );

    final agora = DateTime.now().toUtc();

    if (linhas.isEmpty) {
      // Primeira partida: cria entrada.
      final taxa = total > 0 ? (acertos / total) : 0.0;
      await _banco.db.insert('ranking', {
        'aluno_id': alunoId,
        'apelido': apelido,
        'pontuacao_total': xpAdicional,
        'total_jogos': 1,
        'taxa_acerto': taxa,
        'atualizado_em': agora.toIso8601String(),
      });
    } else {
      // Atualiza stats acumulados.
      final existente = RankingEntry.deLinha(linhas.single);
      final novoTotal = existente.totalJogos + 1;
      final novoXp = existente.pontuacaoTotal + xpAdicional;
      // Media ponderada da taxa de acerto: peso por partida.
      final novaTaxa =
          ((existente.taxaAcerto * existente.totalJogos) + acertos) / novoTotal;

      await _banco.db.update(
        'ranking',
        {
          'apelido': apelido,
          'pontuacao_total': novoXp,
          'total_jogos': novoTotal,
          'taxa_acerto': novaTaxa,
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

    final acima = await _banco.db.rawQuery('''
      SELECT COUNT(*) as total FROM ranking
      WHERE pontuacao_total > ?
    ''', [entrada.pontuacaoTotal]);

    return (acima.first['total'] as int) + 1;
  }
}
