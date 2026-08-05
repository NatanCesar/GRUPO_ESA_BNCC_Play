import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/validation/sanitizer.dart';

void main() {
  group('Sanitizer.limpar', () {
    test('devolve texto comum sem mudanca', () {
      expect(Sanitizer.limpar('Maria Silva'), 'Maria Silva');
    });

    test('devolve string vazia para nulo', () {
      expect(Sanitizer.limpar(null), '');
    });

    test('remove tag html simples', () {
      expect(Sanitizer.limpar('O que e <b>algoritmo</b>?'), 'O que e algoritmo?');
    });

    test('remove bloco script inteiro, conteudo junto', () {
      expect(
        Sanitizer.limpar('Ola<script>alert("xss")</script>mundo'),
        'Olamundo',
      );
    });

    test('remove script com atributo e caixa alta', () {
      expect(
        Sanitizer.limpar('<SCRIPT SRC="http://x.com/a.js">roubar()</SCRIPT>fim'),
        'fim',
      );
    });

    test('remove tag mesmo sem fechamento', () {
      expect(Sanitizer.limpar('texto <img src=x onerror=alert(1)'), 'texto');
    });

    test('nao deixa entidade html virar tag depois', () {
      // Entidades HTML viram caractere (`&lt;` → `<`, `&gt;` → `>`).
      // Apos isso, o bloco `<script>alert(1)</script>` e removido inteiro,
      // com o conteudo junto — como qualquer script real seria.
      expect(Sanitizer.limpar('&lt;script&gt;alert(1)&lt;/script&gt;'), '');
    });

    test('normaliza espaco repetido e quebra de linha', () {
      expect(Sanitizer.limpar('Maria   \n\n  Silva'), 'Maria Silva');
    });

    test('apara espaco das pontas', () {
      expect(Sanitizer.limpar('   Ana   '), 'Ana');
    });

    test('corta no maxLength depois de limpar', () {
      expect(Sanitizer.limpar('a' * 300), 'a' * 200);
      expect(Sanitizer.limpar('abcdef', maxLength: 3), 'abc');
    });

    test('preserva acento e cedilha', () {
      expect(Sanitizer.limpar('João Conceição'), 'João Conceição');
    });
  });
}
