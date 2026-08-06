import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/errors.dart';
import 'package:bncc_play_mobile/data/repositories/session_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;

  setUp(() async => banco = await abrirBancoDeTeste());
  tearDown(() async => banco.fechar());

  group('SessionRepository', () {
    test('devolve token unico por sessao', () async {
      final a = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 1,
        papel: 'professor',
      );
      final b = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 2,
        papel: 'professor',
      );

      expect(a.token, isNot(b.token));
    });

    test('o mesmo usuario em momentos diferentes tem tokens diferentes', () async {
      final a = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 1,
        papel: 'professor',
      );
      final b = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 1,
        papel: 'professor',
      );

      expect(a.token, isNot(b.token));
    });

    test('validar devolve a sessao se o token bate', () async {
      final sessao = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 5,
        papel: 'aluno',
      );

      final validada = await SessionRepository.validar(
        banco: banco,
        usuarioId: 5,
        token: sessao.token,
      );

      expect(validada.papel, 'aluno');
      expect(validada.usuarioId, 5);
    });

    test('validar lana SessaoExpiradaException para token invalido', () async {
      expect(
        () => SessionRepository.validar(
          banco: banco,
          usuarioId: 99,
          token: 'token_invalido',
        ),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });

    test('validar lana SessaoExpiradaException para usuario sem sessao', () async {
      expect(
        () => SessionRepository.validar(
          banco: banco,
          usuarioId: 99,
          token: 'qualquer_token',
        ),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });

    test('fechar remove a sessao', () async {
      final sessao = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 7,
        papel: 'professor',
      );

      await SessionRepository.fechar(banco: banco, usuarioId: 7);

      expect(
        () => SessionRepository.validar(
          banco: banco,
          usuarioId: 7,
          token: sessao.token,
        ),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });

    test('expirou devolve true depois do tempo', () async {
      final sessao = await SessionRepository.abrir(
        banco: banco,
        usuarioId: 8,
        papel: 'professor',
        duracao: const Duration(milliseconds: 1),
      );

      await Future.delayed(const Duration(milliseconds: 5));

      expect(sessao.expirou, isTrue);
    });
  });
}
