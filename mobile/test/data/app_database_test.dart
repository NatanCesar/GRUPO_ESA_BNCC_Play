import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;

  setUp(() async => banco = await abrirBancoDeTeste());
  tearDown(() async => banco.fechar());

  group('AppDatabase', () {
    test('abre na versao atual', () async {
      final version = (await banco.db.rawQuery('PRAGMA user_version'))
          .first
          .values
          .first as int;
      expect(version, AppDatabase.versaoAtual);
    });

    test('cria as tabelas do ciclo 1', () async {
      final tabelas = await banco.db.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );
      final nomes = tabelas.map((t) => t['name']).toList();

      expect(nomes, contains('users'));
      expect(nomes, contains('login_attempts'));
    });

    test('recusa papel fora de professor e aluno', () async {
      expect(
        () => banco.db.insert('users', {
          'nome': 'Fulano',
          'email': 'fulano@x.com',
          'usuario': 'fulano',
          'senha_hash': 'h',
          'salt': 's',
          'papel': 'admin',
          'criado_em': '2026-07-31T12:00:00.000Z',
          'atualizado_em': '2026-07-31T12:00:00.000Z',
        }),
        throwsA(anything),
      );
    });

    test('recusa e-mail repetido', () async {
      Map<String, Object?> linha(String usuario) => {
            'nome': 'Fulano',
            'email': 'fulano@x.com',
            'usuario': usuario,
            'senha_hash': 'h',
            'salt': 's',
            'papel': 'aluno',
            'criado_em': '2026-07-31T12:00:00.000Z',
            'atualizado_em': '2026-07-31T12:00:00.000Z',
          };

      await banco.db.insert('users', linha('fulano'));

      expect(() => banco.db.insert('users', linha('outro')), throwsA(anything));
    });

    test('recusa nome de usuario repetido', () async {
      Map<String, Object?> linha(String email) => {
            'nome': 'Fulano',
            'email': email,
            'usuario': 'fulano',
            'senha_hash': 'h',
            'salt': 's',
            'papel': 'aluno',
            'criado_em': '2026-07-31T12:00:00.000Z',
            'atualizado_em': '2026-07-31T12:00:00.000Z',
          };

      await banco.db.insert('users', linha('a@x.com'));

      expect(() => banco.db.insert('users', linha('b@x.com')), throwsA(anything));
    });
  });
}
