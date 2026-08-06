import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/features/auth/forgot_password_screen.dart';

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const ForgotPasswordScreen(),
      routes: {Rotas.login: (_) => const Scaffold(body: Text('tela de login'))},
    ),
  );
  await tester.pump();
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('avisa que o recurso ainda nao esta disponivel',
        (tester) async {
      await pumpTela(tester);

      expect(find.text('Recuperar senha'), findsOneWidget);
      expect(
        find.text(
          'A recuperação de senha por e-mail depende de servidor e chega numa próxima entrega.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('nao pede e-mail, para nao simular envio que nao acontece',
        (tester) async {
      await pumpTela(tester);

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Voltar ao login leva ao login', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Voltar ao login'));
      await tester.pump();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });
}
