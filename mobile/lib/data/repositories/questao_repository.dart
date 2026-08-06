import 'package:bncc_play_mobile/core/validation/sanitizer.dart';
import 'package:bncc_play_mobile/core/validation/validators.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/errors.dart';

/// Acesso a dados de questoes no banco local.
class QuestaoRepository {
  const QuestaoRepository({required AppDatabase banco}) : _banco = banco;

  final AppDatabase _banco;

  /// Cadastra uma nova questao.
  ///
  /// Lanca [QuestaoInvalidaException] se a validacao falhar.
  Future<Questao> cadastrar({
    required String enunciado,
    required String opcaoA,
    required String opcaoB,
    required String opcaoC,
    required String opcaoD,
    required String respostaCorreta,
    required EixoBNCC eixo,
    required Dificuldade dificuldade,
    required int professorId,
  }) async {
    final erros = _validarCampos(enunciado, opcaoA, opcaoB, opcaoC, opcaoD, respostaCorreta);
    if (erros.isNotEmpty) {
      throw QuestaoInvalidaException(erros.join('; '));
    }

    final agora = DateTime.now().toUtc();

    final questao = Questao(
      enunciado: Sanitizer.limpar(enunciado),
      opcaoA: Sanitizer.limpar(opcaoA),
      opcaoB: Sanitizer.limpar(opcaoB),
      opcaoC: Sanitizer.limpar(opcaoC),
      opcaoD: Sanitizer.limpar(opcaoD),
      respostaCorreta: respostaCorreta,
      eixo: eixo,
      dificuldade: dificuldade,
      professorId: professorId,
      criadoEm: agora,
      atualizadoEm: agora,
    );

    final id = await _banco.db.insert('questoes', questao.paraLinha());
    return (await porId(id))!;
  }

  /// Devolve a questao de id [id], ou null se nao existir.
  Future<Questao?> porId(int id) async {
    final linhas = await _banco.db.query(
      'questoes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Questao.deLinha(linhas.single);
  }

  /// Lista todas as questoes de um professor.
  Future<List<Questao>> listarPorProfessor(int professorId) async {
    final linhas = await _banco.db.query(
      'questoes',
      where: 'professor_id = ?',
      whereArgs: [professorId],
      orderBy: 'criado_em DESC',
    );
    return linhas.map(Questao.deLinha).toList();
  }

  /// Lista questoes filtradas por eixo e/ou dificuldade.
  ///
  /// Se [professorId] for null, lista todas as questoes (ignora professor).
  /// Se [eixo] for null, nao filtra por eixo.
  /// Se [dificuldade] for null, nao filtra por dificuldade.
  Future<List<Questao>> filtrar({
    int? professorId,
    EixoBNCC? eixo,
    Dificuldade? dificuldade,
  }) async {
    final condicoes = <String>[];
    final args = <Object?>[];

    if (professorId != null) {
      condicoes.add('professor_id = ?');
      args.add(professorId);
    }
    if (eixo != null) {
      condicoes.add('eixo = ?');
      args.add(eixo.valor);
    }
    if (dificuldade != null) {
      condicoes.add('dificuldade = ?');
      args.add(dificuldade.valor);
    }

    final linhas = await _banco.db.query(
      'questoes',
      where: condicoes.isEmpty ? null : condicoes.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'criado_em DESC',
    );
    return linhas.map(Questao.deLinha).toList();
  }

  /// Atualiza uma questao existente.
  ///
  /// Lanca [QuestaoNaoEncontradaException] se a questao nao existir.
  /// Lanca [QuestaoInvalidaException] se a validacao falhar.
  Future<Questao> atualizar(Questao questao) async {
    final id = questao.id;
    if (id == null) throw ArgumentError('Atualizar exige id preenchido');

    final erros = _validarCampos(
      questao.enunciado,
      questao.opcaoA,
      questao.opcaoB,
      questao.opcaoC,
      questao.opcaoD,
      questao.respostaCorreta,
    );
    if (erros.isNotEmpty) {
      throw QuestaoInvalidaException(erros.join('; '));
    }

    final atualizado = questao.copiarCom(atualizadoEm: DateTime.now().toUtc());

    final linhas = await _banco.db.query(
      'questoes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) {
      throw const QuestaoNaoEncontradaException();
    }

    await _banco.db.update(
      'questoes',
      atualizado.paraLinha(),
      where: 'id = ?',
      whereArgs: [id],
    );

    return (await porId(id))!;
  }

  /// Remove uma questao.
  ///
  /// Lanca [QuestaoNaoEncontradaException] se a questao nao existir.
  Future<void> remover(int id) async {
    final linhas = await _banco.db.query(
      'questoes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) {
      throw const QuestaoNaoEncontradaException();
    }

    await _banco.db.delete(
      'questoes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Conta questoes por eixo para um professor.
  Future<Map<EixoBNCC, int>> contarPorEixo(int professorId) async {
    final linhas = await _banco.db.rawQuery('''
      SELECT eixo, COUNT(*) as total
      FROM questoes
      WHERE professor_id = ?
      GROUP BY eixo
    ''', [professorId]);

    final resultado = <EixoBNCC, int>{};
    for (final eixo in EixoBNCC.values) {
      resultado[eixo] = 0;
    }
    for (final linha in linhas) {
      final eixo = EixoBNCC.dePersistencia(linha['eixo'] as String);
      resultado[eixo] = linha['total'] as int;
    }
    return resultado;
  }

  List<String> _validarCampos(
    String enunciado,
    String opcaoA,
    String opcaoB,
    String opcaoC,
    String opcaoD,
    String respostaCorreta,
  ) {
    final erros = <String>[];

    if (Validators.enunciado(enunciado) != null) {
      erros.add(Validators.enunciado(enunciado)!);
    }
    if (Validators.opcaoQuestao(opcaoA) != null) {
      erros.add('Opcao A: ${Validators.opcaoQuestao(opcaoA)}');
    }
    if (Validators.opcaoQuestao(opcaoB) != null) {
      erros.add('Opcao B: ${Validators.opcaoQuestao(opcaoB)}');
    }
    if (Validators.opcaoQuestao(opcaoC) != null) {
      erros.add('Opcao C: ${Validators.opcaoQuestao(opcaoC)}');
    }
    if (Validators.opcaoQuestao(opcaoD) != null) {
      erros.add('Opcao D: ${Validators.opcaoQuestao(opcaoD)}');
    }
    if (!['A', 'B', 'C', 'D'].contains(respostaCorreta)) {
      erros.add('Selecione a resposta correta (A, B, C ou D)');
    }

    return erros;
  }
}
