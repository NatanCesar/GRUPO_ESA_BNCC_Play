import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/auth_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/auth/login_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

/// Monta a tela num viewport de telefone real (390x844, o frame do Figma),
/// com os repositorios de verdade sobre banco em memoria.
Future<void> pumpLogin(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        Provider<AuthRepository>.value(value: ambiente.auth),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LoginScreen(),
        routes: {
          Rotas.homeTeacher: (_) => const Scaffold(body: Text('home do professor')),
          Rotas.homeStudent: (_) => const Scaffold(body: Text('home do aluno')),
          Rotas.registerType: (_) => const Scaffold(body: Text('escolha de perfil')),
          Rotas.forgotPassword: (_) => const Scaffold(body: Text('esqueci a senha')),
        },
      ),
    ),
  );
}

Future<void> preencher(
  WidgetTester tester, {
  required String email,
  required String senha,
}) async {
  await tester.enterText(find.byType(TextField).first, email);
  await tester.enterText(find.byType(TextField).last, senha);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  Future<void> cadastrarProfessor() => ambiente.usuarios.cadastrar(
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

  group('LoginScreen - conteudo', () {
    testWidgets('mostra o cabecalho de boas-vindas', (tester) async {
      await pumpLogin(tester);

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.text('Entre para continuar jogando'), findsOneWidget);
    });

    testWidgets('mostra os campos de e-mail e senha', (tester) async {
      await pumpLogin(tester);

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('campos comecam vazios, mostrando so o placeholder',
        (tester) async {
      await pumpLogin(tester);

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      for (final field in fields) {
        expect(field.controller!.text, isEmpty);
      }
      expect(find.text('seu@email.com'), findsOneWidget);
      expect(find.text('Sua senha'), findsOneWidget);
    });

    testWidgets('esconde o texto do campo de senha', (tester) async {
      await pumpLogin(tester);

      final senha = tester.widget<TextField>(find.byType(TextField).last);
      expect(senha.obscureText, isTrue);
    });

    testWidgets('mostra as acoes', (tester) async {
      await pumpLogin(tester);

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem conta?'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });
  });

  group('LoginScreen - validacao', () {
    testWidgets('Entrar com os dois campos vazios mostra os dois erros',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('Entrar so com e-mail cobra apenas a senha', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextField).first, 'maria@escola.br');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe seu e-mail'), findsNothing);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('preencher o campo limpa o erro ja exibido', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Informe seu e-mail'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'maria@escola.br');
      await tester.pump();

      expect(find.text('Informe seu e-mail'), findsNothing);
    });
  });

  group('CT01 - Efetivacao de Login do Professor', () {
    testWidgets('funcional: credenciais validas abrem a home do professor',
        (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      await preencher(tester, email: 'professor@escola.com', senha: 'Professor@123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('home do professor'), findsOneWidget);
      expect(ambiente.sessao.usuario!.nome, 'Maria Silva');
    });

    testWidgets('senha errada mostra o erro e nao navega', (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      await preencher(tester, email: 'professor@escola.com', senha: 'errada123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
      expect(find.text('home do professor'), findsNothing);
      expect(ambiente.sessao.autenticado, isFalse);
    });

    testWidgets('nao funcional: apos cinco erros a tela avisa o bloqueio',
        (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      for (var i = 0; i < 5; i++) {
        await preencher(tester, email: 'professor@escola.com', senha: 'errada123');
        await tester.tap(find.text('Entrar'));
        await tester.pump();
      }

      expect(find.textContaining('Muitas tentativas'), findsOneWidget);
    });

    testWidgets('nao funcional: durante o bloqueio a senha certa nao entra',
        (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      for (var i = 0; i < 5; i++) {
        await preencher(tester, email: 'professor@escola.com', senha: 'errada123');
        await tester.tap(find.text('Entrar'));
        await tester.pump();
      }

      await preencher(tester, email: 'professor@escola.com', senha: 'Professor@123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('home do professor'), findsNothing);
      expect(find.textContaining('Muitas tentativas'), findsOneWidget);
    });

    testWidgets('a senha nunca aparece na tela', (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      await preencher(tester, email: 'professor@escola.com', senha: 'errada123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.textContaining('errada123'), findsNothing);
    });
  });

  group('CT02 - Efetivacao de Login do Aluno', () {
    testWidgets('funcional: o aluno cai na home do aluno', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );
      await pumpLogin(tester);

      await preencher(tester, email: 'joao@email.com', senha: 'Aluno@12345');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('home do aluno'), findsOneWidget);
      expect(ambiente.sessao.papel, Papel.aluno);
    });
  });

  group('LoginScreen - acoes secundarias', () {
    testWidgets('Criar conta leva a escolha de perfil', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('escolha de perfil'), findsOneWidget);
    });

    testWidgets('Esqueci minha senha leva a recuperacao', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pump();

      expect(find.text('esqueci a senha'), findsOneWidget);
    });
  });

  group('LoginScreen - layout', () {
    testWidgets('o conteudo rola quando a tela fica curta', (tester) async {
      await pumpLogin(tester, size: const Size(390, 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('cabe num telefone estreito com fonte ampliada', (tester) async {
      await pumpLogin(tester, size: const Size(320, 844));

      expect(tester.takeException(), isNull);
    });
  });
}
