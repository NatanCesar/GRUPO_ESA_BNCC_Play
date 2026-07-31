import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/features/auth/login_screen.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';

/// Monta a tela num viewport de telefone real (390x844, o frame do Figma).
/// Sem isso o teste roda em 800x600 e o rodape fica fora da area visivel.
Future<void> pumpLogin(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
  );
}

void main() {
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

    testWidgets('mostra as acoes secundarias', (tester) async {
      await pumpLogin(tester);

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Entrar como Aluno'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem conta?'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
      expect(find.text('ou'), findsOneWidget);
    });
  });

  group('LoginScreen - validacao', () {
    testWidgets('Entrar com os dois campos vazios mostra os dois erros',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('Entrar so com e-mail cobra apenas a senha', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextField).first, 'maria@escola.br');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsNothing);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('preencher o campo limpa o erro ja exibido', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe seu e-mail'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'maria@escola.br');
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsNothing);
    });
  });

  group('LoginScreen - acoes', () {
    testWidgets('Entrar preenchido mostra o aviso de desenvolvimento',
        (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextField).first, 'maria@escola.br');
      await tester.enterText(find.byType(TextField).last, 'segredo123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsNothing);
      expect(find.text('Informe sua senha'), findsNothing);
      expect(find.widgetWithText(SnackBar, 'Login em desenvolvimento.'),
          findsOneWidget);
    });

    testWidgets('Entrar como Aluno avisa que esta em desenvolvimento',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Entrar como Aluno'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Acesso do aluno em desenvolvimento.'),
        findsOneWidget,
      );
    });

    testWidgets('Esqueci minha senha avisa que esta em desenvolvimento',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
            SnackBar, 'Recuperação de senha em desenvolvimento.'),
        findsOneWidget,
      );
    });

    testWidgets('Criar conta avisa que esta em desenvolvimento',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Cadastro em desenvolvimento.'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - layout', () {
    testWidgets('o conteudo rola quando a tela fica curta', (tester) async {
      await pumpLogin(tester, size: const Size(390, 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('cabe num telefone estreito com fonte ampliada',
        (tester) async {
      await pumpLogin(tester, size: const Size(320, 844));

      expect(tester.takeException(), isNull);
    });
  });
}
