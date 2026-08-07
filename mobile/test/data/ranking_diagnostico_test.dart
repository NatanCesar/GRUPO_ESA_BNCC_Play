import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/game_repository.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/data/repositories/ranking_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Diagnóstico: listarPorEixo retorna vazio quando aluno só joga partidas GERAIS', () async {
    final banco = await abrirBancoDeTeste();
    addTearDown(banco.fechar);

    final usuarios = UserRepository(
      banco: banco,
      hasher: const PasswordHasher(iteracoes: 1000),
    );
    final professor = await usuarios.cadastrar(
      nome: 'Profa',
      email: 'profa@e.com',
      usuario: 'profa',
      senha: 'Senha123',
      papel: Papel.professor,
      escola: 'Escola',
    );
    final aluno = await usuarios.cadastrar(
      nome: 'Aluno',
      email: 'aluno@e.com',
      usuario: 'aluno',
      senha: 'Senha123',
      papel: Papel.aluno,
      turma: '7A',
      professorId: professor.id,
    );

    final questoes = QuestaoRepository(banco: banco);
    final qTec = await questoes.cadastrar(
      enunciado: 'Q tec',
      opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
      respostaCorreta: 'A',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.facil,
      categoria: 'Geral',
      professorId: professor.id!,
    );
    final qCult = await questoes.cadastrar(
      enunciado: 'Q cult',
      opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
      respostaCorreta: 'A',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
      categoria: 'Geral',
      professorId: professor.id!,
    );
    final qImp = await questoes.cadastrar(
      enunciado: 'Q imp',
      opcaoA: 'A', opcaoB: 'B', opcaoC: 'C', opcaoD: 'D',
      respostaCorreta: 'A',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.facil,
      categoria: 'Geral',
      professorId: professor.id!,
    );

    final jogo = GameRepository(banco: banco);

    // Aluno joga uma partida SEM eixo (geral)
    final partidaGeral = await jogo.iniciarPartida(aluno.id!);
    await jogo.registrarResposta(
      partidaId: partidaGeral.id!,
      questaoId: qTec.id!,
      respostaAluno: 'A',
      acertou: true,
    );
    await jogo.encerrarPartida(partidaGeral.id!, aluno.usuario);

    // Aluno joga uma partida COM eixo tecnologia
    final partidaTec = await jogo.iniciarPartida(aluno.id!, eixo: 'tecnologia');
    await jogo.registrarResposta(
      partidaId: partidaTec.id!,
      questaoId: qTec.id!,
      respostaAluno: 'A',
      acertou: true,
    );
    await jogo.encerrarPartida(partidaTec.id!, aluno.usuario);

    final ranking = RankingRepository(banco: banco);

    print('GERAL: ${(await ranking.listarGeral()).length}');
    print('TECNOLOGIA: ${(await ranking.listarPorEixo('tecnologia')).length}');
    print('CULTURA: ${(await ranking.listarPorEixo('cultura')).length}');
    print('IMPACTO: ${(await ranking.listarPorEixo('impacto')).length}');
  });
}
