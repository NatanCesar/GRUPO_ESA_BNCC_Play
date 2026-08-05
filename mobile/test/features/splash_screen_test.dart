import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/features/auth/splash_screen.dart';

Future<void> pumpSplash(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        Rotas.registerType: (_) => const Scaffold(body: Text('escolha de perfil')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SplashScreen - conteudo', () {
    testWidgets('mostra a marca e a chamada', (tester) async {
      await pumpSplash(tester);

      expect(find.text('BNCC Play'), findsOneWidget);
      expect(
        find.text('Aprenda computação jogando'),
        findsOneWidget,
      );
    });

    testWidgets('mostra as duas acoes', (tester) async {
      await pumpSplash(tester);

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });
  });

  group('SplashScreen - navegacao', () {
    testWidgets('Entrar leva ao login', (tester) async {
      await pumpSplash(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });

    testWidgets('Criar conta leva a escolha de perfil', (tester) async {
      await pumpSplash(tester);

      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('escolha de perfil'), findsOneWidget);
    });
  });

  group('SplashScreen - layout', () {
    testWidgets('cabe em telefone estreito sem estourar', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
