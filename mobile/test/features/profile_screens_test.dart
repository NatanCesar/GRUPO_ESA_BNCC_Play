import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/features/profile/profile_student_screen.dart';
import 'package:bncc_play_mobile/features/profile/profile_teacher_screen.dart';

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

late SessionScope sessao;

Future<void> pumpPerfil(WidgetTester tester, {required Papel papel}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  sessao = SessionScope()..abrir(usuarioDe(papel));

  await tester.pumpWidget(
    ChangeNotifierProvider<SessionScope>.value(
      value: sessao,
      child: MaterialApp(
        theme: AppTheme.light,
        initialRoute: '/perfil-teste',
        routes: {
          '/perfil-teste': (_) => papel == Papel.professor
              ? const ProfileTeacherScreen()
              : const ProfileStudentScreen(),
          Rotas.editProfile: (_) => const Scaffold(body: Text('editar perfil')),
          Rotas.splash: (_) => const Scaffold(body: Text('tela inicial')),
        },
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ProfileTeacherScreen', () {
    testWidgets('mostra nome, e-mail e papel do professor', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('professor@escola.com'), findsOneWidget);
      expect(find.text('Professor(a)'), findsOneWidget);
    });

    testWidgets('mostra a escola no item Minha Escola', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      expect(find.text('Minha Escola'), findsOneWidget);
      expect(find.text('E.E. Monteiro Lobato'), findsOneWidget);
    });

    testWidgets('Minha Escola leva a edicao', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      await tester.tap(find.text('Minha Escola'));
      await tester.pumpAndSettle();

      expect(find.text('editar perfil'), findsOneWidget);
    });

    testWidgets('estatisticas comecam zeradas no ciclo 1', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      expect(find.text('Questões'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Editar Perfil leva a edicao', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      await tester.tap(find.text('Editar Perfil'));
      await tester.pump();
      await tester.pump();

      expect(find.text('editar perfil'), findsOneWidget);
    });

    testWidgets('Sair da Conta encerra a sessao e volta ao inicio',
        (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      await tester.tap(find.text('Sair da Conta'));
      await tester.pump();
      await tester.pump();

      expect(sessao.autenticado, isFalse);
      expect(find.text('tela inicial'), findsOneWidget);
    });
  });

  group('ProfileStudentScreen', () {
    testWidgets('mostra nome, arroba e papel do aluno', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      expect(find.text('João Santos'), findsOneWidget);
      expect(find.text('@joaosantos'), findsOneWidget);
      expect(find.text('Aluno(a)'), findsOneWidget);
    });

    testWidgets('mostra a turma', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      expect(find.text('9 ano B'), findsOneWidget);
    });

    testWidgets('Minha Turma leva a edicao', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      await tester.tap(find.text('Minha Turma'));
      await tester.pumpAndSettle();

      expect(find.text('editar perfil'), findsOneWidget);
    });

    testWidgets('nao mostra o e-mail de outros usuarios', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      expect(find.text('professor@escola.com'), findsNothing);
    });

    testWidgets('Editar Perfil leva a edicao', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      await tester.tap(find.text('Editar Perfil'));
      await tester.pump();
      await tester.pump();

      expect(find.text('editar perfil'), findsOneWidget);
    });

    testWidgets('Sair da Conta encerra a sessao', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      await tester.tap(find.text('Sair da Conta'));
      await tester.pump();
      await tester.pump();

      expect(sessao.autenticado, isFalse);
    });
  });
}
