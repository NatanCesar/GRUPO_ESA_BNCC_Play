import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/estatistica_repository.dart';
import 'package:bncc_play_mobile/data/repositories/game_repository.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/data/repositories/ranking_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('US17, US19 e US20: consolida respostas, ranking e dashboard', () async {
    final banco = await abrirBancoDeTeste();
    addTearDown(banco.fechar);
    final usuarios = UserRepository(
      banco: banco,
      hasher: const PasswordHasher(iteracoes: 1000),
    );
    final professor = await usuarios.cadastrar(
      nome: 'Professora Ana',
      email: 'ana@escola.com',
      usuario: 'professoraana',
      senha: 'Senha123',
      papel: Papel.professor,
      escola: 'Escola Central',
    );
    final outroProfessor = await usuarios.cadastrar(
      nome: 'Professor Bruno',
      email: 'bruno@escola.com',
      usuario: 'professorbruno',
      senha: 'Senha123',
      papel: Papel.professor,
      escola: 'Outra Escola',
    );
    final aluno = await usuarios.cadastrar(
      nome: 'Carlos Silva',
      email: 'carlos@escola.com',
      usuario: 'carlossilva',
      senha: 'Senha123',
      papel: Papel.aluno,
      turma: '7A',
      professorId: professor.id,
    );
    await usuarios.cadastrar(
      nome: 'Dora Souza',
      email: 'dora@escola.com',
      usuario: 'dorasouza',
      senha: 'Senha123',
      papel: Papel.aluno,
      turma: '8B',
      professorId: outroProfessor.id,
    );

    final questoes = QuestaoRepository(banco: banco);
    final facil = await questoes.cadastrar(
      enunciado: 'Questão com alto índice de acerto',
      opcaoA: 'Correta',
      opcaoB: 'Incorreta',
      opcaoC: 'Incorreta',
      opcaoD: 'Incorreta',
      respostaCorreta: 'A',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.facil,
      categoria: 'Fundamentos',
      professorId: professor.id!,
    );
    final dificil = await questoes.cadastrar(
      enunciado: 'Questão com baixo índice de acerto',
      opcaoA: 'Incorreta',
      opcaoB: 'Correta',
      opcaoC: 'Incorreta',
      opcaoD: 'Incorreta',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.dificil,
      categoria: 'Sociedade',
      professorId: professor.id!,
    );

    final jogo = GameRepository(banco: banco);
    final partidaTecnologia = await jogo.iniciarPartida(
      aluno.id!,
      eixo: EixoBNCC.tecnologia.valor,
    );
    await jogo.registrarResposta(
      partidaId: partidaTecnologia.id!,
      questaoId: facil.id!,
      respostaAluno: 'A',
      acertou: true,
    );
    await jogo.encerrarPartida(partidaTecnologia.id!, aluno.usuario);

    final partidaImpacto = await jogo.iniciarPartida(
      aluno.id!,
      eixo: EixoBNCC.impacto.valor,
    );
    await jogo.registrarResposta(
      partidaId: partidaImpacto.id!,
      questaoId: dificil.id!,
      respostaAluno: 'A',
      acertou: false,
    );
    await jogo.encerrarPartida(partidaImpacto.id!, aluno.usuario);

    final respostas = await jogo.historicoRespostas(aluno.id!);
    expect(respostas, hasLength(2));
    expect(respostas.where((resposta) => resposta.correta), hasLength(1));
    expect(
      respostas.map((resposta) => resposta.enunciado),
      contains(facil.enunciado),
    );

    final ranking = RankingRepository(banco: banco);
    final geral = await ranking.porAluno(aluno.id!);
    final porTecnologia = await ranking.listarPorEixo(
      EixoBNCC.tecnologia.valor,
    );
    final porImpacto = await ranking.listarPorEixo(EixoBNCC.impacto.valor);
    expect(geral!.totalJogos, 2);
    expect(geral.pontuacaoTotal, 100);
    expect(geral.taxaAcerto, 50);
    expect(porTecnologia.single.taxaAcerto, 100);
    expect(porImpacto.single.taxaAcerto, 0);

    final estatisticas = EstatisticaRepository(banco: banco);
    final resumo = await estatisticas.gerarEstatisticasGerais(professor.id!);
    final resumoOutro = await estatisticas.gerarEstatisticasGerais(
      outroProfessor.id!,
    );
    final maisFaceis = await estatisticas.questoesMaisFaceis(
      professorId: professor.id!,
    );
    final maisDificeis = await estatisticas.questoesMaisDificeis(
      professorId: professor.id!,
    );
    expect(resumo.totalAlunos, 1);
    expect(resumo.totalPartidas, 2);
    expect(resumo.totalRespostas, 2);
    expect(resumo.totalAcertos, 1);
    expect(resumoOutro.totalAlunos, 1);
    expect(resumoOutro.totalPartidas, 0);
    expect(maisFaceis.single.questaoId, facil.id);
    expect(maisDificeis.single.questaoId, dificil.id);

    final alunosDaProfessora = await usuarios.listarAlunos(
      professorId: professor.id,
    );
    expect(alunosDaProfessora.map((usuario) => usuario.id), [aluno.id]);
  });
}
