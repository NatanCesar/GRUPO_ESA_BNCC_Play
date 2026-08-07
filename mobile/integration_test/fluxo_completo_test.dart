import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    banco = await AppDatabase.abrir(caminho: inMemoryDatabasePath);
  });
  tearDown(() async => banco.fechar());

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(BnccPlayApp(banco: banco));
    await tester.pumpAndSettle();
  }

  testWidgets('cadastro, logout, login e alteracao de cadastro', (
    tester,
  ) async {
    await abrirApp(tester);

    // Splash -> escolha de perfil -> cadastro de professor
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sou Professor(a)'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'Maria Silva');
    await tester.enterText(campos.at(1), 'professor@escola.com');
    await tester.enterText(campos.at(2), 'mariasilva');
    await tester.enterText(campos.at(3), 'E.E. Monteiro Lobato');
    await tester.enterText(campos.at(4), 'Professor@123');
    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria!'), findsOneWidget);

    // Home -> perfil -> sair
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('professor@escola.com'), findsOneWidget);

    await tester.tap(find.text('Sair da Conta'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);

    // Login com a conta recem-criada
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(0),
      'professor@escola.com',
    );
    await tester.enterText(find.byType(TextField).at(1), 'Professor@123');
    await tester.tap(find.widgetWithText(InkWell, 'Entrar').last);
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria!'), findsOneWidget);

    // Perfil -> editar -> salvar
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar Perfil'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(3), 'E.E. Santos Dumont');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Dados atualizados'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('E.E. Santos Dumont'), findsOneWidget);
  });

  testWidgets('cinco senhas erradas bloqueiam o login', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sou Aluno(a)'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'Joao Santos');
    await tester.enterText(campos.at(1), 'joao@email.com');
    await tester.enterText(campos.at(2), 'joaosantos');
    await tester.enterText(campos.at(3), '9 ano B');
    await tester.enterText(campos.at(4), 'Aluno@12345');
    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da Conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.enterText(find.byType(TextField).at(0), 'joao@email.com');
      await tester.enterText(find.byType(TextField).at(1), 'errada123');
      await tester.tap(find.widgetWithText(InkWell, 'Entrar').last);
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('Muitas tentativas'), findsOneWidget);
  });
}
