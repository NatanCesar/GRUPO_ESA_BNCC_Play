import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/auth_controller.dart';
import 'package:bncc_play_mobile/data/repositories/erros.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;
  late AuthController auth;

  setUp(() async {
    banco = await abrirBancoDeTeste();
    auth = AuthController(
      banco: banco,
      hasher: const PasswordHasher(iteracoes: 1000),
    );
  });
  tearDown(() async => banco.fechar());

  group('CT05 e CT08 - Login', () {
    test('funcional: login com credenciais validas devolve token e perfil', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      final resultado = await auth.login(
        email: 'maria@escola.com',
        senha: 'Professor@123',
      );

      expect(resultado.token, isNotEmpty);
      expect(resultado.perfil.nome, 'Maria Silva');
      expect(resultado.perfil.papel, Papel.professor);
    });

    test('ignora espacos e caixa no e-mail', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      final resultado = await auth.login(
        email: '  MARIA@ESCOLA.COM ',
        senha: 'Professor@123',
      );

      expect(resultado.token, isNotEmpty);
    });

    test('CT08: CredenciaisInvalidasException para e-mail sem cadastro', () async {
      expect(
        () => auth.login(email: 'ninguem@x.com', senha: 'qualquer'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
    });

    test('CT08: CredenciaisInvalidasException para senha errada', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      expect(
        () => auth.login(email: 'maria@escola.com', senha: 'SenhaErrada'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
    });

    test('CT08: resetar tentativa falha limpa o contador', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      // Tres tentativas falhadas
      for (var i = 0; i < 3; i++) {
        try {
          await auth.login(email: 'maria@escola.com', senha: 'errada');
        } on CredenciaisInvalidasException {
          // esperado
        }
      }

      // A proxima ainda funciona se a senha estiver correta
      final resultado = await auth.login(
        email: 'maria@escola.com',
        senha: 'Professor@123',
      );
      expect(resultado.token, isNotEmpty);
    });
  });

  group('CT09 - Logout', () {
    test('logout invalida o token', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      final resultado = await auth.login(
        email: 'maria@escola.com',
        senha: 'Professor@123',
      );

      await auth.logout(usuarioId: resultado.perfil.id!);

      expect(
        () => auth.validarToken(
          usuarioId: resultado.perfil.id!,
          token: resultado.token,
        ),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });
  });

  group('CT07 - Cadastro com validacao', () {
    test('cadastro via controller ainda exige validacao', () async {
      // Nome vazio
      await expectLater(
        () => auth.cadastrar(
          nome: '',
          email: 'maria@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Monteiro Lobato',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // E-mail invalido
      await expectLater(
        () => auth.cadastrar(
          nome: 'Maria Silva',
          email: 'nao-e-email',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Monteiro Lobato',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Senha curta
      await expectLater(
        () => auth.cadastrar(
          nome: 'Maria Silva',
          email: 'maria@escola.com',
          usuario: 'mariasilva',
          senha: 'curta',
          papel: Papel.professor,
          escola: 'E.E. Monteiro Lobato',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('cadastro via controller devolve token e perfil', () async {
      final resultado = await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      expect(resultado.token, isNotEmpty);
      expect(resultado.perfil.nome, 'Maria Silva');
    });

    test('CT07: EmailJaCadastradoException quando repete e-mail', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      expect(
        () => auth.cadastrar(
          nome: 'Outro Nome',
          email: 'maria@escola.com',
          usuario: 'outrousuario',
          senha: 'Outra@123',
          papel: Papel.aluno,
          turma: '9 ano B',
        ),
        throwsA(isA<EmailJaCadastradoException>()),
      );
    });

    test('CT07: UsuarioJaCadastradoException quando repete usuario', () async {
      await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      expect(
        () => auth.cadastrar(
          nome: 'Outro Nome',
          email: 'outro@escola.com',
          usuario: 'mariasilva',
          senha: 'Outra@123',
          papel: Papel.aluno,
          turma: '9 ano B',
        ),
        throwsA(isA<UsuarioJaCadastradoException>()),
      );
    });
  });
}
