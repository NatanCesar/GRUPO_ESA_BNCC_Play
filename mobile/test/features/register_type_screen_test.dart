import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/features/auth/register_type_screen.dart';

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const RegisterTypeScreen(),
      routes: {
        Rotas.registerTeacher: (_) =>
            const Scaffold(body: Text('cadastro do professor')),
        Rotas.registerStudent: (_) =>
            const Scaffold(body: Text('cadastro do aluno')),
      },
    ),
  );
  await tester.pump();
}

void main() {
  group('RegisterTypeScreen - conteudo', () {
    testWidgets('mostra a pergunta e as duas opcoes', (tester) async {
      await pumpTela(tester);

      expect(find.text('Quem é você?'), findsOneWidget);
      expect(find.text('Escolha seu perfil para começar'), findsOneWidget);
      expect(find.text('Sou Professor(a)'), findsOneWidget);
      expect(find.text('Sou Aluno(a)'), findsOneWidget);
    });

    testWidgets('descreve o que cada perfil faz', (tester) async {
      await pumpTela(tester);

      expect(
        find.text(
          'Cadastre questões, acompanhe turmas e visualize relatórios pedagógicos',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Jogue, aprenda, suba no ranking e desafie seus colegas'),
        findsOneWidget,
      );
    });
  });

  group('RegisterTypeScreen - navegacao', () {
    testWidgets('professor leva ao cadastro do professor', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Sou Professor(a)'));
      await tester.pump();
      await tester.pump();

      expect(find.text('cadastro do professor'), findsOneWidget);
    });

    testWidgets('aluno leva ao cadastro do aluno', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Sou Aluno(a)'));
      await tester.pump();
      await tester.pump();

      expect(find.text('cadastro do aluno'), findsOneWidget);
    });
  });

  group('RegisterTypeScreen - layout', () {
    testWidgets('cabe em telefone estreito', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const RegisterTypeScreen(),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
