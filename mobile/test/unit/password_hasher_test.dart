import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';

void main() {
  // Iteracoes baixas so no teste: o custo alto nao prova nada aqui.
  const hasher = PasswordHasher(iteracoes: 1000);

  group('PasswordHasher', () {
    test('nao devolve a senha em texto puro', () {
      final cifrada = hasher.cifrar('Professor@123');

      expect(cifrada.hash, isNot(contains('Professor')));
      expect(cifrada.hash, isNotEmpty);
      expect(cifrada.salt, isNotEmpty);
    });

    test('gera salt diferente a cada chamada', () {
      final a = hasher.cifrar('Professor@123');
      final b = hasher.cifrar('Professor@123');

      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
    });

    test('confere a senha correta', () {
      final cifrada = hasher.cifrar('Professor@123');

      expect(
        hasher.confere('Professor@123', hash: cifrada.hash, salt: cifrada.salt),
        isTrue,
      );
    });

    test('recusa senha errada', () {
      final cifrada = hasher.cifrar('Professor@123');

      expect(
        hasher.confere('Professor@124', hash: cifrada.hash, salt: cifrada.salt),
        isFalse,
      );
      expect(
        hasher.confere('', hash: cifrada.hash, salt: cifrada.salt),
        isFalse,
      );
    });

    test('recusa quando o salt nao e o do hash', () {
      final a = hasher.cifrar('Professor@123');
      final b = hasher.cifrar('Professor@123');

      expect(hasher.confere('Professor@123', hash: a.hash, salt: b.salt), isFalse);
    });

    test('mesmo salt e mesma senha geram o mesmo hash', () {
      final cifrada = hasher.cifrar('Professor@123');
      final repetido = hasher.cifrarComSalt('Professor@123', cifrada.salt);

      expect(repetido.hash, cifrada.hash);
    });

    test('numero de iteracoes muda o hash', () {
      const outro = PasswordHasher(iteracoes: 2000);
      final cifrada = hasher.cifrar('Professor@123');

      expect(
        outro.confere('Professor@123', hash: cifrada.hash, salt: cifrada.salt),
        isFalse,
      );
    });

    test('preserva acento na senha', () {
      final cifrada = hasher.cifrar('senhaÇã123');

      expect(
        hasher.confere('senhaÇã123', hash: cifrada.hash, salt: cifrada.salt),
        isTrue,
      );
    });
  });
}
