import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/repositories/ranking_repository.dart';
import 'package:bncc_play_mobile/features/ranking/ranking_screen.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'BUG: ao tocar em outras abas, dados corretos aparecem',
    (tester) async {
      final banco = await abrirBancoDeTeste();
      addTearDown(banco.fechar);

      // Insere partida direto via SQL
      final repo = RankingRepository(banco: banco);
      // Cria aluno e partidas direto via insert
      await banco.db.insert('users', {
        'nome': 'João',
        'email': 'j@e.com',
        'usuario': 'joaozinho',
        'senha_hash': 'x',
        'salt': 'x',
        'papel': 'aluno',
        'criado_em': DateTime.now().toIso8601String(),
        'atualizado_em': DateTime.now().toIso8601String(),
      });
      final userId = ((await banco.db.rawQuery('SELECT last_insert_rowid() as id')).first)['id'] as int;

      Future<void> inserePartida(String? eixo) async {
        await banco.db.insert('partidas', {
          'aluno_id': userId,
          'eixo': eixo,
          'pontuacao': 100,
          'streak': 1,
          'respondidas': 1,
          'acertos': 1,
          'iniciada_em': DateTime.now().toUtc().toIso8601String(),
          'terminada_em': DateTime.now().toUtc().toIso8601String(),
        });
      }

      await inserePartida('tecnologia');
      await inserePartida('cultura');
      await inserePartida('impacto');

      await tester.pumpWidget(
        MaterialApp(
          home: _RankingTestHarness(banco: banco, alunoId: userId),
        ),
      );
      await tester.pumpAndSettle();

      // Estado inicial: aba Geral (índice 0)
      print('Inicial: ${find.text('joaozinho').evaluate().length}');

      await tester.tap(find.text('Tech'));
      await tester.pumpAndSettle();
      print('Tech: ${find.text('joaozinho').evaluate().length}');

      await tester.tap(find.text('Cultura'));
      await tester.pumpAndSettle();
      print('Cultura: ${find.text('joaozinho').evaluate().length}');

      await tester.tap(find.text('Impacto'));
      await tester.pumpAndSettle();
      print('Impacto: ${find.text('joaozinho').evaluate().length}');
    },
  );
}

/// Harness simples que injeta o banco via Provider.
class _RankingTestHarness extends StatelessWidget {
  const _RankingTestHarness({required this.banco, required this.alunoId});
  final AppDatabase banco;
  final int alunoId;

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>.value(
      value: banco,
      child: RankingScreen(alunoId: alunoId),
    );
  }
}
