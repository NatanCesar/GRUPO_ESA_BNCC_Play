import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/profile/edit_profile_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

/// Cadastra o usuario, abre a sessao com ele e monta a tela de edicao.
Future<AppUser> prepararTela(
  WidgetTester tester, {
  required Papel papel,
  bool abrirSessao = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final usuario = papel == Papel.professor
      ? await ambiente.usuarios.cadastrar(
          nome: 'Maria Silva',
          email: 'professor@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Monteiro Lobato',
        )
      : await ambiente.usuarios.cadastrar(
          nome: 'Joao Santos',
          email: 'joao@email.com',
          usuario: 'joaosantos',
          senha: 'Aluno@12345',
          papel: Papel.aluno,
          turma: '9 ano B',
        );

  if (abrirSessao) ambiente.sessao.abrir(usuario);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const EditProfileScreen(),
        routes: {
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pump();
  return usuario;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  group('CT11 - Alteracao de Cadastro do Aluno', () {
    testWidgets('funcional: novo e-mail e salvo', (tester) async {
      final aluno = await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(
        find.byType(TextField).at(1),
        'joao.novo@email.com',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      final gravado = await ambiente.usuarios.porId(aluno.id!);
      expect(gravado!.email, 'joao.novo@email.com');
      expect(find.text('Dados atualizados'), findsOneWidget);
    });

    testWidgets('a sessao passa a refletir o dado novo', (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(find.byType(TextField).at(0), 'Joao Pedro Santos');
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      expect(ambiente.sessao.usuario!.nome, 'Joao Pedro Santos');
    });

    testWidgets('os campos vem preenchidos com o cadastro atual', (
      tester,
    ) async {
      await prepararTela(tester, papel: Papel.aluno);

      final campos = tester
          .widgetList<TextField>(find.byType(TextField))
          .map((c) => c.controller!.text)
          .toList();

      expect(campos, [
        'Joao Santos',
        'joao@email.com',
        'joaosantos',
        '9 ano B',
      ]);
    });

    testWidgets('o aluno edita turma, nao escola', (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      expect(find.text('Turma'), findsOneWidget);
      expect(find.text('Escola'), findsNothing);
    });

    testWidgets('nao funcional: sem sessao a tela manda para o login', (
      tester,
    ) async {
      await prepararTela(tester, papel: Papel.aluno, abrirSessao: false);

      expect(find.text('tela de login'), findsOneWidget);
    });

    testWidgets('recusa e-mail invalido', (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(find.byType(TextField).at(1), 'joao.email');
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('recusa e-mail de outra conta', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );
      await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(
        find.byType(TextField).at(1),
        'professor@escola.com',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Este e-mail já está cadastrado'), findsOneWidget);
    });

    testWidgets('nao funcional: script no nome nao chega ao banco', (
      tester,
    ) async {
      final aluno = await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(
        find.byType(TextField).at(0),
        'Joao<script>alert(1)</script>Santos',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      expect((await ambiente.usuarios.porId(aluno.id!))!.nome, 'JoaoSantos');
    });
  });

  group('CT12 - Alteracao de Cadastro do Professor', () {
    testWidgets('funcional: nova instituicao e salva', (tester) async {
      final professor = await prepararTela(tester, papel: Papel.professor);

      await tester.enterText(
        find.byType(TextField).at(3),
        'E.E. Santos Dumont',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      final gravado = await ambiente.usuarios.porId(professor.id!);
      expect(gravado!.escola, 'E.E. Santos Dumont');
    });

    testWidgets('o professor edita escola, nao turma', (tester) async {
      await prepararTela(tester, papel: Papel.professor);

      expect(find.text('Escola'), findsOneWidget);
      expect(find.text('Turma'), findsNothing);
    });

    testWidgets('nao funcional: sessao expirada bloqueia a alteracao', (
      tester,
    ) async {
      final professor = await prepararTela(tester, papel: Papel.professor);

      // Encerrar a sessao equivale, para a tela, a sessao expirada.
      ambiente.sessao.encerrar();
      await tester.pump();
      await tester.pump();

      expect(find.text('tela de login'), findsOneWidget);
      expect(
        (await ambiente.usuarios.porId(professor.id!))!.escola,
        'E.E. Monteiro Lobato',
      );
    });

    testWidgets('nao mostra campo de senha', (tester) async {
      await prepararTela(tester, papel: Papel.professor);

      expect(find.text('Senha'), findsNothing);
      expect(find.byType(TextField), findsNWidgets(4));
    });
  });
}
