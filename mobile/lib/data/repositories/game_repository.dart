import 'dart:math';

import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/partida.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/repositories/ranking_repository.dart';

/// Acesso a dados de partidas de jogo.
///
/// Cuida do loop de jogo: iniciar partida, registrar resposta e encerrar.
class GameRepository {
  GameRepository({
    required AppDatabase banco,
    RankingRepository? ranking,
    Random? random,
  })  : _banco = banco,
        _ranking = ranking ?? RankingRepository(banco: banco),
        _random = random ?? Random();

  final AppDatabase _banco;
  final RankingRepository _ranking;
  final Random _random;

  static const int questoesPorPartida = 5;
  static const int xpPorAcerto = 100;
  static const int bonusPorStreak = 10;

  /// Inicia uma nova partida para o aluno.
  ///
  /// Seleciona [questoesPorPartida] questoes aleatorias do eixo
  /// (ou de qualquer eixo se eixo for null).
  Future<Partida> iniciarPartida(int alunoId, {String? eixo}) async {
    String sql = '''
      SELECT id, enunciado, opcao_a, opcao_b, opcao_c, opcao_d,
             resposta_correta, eixo, dificuldade, professor_id,
             criado_em, atualizado_em
      FROM questoes
    ''';
    List<Object?> args = [];

    if (eixo != null) {
      sql += ' WHERE eixo = ?';
      args = [eixo];
    }

    final linhas = await _banco.db.rawQuery(sql, args);

    if (linhas.isEmpty) {
      throw const PartidaSemQuestoesException();
    }

    final todas = linhas.map(Questao.deLinha).toList();
    final shuffled = List<Questao>.from(todas)..shuffle(_random);
    final escolhidas = shuffled.take(questoesPorPartida).toList();

    final agora = DateTime.now().toUtc();

    final partida = Partida(
      alunoId: alunoId,
      eixo: eixo,
      pontuacao: 0,
      streak: 0,
      respondidas: 0,
      acertos: 0,
      iniciadaEm: agora,
    );

    final id = await _banco.db.insert('partidas', {
      ...partida.paraLinha(),
      'eixo': eixo,
      // Armazena IDs das questoes como texto separado por virgula
      'questao_ids': escolhidas.map((q) => q.id).join(','),
    });

    return (await porId(id))!;
  }

  /// Registra a resposta de uma questao e atualiza pontuacao/streak.
  Future<Partida> registrarResposta({
    required int partidaId,
    required String respostaAluno,
    required bool acertou,
  }) async {
    final linhas = await _banco.db.query(
      'partidas',
      where: 'id = ?',
      whereArgs: [partidaId],
      limit: 1,
    );
    if (linhas.isEmpty) throw const PartidaNaoEncontradaException();

    final partida = Partida.deLinha(linhas.single);
    if (!partida.emAndamento) {
      throw const PartidaJaEncerradaException();
    }

    int novoStreak = acertou ? partida.streak + 1 : 0;
    int xpGanho = 0;

    if (acertou) {
      xpGanho = xpPorAcerto;
      if (novoStreak >= 3) {
        xpGanho += novoStreak * bonusPorStreak;
      }
    }

    final atualizada = partida.copiarCom(
      pontuacao: partida.pontuacao + xpGanho,
      streak: novoStreak,
      respondidas: partida.respondidas + 1,
      acertos: partida.acertos + (acertou ? 1 : 0),
    );

    await _banco.db.update(
      'partidas',
      atualizada.paraLinha(),
      where: 'id = ?',
      whereArgs: [partidaId],
    );

    return atualizada;
  }

  /// Encerra a partida e atualiza o ranking.
  Future<Partida> encerrarPartida(int partidaId, String apelido) async {
    final linhas = await _banco.db.query(
      'partidas',
      where: 'id = ?',
      whereArgs: [partidaId],
      limit: 1,
    );
    if (linhas.isEmpty) throw const PartidaNaoEncontradaException();

    final partida = Partida.deLinha(linhas.single);
    if (!partida.emAndamento) {
      throw const PartidaJaEncerradaException();
    }

    final agora = DateTime.now().toUtc();

    final encerrada = partida.copiarCom(terminadaEm: agora);

    await _banco.db.update(
      'partidas',
      encerrada.paraLinha(),
      where: 'id = ?',
      whereArgs: [partidaId],
    );

    // Atualiza o ranking com os stats da partida.
    await _ranking.atualizarRanking(
      alunoId: partida.alunoId,
      apelido: apelido,
      xpAdicional: partida.pontuacao,
      acertos: partida.acertos,
      total: partida.respondidas,
    );

    return encerrada;
  }

  /// Devolve a partida em andamento do aluno, ou null.
  Future<Partida?> partidaEmAndamento(int alunoId) async {
    final linhas = await _banco.db.query(
      'partidas',
      where: 'aluno_id = ? AND terminada_em IS NULL',
      whereArgs: [alunoId],
      orderBy: 'iniciada_em DESC',
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Partida.deLinha(linhas.single);
  }

  /// Devolve a partida de id [id], ou null.
  Future<Partida?> porId(int id) async {
    final linhas = await _banco.db.query(
      'partidas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Partida.deLinha(linhas.single);
  }

  /// Devolve o historico de partidas do aluno.
  Future<List<Partida>> historico(int alunoId, {int limite = 20}) async {
    final linhas = await _banco.db.query(
      'partidas',
      where: 'aluno_id = ? AND terminada_em IS NOT NULL',
      whereArgs: [alunoId],
      orderBy: 'terminada_em DESC',
      limit: limite,
    );
    return linhas.map(Partida.deLinha).toList();
  }
}

/// excecao lancada quando nao ha questoes para iniciar uma partida.
class PartidaSemQuestoesException implements Exception {
  const PartidaSemQuestoesException();

  @override
  String toString() => 'Nenhuma questao disponivel para jogar';
}

/// excecao lancada quando a partida nao e encontrada.
class PartidaNaoEncontradaException implements Exception {
  const PartidaNaoEncontradaException();

  @override
  String toString() => 'Partida nao encontrada';
}

/// excecao lancada quando tenta registrar resposta em partida ja encerrada.
class PartidaJaEncerradaException implements Exception {
  const PartidaJaEncerradaException();

  @override
  String toString() => 'Partida ja encerrada';
}
