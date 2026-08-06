import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/auth/register_student_screen.dart';

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
        home: const RegisterStudentScreen(),
        routes: {
          Rotas.homeStudent: (_) => const Scaffold(body: Text('home do aluno')),
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> preencher(
  WidgetTester tester, {
  String nome = 'Joao Santos',
  String email = 'joao@email.com',
  String usuario = 'joaosantos',
  String turma = '9 ano B',
  String senha = 'Aluno@12345',
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nome);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), usuario);
  await tester.enterText(campos.at(3), turma);
  await tester.enterText(campos.at(4), senha);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  group('CT04 - Cadastro de Aluno', () {
    testWidgets('nao funcional: minimizacao, so os cinco campos previstos', (
      tester,
    ) async {
      await pumpTela(tester);

      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Nome completo'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Nome de usuário'), findsOneWidget);
      expect(find.text('Turma'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('funcional: conta criada com sucesso', (tester) async {
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('home do aluno'), findsOneWidget);

      final gravado = await ambiente.usuarios.porEmail('joao@email.com');
      expect(gravado!.papel, Papel.aluno);
      expect(gravado.turma, '9 ano B');
      expect(gravado.escola, isNull);
    });

    testWidgets('nao funcional: script no nome nao chega ao banco', (
      tester,
    ) async {
      await pumpTela(tester);
      await preencher(tester, nome: 'Joao<script>alert(1)</script>Santos');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      final gravado = await ambiente.usuarios.porEmail('joao@email.com');
      expect(gravado!.nome, 'JoaoSantos');
    });

    testWidgets('nao funcional: recusa texto longo demais na turma', (
      tester,
    ) async {
      await pumpTela(tester);
      await preencher(tester, turma: 'a' * 81);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('A turma precisa de 2 a 80 caracteres'), findsOneWidget);
      expect(find.text('home do aluno'), findsNothing);
    });

    testWidgets('formulario vazio cobra os cinco campos', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu nome'), findsOneWidget);
      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe seu nome de usuário'), findsOneWidget);
      expect(find.text('Informe sua turma'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('avisa quando o nome de usuario ja existe', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Outro Joao',
        email: 'outro@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '8 ano A',
      );
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Este nome de usuário já está em uso'), findsOneWidget);
    });
  });

  group('RegisterStudentScreen - navegacao', () {
    testWidgets('Entrar leva ao login', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });
}
