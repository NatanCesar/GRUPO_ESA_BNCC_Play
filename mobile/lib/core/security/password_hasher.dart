import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Senha cifrada pronta para gravar: os dois campos vao em base64.
class SenhaCifrada {
  const SenhaCifrada({required this.hash, required this.salt});

  final String hash;
  final String salt;
}

/// PBKDF2-HMAC-SHA256 sobre o pacote crypto, que oferece o HMAC mas nao o
/// PBKDF2. A derivacao e curta o bastante para viver aqui sem outra
/// dependencia nativa.
class PasswordHasher {
  const PasswordHasher({this.iteracoes = 100000});

  /// Custo da derivacao. O app usa o padrao; os testes baixam para nao
  /// pagar 100 mil rodadas em cada caso.
  final int iteracoes;

  static const _bytesDeSalt = 16;
  static const _bytesDeChave = 32;

  SenhaCifrada cifrar(String senha) =>
      cifrarComSalt(senha, _novoSalt());

  SenhaCifrada cifrarComSalt(String senha, String salt) {
    final derivada = _pbkdf2(
      utf8.encode(senha),
      base64Decode(salt),
    );
    return SenhaCifrada(hash: base64Encode(derivada), salt: salt);
  }

  bool confere(String senha, {required String hash, required String salt}) {
    late final Uint8List esperado;
    try {
      esperado = base64Decode(hash);
    } on FormatException {
      return false;
    }
    final obtido = base64Decode(cifrarComSalt(senha, salt).hash);
    return _iguaisEmTempoConstante(esperado, obtido);
  }

  String _novoSalt() {
    final rnd = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(_bytesDeSalt, (_) => rnd.nextInt(256)),
    );
    return base64Encode(bytes);
  }

  Uint8List _pbkdf2(List<int> senha, List<int> salt) {
    final hmac = Hmac(sha256, senha);
    final saida = BytesBuilder();
    var bloco = 1;

    while (saida.length < _bytesDeChave) {
      // U1 = HMAC(senha, salt || INT_32_BE(bloco))
      final entrada = <int>[
        ...salt,
        (bloco >> 24) & 0xff,
        (bloco >> 16) & 0xff,
        (bloco >> 8) & 0xff,
        bloco & 0xff,
      ];
      var u = Uint8List.fromList(hmac.convert(entrada).bytes);
      final acumulado = Uint8List.fromList(u);

      for (var i = 1; i < iteracoes; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < acumulado.length; j++) {
          acumulado[j] ^= u[j];
        }
      }

      saida.add(acumulado);
      bloco++;
    }

    return Uint8List.fromList(saida.toBytes().sublist(0, _bytesDeChave));
  }

  /// Comparacao sem saida antecipada, para o tempo de resposta nao vazar
  /// quantos bytes iniciais bateram.
  bool _iguaisEmTempoConstante(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diferenca = 0;
    for (var i = 0; i < a.length; i++) {
      diferenca |= a[i] ^ b[i];
    }
    return diferenca == 0;
  }
}
