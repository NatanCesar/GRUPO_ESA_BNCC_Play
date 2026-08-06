import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';

void main() {
  group('Questao - modelo', () {
    test('deLinha constroi corretamente', () {
      final linha = {
        'id': 1,
        'enunciado': 'Qual e a capital do Brasil?',
        'opcao_a': 'Sao Paulo',
        'opcao_b': 'Rio de Janeiro',
        'opcao_c': 'Brasilia',
        'opcao_d': 'Salvador',
        'resposta_correta': 'C',
        'eixo': 'tecnologia',
        'dificuldade': 'medio',
        'professor_id': 5,
        'criado_em': '2026-08-06T10:00:00.000Z',
        'atualizado_em': '2026-08-06T10:00:00.000Z',
      };

      final questao = Questao.deLinha(linha);

      expect(questao.id, 1);
      expect(questao.enunciado, 'Qual e a capital do Brasil?');
      expect(questao.opcaoA, 'Sao Paulo');
      expect(questao.opcaoB, 'Rio de Janeiro');
      expect(questao.opcaoC, 'Brasilia');
      expect(questao.opcaoD, 'Salvador');
      expect(questao.respostaCorreta, 'C');
      expect(questao.eixo, EixoBNCC.tecnologia);
      expect(questao.dificuldade, Dificuldade.medio);
      expect(questao.professorId, 5);
    });

    test('paraLinha gera mapa correto', () {
      final agora = DateTime.parse('2026-08-06T10:00:00.000Z');
      final questao = Questao(
        id: 1,
        enunciado: 'Teste?',
        opcaoA: 'A',
        opcaoB: 'B',
        opcaoC: 'C',
        opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.impacto,
        dificuldade: Dificuldade.dificil,
        professorId: 2,
        criadoEm: agora,
        atualizadoEm: agora,
      );

      final linha = questao.paraLinha();

      expect(linha['enunciado'], 'Teste?');
      expect(linha['resposta_correta'], 'A');
      expect(linha['eixo'], 'impacto');
      expect(linha['dificuldade'], 'dificil');
      expect(linha['professor_id'], 2);
      expect(linha.containsKey('id'), isFalse); // id nao vai para o banco
    });

    test('copiarCom atualiza campos', () {
      final agora = DateTime.parse('2026-08-06T10:00:00.000Z');
      final original = Questao(
        id: 1,
        enunciado: 'Original',
        opcaoA: 'A',
        opcaoB: 'B',
        opcaoC: 'C',
        opcaoD: 'D',
        respostaCorreta: 'A',
        eixo: EixoBNCC.tecnologia,
        dificuldade: Dificuldade.facil,
        professorId: 1,
        criadoEm: agora,
        atualizadoEm: agora,
      );

      final copia = original.copiarCom(
        enunciado: 'Modificado',
        dificuldade: Dificuldade.dificil,
      );

      expect(copia.enunciado, 'Modificado');
      expect(copia.dificuldade, Dificuldade.dificil);
      expect(copia.eixo, EixoBNCC.tecnologia); // inalterado
      expect(copia.id, 1); // inalterado
    });

    test('opcaoCorreta retorna texto correto', () {
      final agora = DateTime.parse('2026-08-06T10:00:00.000Z');

      for (final letra in ['A', 'B', 'C', 'D']) {
        final questao = Questao(
          enunciado: 'Teste',
          opcaoA: 'Alpha',
          opcaoB: 'Beta',
          opcaoC: 'Charlie',
          opcaoD: 'Delta',
          respostaCorreta: letra,
          eixo: EixoBNCC.tecnologia,
          dificuldade: Dificuldade.facil,
          professorId: 1,
          criadoEm: agora,
          atualizadoEm: agora,
        );

        switch (letra) {
          case 'A':
            expect(questao.opcaoCorreta, 'Alpha');
          case 'B':
            expect(questao.opcaoCorreta, 'Beta');
          case 'C':
            expect(questao.opcaoCorreta, 'Charlie');
          case 'D':
            expect(questao.opcaoCorreta, 'Delta');
        }
      }
    });
  });

  group('EixoBNCC - enum', () {
    test('valores esperados', () {
      expect(EixoBNCC.values.length, 3);
      expect(EixoBNCC.tecnologia.valor, 'tecnologia');
      expect(EixoBNCC.culturaDigital.valor, 'cultura');
      expect(EixoBNCC.impacto.valor, 'impacto');
    });

    test('dePersistencia funciona', () {
      expect(EixoBNCC.dePersistencia('tecnologia'), EixoBNCC.tecnologia);
      expect(EixoBNCC.dePersistencia('cultura'), EixoBNCC.culturaDigital);
      expect(EixoBNCC.dePersistencia('impacto'), EixoBNCC.impacto);
    });

    test('rotulos legiveis', () {
      expect(EixoBNCC.tecnologia.rotulo, isNotEmpty);
      expect(EixoBNCC.culturaDigital.rotulo, isNotEmpty);
      expect(EixoBNCC.impacto.rotulo, isNotEmpty);
    });
  });

  group('Dificuldade - enum', () {
    test('valores esperados', () {
      expect(Dificuldade.values.length, 3);
      expect(Dificuldade.facil.valor, 'facil');
      expect(Dificuldade.medio.valor, 'medio');
      expect(Dificuldade.dificil.valor, 'dificil');
    });

    test('dePersistencia funciona', () {
      expect(Dificuldade.dePersistencia('facil'), Dificuldade.facil);
      expect(Dificuldade.dePersistencia('medio'), Dificuldade.medio);
      expect(Dificuldade.dePersistencia('dificil'), Dificuldade.dificil);
    });
  });
}
