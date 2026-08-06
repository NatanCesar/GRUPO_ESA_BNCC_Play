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
    final alunos = await _banco.db.rawQuery('''
      SELECT id FROM users
      WHERE papel = 'aluno'
    ''');

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
      alunosComMelhorDesempenho({int limite = 10}) async {
    final alunos = await _banco.db.rawQuery('''
      SELECT
        r.aluno_id,
        u.nome,
        r.pontuacao_total,
        r.taxa_acerto
      FROM ranking r
      JOIN users u ON u.id = r.aluno_id
      WHERE u.papel = 'aluno'
      ORDER BY r.pontuacao_total DESC
      LIMIT ?
    ''', [limite]);

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
  Future<Map<String, int>> contarAlunosPorEixo() async {
    final resultado = await _banco.db.rawQuery('''
      SELECT eixo, COUNT(DISTINCT aluno_id) as total
      FROM partidas
      WHERE eixo IS NOT NULL
      GROUP BY eixo
    ''');

    final mapa = <String, int>{
      'tecnologia': 0,
      'cultura': 0,
      'impacto': 0,
    };

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
    int limite = 5,
    double minTaxa = 70,
  }) async {
    // Por enquanto retorna lista vazia - depende de tracking
    // de respostas individuais por questao.
    // Em uma versao completa, teriamos uma tabela de respostas.
    return [];
  }

  /// Questoes mais dificeis (baixa taxa de acerto).
  Future<List<EstatisticaQuestao>> questoesMaisDificeis({
    int limite = 5,
    double maxTaxa = 40,
  }) async {
    // Por enquanto retorna lista vazia - depende de tracking.
    return [];
  }
}
