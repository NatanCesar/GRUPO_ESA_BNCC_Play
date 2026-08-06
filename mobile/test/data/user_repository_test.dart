import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/errors.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;
  late UserRepository repo;

  setUp(() async {
    banco = await abrirBancoDeTeste();
    repo = UserRepository(
      banco: banco,
      hasher: const PasswordHasher(iteracoes: 1000),
    );
  });
  tearDown(() async => banco.fechar());

  Future<AppUser> cadastrarProfessor() => repo.cadastrar(
    nome: 'Maria Silva',
    email: 'professor@escola.com',
    usuario: 'mariasilva',
    senha: 'Professor@123',
    papel: Papel.professor,
    escola: 'E.E. Monteiro Lobato',
  );

  group('CT03 - Cadastro de Professor', () {
    test('funcional: cadastra e devolve o professor com id', () async {
      final professor = await cadastrarProfessor();

      expect(professor.id, isNotNull);
      expect(professor.nome, 'Maria Silva');
      expect(professor.email, 'professor@escola.com');
      expect(professor.papel, Papel.professor);
      expect(professor.escola, 'E.E. Monteiro Lobato');
      expect(professor.turma, isNull);
    });

    test('funcional: o professor cadastrado e encontrado por e-mail', () async {
      await cadastrarProfessor();

      final achado = await repo.porEmail('professor@escola.com');

      expect(achado, isNotNull);
      expect(achado!.usuario, 'mariasilva');
    });

    test('nao funcional: a senha nao fica em texto puro no banco', () async {
      await cadastrarProfessor();

      final linhas = await banco.db.query('users');

      expect(linhas.single['senha_hash'], isNot(contains('Professor')));
      expect(linhas.single.containsKey('senha'), isFalse);
      expect(linhas.single['salt'], isNotNull);
    });

    test(
      'nao funcional: minimizacao, a linha so tem os campos previstos',
      () async {
        await cadastrarProfessor();

        final linha = (await banco.db.query('users')).single;

        expect(linha.keys.toSet(), {
          'id',
          'nome',
          'email',
          'usuario',
          'senha_hash',
          'salt',
          'papel',
          'escola',
          'turma',
          'avatar',
          'criado_em',
          'atualizado_em',
          'professor_id',
        });
      },
    );

    test('recusa e-mail ja cadastrado', () async {
      await cadastrarProfessor();

      expect(
        () => repo.cadastrar(
          nome: 'Outra Pessoa',
          email: 'professor@escola.com',
          usuario: 'outrapessoa',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Outra',
        ),
        throwsA(isA<EmailJaCadastradoException>()),
      );
    });

    test('recusa nome de usuario ja em uso', () async {
      await cadastrarProfessor();

      expect(
        () => repo.cadastrar(
          nome: 'Outra Pessoa',
          email: 'outro@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Outra',
        ),
        throwsA(isA<UsuarioJaCadastradoException>()),
      );
    });

    test('normaliza e-mail para minusculo e sem espaco', () async {
      await repo.cadastrar(
        nome: 'Maria Silva',
        email: '  Professor@Escola.COM  ',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      expect(await repo.porEmail('professor@escola.com'), isNotNull);
    });

    test('exige escola para professor', () async {
      expect(
        () => repo.cadastrar(
          nome: 'Maria Silva',
          email: 'professor@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CT04 - Cadastro de Aluno', () {
    test('funcional: cadastra o aluno com turma', () async {
      final aluno = await repo.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      expect(aluno.papel, Papel.aluno);
      expect(aluno.turma, '9 ano B');
      expect(aluno.escola, isNull);
    });

    test('nao funcional: remove script do nome antes de gravar', () async {
      final aluno = await repo.cadastrar(
        nome: 'Joao<script>alert(1)</script>Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      expect(aluno.nome, 'JoaoSantos');
    });

    test('exige turma para aluno', () async {
      expect(
        () => repo.cadastrar(
          nome: 'Joao Santos',
          email: 'joao@email.com',
          usuario: 'joaosantos',
          senha: 'Aluno@12345',
          papel: Papel.aluno,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CT11 e CT12 - Alteracao de cadastro', () {
    test('funcional: altera o e-mail do aluno', () async {
      final aluno = await repo.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      final alterado = await repo.atualizar(
        aluno.copiarCom(email: 'joao.novo@email.com'),
      );

      expect(alterado.email, 'joao.novo@email.com');
      expect((await repo.porId(aluno.id!))!.email, 'joao.novo@email.com');
    });

    test('funcional: altera a escola do professor', () async {
      final professor = await cadastrarProfessor();

      final alterado = await repo.atualizar(
        professor.copiarCom(escola: 'E.E. Santos Dumont'),
      );

      expect(alterado.escola, 'E.E. Santos Dumont');
    });

    test('carimba atualizado_em na alteracao', () async {
      final professor = await cadastrarProfessor();

      final alterado = await repo.atualizar(
        professor.copiarCom(nome: 'Maria Silva Souza'),
      );

      expect(
        alterado.atualizadoEm.isAfter(professor.atualizadoEm) ||
            alterado.atualizadoEm.isAtSameMomentAs(professor.atualizadoEm),
        isTrue,
      );
      expect(alterado.criadoEm, professor.criadoEm);
    });

    test('recusa alteracao para e-mail de outra conta', () async {
      await cadastrarProfessor();
      final aluno = await repo.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      expect(
        () => repo.atualizar(aluno.copiarCom(email: 'professor@escola.com')),
        throwsA(isA<EmailJaCadastradoException>()),
      );
    });

    test('sanitiza o texto na alteracao', () async {
      final professor = await cadastrarProfessor();

      final alterado = await repo.atualizar(
        professor.copiarCom(escola: 'E.E. <b>Nova</b>'),
      );

      expect(alterado.escola, 'E.E. Nova');
    });

    test('recusa alteracao de usuario sem id', () async {
      final professor = await cadastrarProfessor();
      final semId = AppUserSemId.de(professor);

      expect(() => repo.atualizar(semId), throwsA(isA<ArgumentError>()));
    });
  });

  group('UserRepository.porEmail', () {
    test('devolve nulo quando nao existe', () async {
      expect(await repo.porEmail('ninguem@x.com'), isNull);
    });

    test('ignora caixa e espaco na busca', () async {
      await cadastrarProfessor();

      expect(await repo.porEmail('  PROFESSOR@escola.com '), isNotNull);
    });
  });
}

/// Copia um usuario zerando o id, para exercitar o caminho de erro de
/// `atualizar`. `copiarCom` preserva o id de proposito, entao a copia e
/// feita a mao aqui.
abstract final class AppUserSemId {
  static AppUser de(AppUser origem) => AppUser(
    nome: origem.nome,
    email: origem.email,
    usuario: origem.usuario,
    papel: origem.papel,
    escola: origem.escola,
    turma: origem.turma,
    avatar: origem.avatar,
    criadoEm: origem.criadoEm,
    atualizadoEm: origem.atualizadoEm,
  );
}
