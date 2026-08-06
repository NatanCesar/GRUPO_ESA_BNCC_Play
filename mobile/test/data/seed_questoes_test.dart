import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/db/seed_questoes.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed mantém acentuação em enunciados e alternativas', () {
    final textos = questoesSeed.expand(
      (questao) => [
        questao.enunciado,
        questao.opcaoA,
        questao.opcaoB,
        questao.opcaoC,
        questao.opcaoD,
      ],
    );

    const grafiasIncorretas = <String>[
      ' programacao',
      ' sequencia',
      ' logica',
      ' eletronico',
      ' memoria',
      ' codigo',
      ' arvore',
      ' binaria',
      ' quadratico',
      ' basica',
      ' funcao',
      ' informacao',
      ' computacao',
      ' edicao',
      ' relacoes',
      ' pagina',
      ' variaveis',
      ' plagio',
      ' conteudo',
      ' credito',
      ' licenca',
      ' virus',
      'antivrus',
      ' seguranca',
      ' importancia',
      ' nao',
      ' sao',
      ' so ',
      ' noticias',
      ' impressao',
      ' carbonica',
      ' diferenca',
      ' circunstancias',
      'circunstacias',
      ' cidadao',
      ' responsavel',
      ' etica',
      ' inclusao',
      ' dependencia',
      ' reducao',
      ' sustentavel',
      ' ate ',
      ' usuarios',
      ' discriminacao',
      ' inteligencia',
      ' rapida',
      ' democratizacao',
      ' acessivel',
      ' saude',
      ' criancas',
      'o que e ',
      'qual e ',
      ' acesso igual a tecnologia',
      ' acesso a informacao',
      'через',
      'belajar',
      'huella',
      'vida privacao algoritmica',
    ];

    for (final texto in textos) {
      final normalizado = ' ${texto.toLowerCase()} ';
      for (final grafia in grafiasIncorretas) {
        expect(
          normalizado,
          isNot(contains(grafia)),
          reason: 'Grafia sem acento em: "$texto"',
        );
      }
    }
  });

  test('corrige o seed já persistido por uma versão antiga', () async {
    final banco = await abrirBancoDeTeste();
    addTearDown(banco.fechar);

    final usuarios = UserRepository(
      banco: banco,
      hasher: const PasswordHasher(iteracoes: 1000),
    );
    await usuarios.cadastrar(
      nome: 'Professor Seed',
      email: 'seed@escola.edu.br',
      usuario: 'professor.seed',
      senha: 'Senha123',
      papel: Papel.professor,
      escola: 'Escola Seed',
    );
    await popularBancoSeed(banco);

    final categorias = await banco.db.rawQuery(
      'SELECT DISTINCT categoria FROM questoes ORDER BY categoria',
    );
    expect(categorias.length, greaterThanOrEqualTo(8));
    expect(
      categorias.map((linha) => linha['categoria']),
      containsAll(['Ética e autoria', 'Inteligência artificial']),
    );

    await banco.db.update(
      'questoes',
      {
        'enunciado': 'O que e um algoritmo?',
        'opcao_b': 'Uma sequencia logica de passos para resolver um problema',
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    await corrigirAcentuacaoSeed(banco);

    final primeira = (await banco.db.query(
      'questoes',
      where: 'id = ?',
      whereArgs: [1],
    )).single;
    expect(primeira['enunciado'], 'O que é um algoritmo?');
    expect(
      primeira['opcao_b'],
      'Uma sequência lógica de passos para resolver um problema',
    );
  });

  test('popula banco vazio e não duplica as questões', () async {
    final banco = await abrirBancoDeTeste();
    addTearDown(banco.fechar);

    await popularBancoSeed(banco);
    await popularBancoSeed(banco);

    final totalQuestoes = (await banco.db.rawQuery(
      'SELECT COUNT(*) AS total FROM questoes',
    )).single['total'];
    final professorInterno = await banco.db.query(
      'users',
      where: 'usuario = ?',
      whereArgs: ['conteudo_bncc'],
    );
    expect(totalQuestoes, questoesSeed.length);
    expect(professorInterno, hasLength(1));
  });

  test(
    'conta interna do seed não recebe alunos de professores reais',
    () async {
      final banco = await abrirBancoDeTeste();
      addTearDown(banco.fechar);
      await popularBancoSeed(banco);
      final usuarios = UserRepository(
        banco: banco,
        hasher: const PasswordHasher(iteracoes: 1000),
      );
      final professor = await usuarios.cadastrar(
        nome: 'Professor Real',
        email: 'real@escola.edu.br',
        usuario: 'professor.real',
        senha: 'Senha123',
        papel: Papel.professor,
        escola: 'Escola Real',
      );
      final aluno = await usuarios.cadastrar(
        nome: 'Aluno Real',
        email: 'aluno@escola.edu.br',
        usuario: 'aluno.real',
        senha: 'Senha123',
        papel: Papel.aluno,
        turma: '7A',
      );

      expect(aluno.professorId, professor.id);
    },
  );
}
