import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/features/home/home_student_screen.dart';
import 'package:bncc_play_mobile/features/home/home_teacher_screen.dart';

AppUser usuarioDe(Papel papel) {
  final momento = DateTime.utc(2026, 7, 31, 12);
  return AppUser(
    id: 1,
    nome: papel == Papel.professor ? 'Maria Silva' : 'João Santos',
    email: papel == Papel.professor ? 'professor@escola.com' : 'joao@email.com',
    usuario: papel == Papel.professor ? 'mariasilva' : 'joaosantos',
    papel: papel,
    escola: papel == Papel.professor ? 'E.E. Monteiro Lobato' : null,
    turma: papel == Papel.aluno ? '9 ano B' : null,
    criadoEm: momento,
    atualizadoEm: momento,
  );
}

Future<void> pumpHome(
  WidgetTester tester, {
  required Papel papel,
  bool comSessao = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final sessao = SessionScope();
  if (comSessao) sessao.abrir(usuarioDe(papel));

  await tester.pumpWidget(
    ChangeNotifierProvider<SessionScope>.value(
      value: sessao,
      child: MaterialApp(
        theme: AppTheme.light,
        home: papel == Papel.professor
            ? const HomeTeacherScreen()
            : const HomeStudentScreen(),
        routes: {
          Rotas.profileTeacher: (_) =>
              const Scaffold(body: Text('perfil do professor')),
          Rotas.profileStudent: (_) =>
              const Scaffold(body: Text('perfil do aluno')),
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomeTeacherScreen', () {
    testWidgets('saúda o professor logado pelo primeiro nome', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      expect(find.text('Olá, Maria!'), findsOneWidget);
    });

    testWidgets('mostra a escola do professor', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      expect(find.text('E.E. Monteiro Lobato'), findsOneWidget);
    });

    testWidgets('mostra os itens de navegacao do professor', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Questões'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('Perfil leva ao perfil do professor', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('perfil do professor'), findsOneWidget);
    });

    testWidgets('item de ciclo futuro avisa em vez de ficar mudo',
        (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      await tester.tap(find.text('Questões'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Disponível na próxima entrega.'),
        findsOneWidget,
      );
    });

    testWidgets('sem sessao valida manda para o login', (tester) async {
      await pumpHome(tester, papel: Papel.professor, comSessao: false);

      await tester.pump();
      await tester.pump();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });

  group('HomeStudentScreen', () {
    testWidgets('saúda o aluno e mostra a turma', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      expect(find.text('Olá, João!'), findsOneWidget);
      expect(find.text('9 ano B'), findsOneWidget);
    });

    testWidgets('mostra os itens de navegacao do aluno', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Jogar'), findsOneWidget);
      expect(find.text('Ranking'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('Perfil leva ao perfil do aluno', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('perfil do aluno'), findsOneWidget);
    });

    testWidgets('Jogar avisa que chega na proxima entrega', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      await tester.tap(find.text('Jogar'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Disponível na próxima entrega.'),
        findsOneWidget,
      );
    });
  });
}
