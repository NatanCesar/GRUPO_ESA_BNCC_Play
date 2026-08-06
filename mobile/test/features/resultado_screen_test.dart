import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/data/models/partida.dart';
import 'package:bncc_play_mobile/features/game/resultado_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Início volta para a home do aluno e limpa o jogo', (
    tester,
  ) async {
    final partida = Partida(
      id: 1,
      alunoId: 1,
      pontuacao: 300,
      streak: 2,
      respondidas: 5,
      acertos: 3,
      iniciadaEm: DateTime.utc(2026, 8, 6),
      terminadaEm: DateTime.utc(2026, 8, 6, 0, 5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ResultadoScreen(
          partida: partida,
          apelido: 'aluno.teste',
          carregarPosicao: (_) async => null,
        ),
        routes: {
          Rotas.homeStudent: (_) => const Scaffold(body: Text('home do aluno')),
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    await tester.ensureVisible(find.text('Início'));
    await tester.tap(find.text('Início'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('home do aluno'), findsOneWidget);
    expect(find.byType(ResultadoScreen), findsNothing);
  });
}
