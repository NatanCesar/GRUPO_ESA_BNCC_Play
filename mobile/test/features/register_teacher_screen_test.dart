import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/auth/register_teacher_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const RegisterTeacherScreen(),
        routes: {
          Rotas.homeTeacher: (_) =>
              const Scaffold(body: Text('home do professor')),
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Preenche os cinco campos na ordem em que aparecem na tela.
Future<void> preencher(
  WidgetTester tester, {
  String nome = 'Maria Silva',
  String email = 'professor@escola.com',
  String usuario = 'mariasilva',
  String escola = 'E.E. Monteiro Lobato',
  String senha = 'Professor@123',
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nome);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), usuario);
  await tester.enterText(campos.at(3), escola);
  await tester.enterText(campos.at(4), senha);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  group('CT03 - Cadastro de Professor', () {
    testWidgets('nao funcional: minimizacao, so os cinco campos previstos', (
      tester,
    ) async {
      await pumpTela(tester);

      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Nome completo'), findsOneWidget);
      expect(find.text('E-mail institucional'), findsOneWidget);
      expect(find.text('Nome de usuário'), findsOneWidget);
      expect(find.text('Escola'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('funcional: cadastro valido grava e abre a home', (
      tester,
    ) async {
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('home do professor'), findsOneWidget);

      final gravado = await ambiente.usuarios.porEmail('professor@escola.com');
      expect(gravado, isNotNull);
      expect(gravado!.papel, Papel.professor);
      expect(gravado.escola, 'E.E. Monteiro Lobato');
      expect(ambiente.sessao.usuario!.nome, 'Maria Silva');
    });

    testWidgets('formulario vazio cobra os cinco campos', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu nome'), findsOneWidget);
      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe seu nome de usuário'), findsOneWidget);
      expect(find.text('Informe sua escola'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('nao funcional: recusa e-mail mal formado', (tester) async {
      await pumpTela(tester);
      await preencher(tester, email: 'maria.escola');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('home do professor'), findsNothing);
    });

    testWidgets('nao funcional: recusa senha curta', (tester) async {
      await pumpTela(tester);
      await preencher(tester, senha: 'curta1');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha precisa de ao menos 8 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets(
      'nao funcional: recusa nome de usuario com caractere especial',
      (tester) async {
        await pumpTela(tester);
        await preencher(tester, usuario: 'maria silha');

        await tester.tap(find.text('Criar Conta'));
        await tester.pumpAndSettle();

        expect(
          find.text('Use apenas letras, números, ponto e sublinhado'),
          findsOneWidget,
        );
      },
    );

    testWidgets('nao funcional: recusa nome longo demais', (tester) async {
      await pumpTela(tester);
      await preencher(tester, nome: 'a' * 81);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('O nome precisa de 3 a 80 caracteres'), findsOneWidget);
    });

    testWidgets('avisa quando o e-mail ja existe', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Outra Pessoa',
        email: 'professor@escola.com',
        usuario: 'outrapessoa',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Outra',
      );
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Este e-mail já está cadastrado'), findsOneWidget);
      expect(find.text('home do professor'), findsNothing);
    });

    testWidgets('a senha fica escondida no campo', (tester) async {
      await pumpTela(tester);

      final senha = tester.widget<TextField>(find.byType(TextField).at(4));
      expect(senha.obscureText, isTrue);
    });

    testWidgets('o olho mostra e volta a esconder a senha', (tester) async {
      await pumpTela(tester);

      expect(find.byTooltip('Mostrar senha'), findsOneWidget);
      await tester.tap(find.byKey(const Key('toggle-password-visibility')));
      await tester.pump();

      var senha = tester.widget<TextField>(find.byType(TextField).at(4));
      expect(senha.obscureText, isFalse);
      expect(find.byTooltip('Esconder senha'), findsOneWidget);

      await tester.tap(find.byKey(const Key('toggle-password-visibility')));
      await tester.pump();

      senha = tester.widget<TextField>(find.byType(TextField).at(4));
      expect(senha.obscureText, isTrue);
    });
  });

  group('RegisterTeacherScreen - navegacao', () {
    testWidgets('Entrar leva ao login', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });

  group('RegisterTeacherScreen - layout', () {
    testWidgets('rola quando a tela e curta', (tester) async {
      tester.view.physicalSize = const Size(390, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpTela(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
