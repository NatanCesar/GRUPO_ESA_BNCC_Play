import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/errors.dart';

import '../support/db_de_teste.dart';

void main() {
  group('QuestaoRepository.cadastrar', () {
    late QuestaoRepository repository;
    late int professorId;

    setUpAll(() async {
      final banco = await _criarBancoComProfessor();
      repository = banco.$1;
      professorId = banco.$2;
    });

    test('CT06 funcional: salva questao com todos os campos', () async {
      final questao = await repository.cadastrar(
        enunciado: 'Qual a capital do Brasil?',
        opcaoA: 'Sao Paulo',
        opcaoB: 'Rio de Janeiro',
        opcaoC: 'Brasilia',
        opcaoD: 'Salvador',
        respostaCorreta: 'C',
        eixo: EixoBNCC.culturaDigital,
        dificuldade: Dificuldade.facil,
        professorId: professorId,
      );

      expect(questao.id, isNotNull);
      expect(questao.enunciado, 'Qual a capital do Brasil?');
      expect(questao.respostaCorreta, 'C');
      expect(questao.eixo, EixoBNCC.culturaDigital);
      expect(questao.dificuldade, Dificuldade.facil);
      expect(questao.professorId, professorId);
    });

    test('CT06 nao funcional: sanitiza XSS no enunciado', () async {
      final questao = await repository.cadastrar(
        enunciado: '<script>alert("xss")</script>Qual a capital?',
        opcaoA: 'Sao Paulo',
        opcaoB: 'Rio de Janeiro',
        opcaoC: 'Brasilia',
        opcaoD: 'Salvador',
        respostaCorreta: 'C',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.medio,
        professorId: professorId,
      );

      expect(questao.enunciado.contains('<script>'), isFalse);
    });

    test('rejeita enunciado vazio', () async {
      expect(
        () => repository.cadastrar(
          enunciado: '',
          opcaoA: 'A',
          opcaoB: 'B',
          opcaoC: 'C',
          opcaoD: 'D',
          respostaCorreta: 'A',
          eixo: EixoBNCC.tecnologia,
          dificuldade: Dificuldade.facil,
          professorId: professorId,
        ),
        throwsA(isA<QuestaoInvalidaException>()),
      );
    });

    test('rejeita resposta invalida', () async {
      expect(
        () => repository.cadastrar(
          enunciado: 'Qual a capital?',
          opcaoA: 'A',
          opcaoB: 'B',
          opcaoC: 'C',
          opcaoD: 'D',
          respostaCorreta: 'X',
          eixo: EixoBNCC.tecnologia,
          dificuldade: Dificuldade.facil,
          professorId: professorId,
        ),
        throwsA(isA<QuestaoInvalidaException>()),
      );
    });
  });

  group('QuestaoRepository.listarPorProfessor', () {
    late QuestaoRepository repository;
    late int professorId;

    setUpAll(() async {
      final banco = await _criarBancoComProfessor();
      repository = banco.$1;
      professorId = banco.$2;
    });

    test('CT08 funcional: lista questoes de um professor', () async {
      await repository.cadastrar(
        enunciado: 'Questao Um para listar',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.facil,
        professorId: professorId,
      );
      await repository.cadastrar(
        enunciado: 'Questao Dois para listar',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'B',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.medio,
        professorId: professorId,
      );

      final questoes = await repository.listarPorProfessor(professorId);

      expect(questoes.length, 2);
    });
  });

  group('QuestaoRepository.filtrar', () {
    late QuestaoRepository repository;
    late int professorId;

    setUpAll(() async {
      final banco = await _criarBancoComProfessor();
      repository = banco.$1;
      professorId = banco.$2;

      // Cria 9 questoes (3 eixos x 3 dificuldades)
      for (final eixo in EixoBNCC.values) {
        for (final dif in Dificuldade.values) {
          await repository.cadastrar(
            enunciado: 'Questao ${eixo.valor} ${dif.valor}',
            opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
            respostaCorreta: 'A',
            eixo: eixo,
            dificuldade: dif,
            professorId: professorId,
          );
        }
      }
    });

    test('CT08 funcional: filtra por eixo', () async {
      final questoes = await repository.filtrar(
        professorId: professorId,
        eixo: EixoBNCC.tecnologia,
      );

      expect(questoes.every((q) => q.eixo == EixoBNCC.tecnologia), isTrue);
      expect(questoes.length, 3);
    });

    test('CT12 funcional: filtra por dificuldade', () async {
      final questoes = await repository.filtrar(
        professorId: professorId,
        dificuldade: Dificuldade.facil,
      );

      expect(questoes.every((q) => q.dificuldade == Dificuldade.facil), isTrue);
      expect(questoes.length, 3);
    });

    test('filtra por eixo e dificuldade combinados', () async {
      final questoes = await repository.filtrar(
        professorId: professorId,
        eixo: EixoBNCC.impacto,
        dificuldade: Dificuldade.dificil,
      );

      expect(questoes.length, 1);
      expect(questoes.single.eixo, EixoBNCC.impacto);
      expect(questoes.single.dificuldade, Dificuldade.dificil);
    });

    test('sem filtro retorna todas do professor', () async {
      final todas = await repository.filtrar(professorId: professorId);
      expect(todas.length, 9); // 3 eixos x 3 dificuldades
    });
  });

  group('QuestaoRepository.atualizar', () {
    late QuestaoRepository repository;
    late int professorId;

    setUpAll(() async {
      final banco = await _criarBancoComProfessor();
      repository = banco.$1;
      professorId = banco.$2;
    });

    test('CT09 funcional: atualiza enunciado e dificuldade', () async {
      final original = await repository.cadastrar(
        enunciado: 'Enunciado Original',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.facil,
        professorId: professorId,
      );

      final atualizada = await repository.atualizar(
        original.copiarCom(enunciado: 'Enunciado Modificado', dificuldade: Dificuldade.dificil),
      );

      expect(atualizada.enunciado, 'Enunciado Modificado');
      expect(atualizada.dificuldade, Dificuldade.dificil);
      expect(atualizada.id, original.id);
    });

    test('CT09 funcional: resposta correta pode ser alterada', () async {
      final original = await repository.cadastrar(
        enunciado: 'Qual a capital?',
        opcaoA: 'Sao Paulo',
        opcaoB: 'Rio',
        opcaoC: 'Brasilia',
        opcaoD: 'Salvador',
        respostaCorreta: 'C',
        eixo: EixoBNCC.culturaDigital,
        dificuldade: Dificuldade.medio,
        professorId: professorId,
      );

      final atualizada = await repository.atualizar(
        original.copiarCom(respostaCorreta: 'B'),
      );

      expect(atualizada.respostaCorreta, 'B');
    });
  });

  group('QuestaoRepository.remover', () {
    late QuestaoRepository repository;
    late int professorId;

    setUpAll(() async {
      final banco = await _criarBancoComProfessor();
      repository = banco.$1;
      professorId = banco.$2;
    });

    test('CT10 funcional: remove questao existente', () async {
      final questao = await repository.cadastrar(
        enunciado: 'Questao para remover',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.facil,
        professorId: professorId,
      );

      await repository.remover(questao.id!);

      final verificada = await repository.porId(questao.id!);
      expect(verificada, isNull);
    });

    test('CT10 funcional: lanca excecao para questao inexistente', () async {
      expect(
        () => repository.remover(99999),
        throwsA(isA<QuestaoNaoEncontradaException>()),
      );
    });
  });

  group('QuestaoRepository.contarPorEixo', () {
    late QuestaoRepository repository;
    late int professorId;

    setUpAll(() async {
      final banco = await _criarBancoComProfessor();
      repository = banco.$1;
      professorId = banco.$2;

      // Cria 3 questoes: 2 de tecnologia, 1 de cultura
      await repository.cadastrar(
        enunciado: 'Questao de Tecnologia Facil',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.facil,
        professorId: professorId,
      );
      await repository.cadastrar(
        enunciado: 'Questao de Tecnologia Medio',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.medio,
        professorId: professorId,
      );
      await repository.cadastrar(
        enunciado: 'Questao de Cultura Digital',
        opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.culturaDigital,
        dificuldade: Dificuldade.facil,
        professorId: professorId,
      );
    });

    test('conta questoes agrupadas por eixo', () async {
      final contagem = await repository.contarPorEixo(professorId);

      expect(contagem[EixoBNCC.tecnologia], 2);
      expect(contagem[EixoBNCC.culturaDigital], 1);
      expect(contagem[EixoBNCC.impacto], 0);
    });
  });
}

/// Cria banco fresco com professor para cada grupo de testes.
Future<(QuestaoRepository, int)> _criarBancoComProfessor() async {
  final banco = await abrirBancoDeTeste();

  final id = DateTime.now().microsecondsSinceEpoch;

  await banco.db.insert('users', {
    'nome': 'Prof. Teste',
    'email': 'prof$id@teste.com',
    'usuario': 'prof$id',
    'senha_hash': 'hash',
    'salt': 'salt',
    'papel': 'professor',
    'escola': 'Teste',
    'criado_em': DateTime.now().toUtc().toIso8601String(),
    'atualizado_em': DateTime.now().toUtc().toIso8601String(),
  });

  final linhas = await banco.db.query('users', where: 'email = ?', whereArgs: ['prof$id@teste.com']);
  final professorId = linhas.single['id'] as int;

  return (QuestaoRepository(banco: banco), professorId);
}
