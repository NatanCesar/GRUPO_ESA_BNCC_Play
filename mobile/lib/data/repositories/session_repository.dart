import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/repositories/erros.dart';

/// Sessao ativa do app.
///
/// [token] e a chave da sessao, gerada como HMAC-SHA256(id || papel) para
/// nao precisar de estado global alem do banco.
class Sessao {
  const Sessao({
    required this.token,
    required this.usuarioId,
    required this.papel,
    required this.criadoEm,
    required this.expiraEm,
  });

  final String token;
  final int usuarioId;
  final String papel;
  final DateTime criadoEm;
  final DateTime expiraEm;

  bool get expirou => DateTime.now().toUtc().isAfter(expiraEm);
}

abstract final class SessionRepository {
  SessionRepository._();

  static final Map<int, _SessaoMemoria> _memoria = {};

  /// Abre uma sessao para [usuarioId] com [papel] e devolve o token.
  static Future<Sessao> abrir({
    required AppDatabase banco,
    required int usuarioId,
    required String papel,
    Duration duracao = const Duration(hours: 24),
  }) async {
    final agora = DateTime.now().toUtc();
    final expiraEm = agora.add(duracao);

    final token = _gerarToken(usuarioId, papel, agora);

    _memoria[usuarioId] = _SessaoMemoria(
      token: token,
      papel: papel,
      criadoEm: agora,
      expiraEm: expiraEm,
    );

    return Sessao(
      token: token,
      usuarioId: usuarioId,
      papel: papel,
      criadoEm: agora,
      expiraEm: expiraEm,
    );
  }

  /// Valida [token] para [usuarioId].
  /// Lanca [SessaoExpiradaException] se expirou.
  /// Devolve a sessao se valida.
  static Future<Sessao> validar({
    required AppDatabase banco,
    required int usuarioId,
    required String token,
  }) async {
    final memoria = _memoria[usuarioId];

    if (memoria == null || memoria.token != token) {
      throw const SessaoExpiradaException();
    }

    final sessao = Sessao(
      token: memoria.token,
      usuarioId: usuarioId,
      papel: memoria.papel,
      criadoEm: memoria.criadoEm,
      expiraEm: memoria.expiraEm,
    );

    if (sessao.expirou) {
      _memoria.remove(usuarioId);
      throw const SessaoExpiradaException();
    }

    return sessao;
  }

  /// Encerra a sessao de [usuarioId].
  static Future<void> fechar({
    required AppDatabase banco,
    required int usuarioId,
  }) async {
    _memoria.remove(usuarioId);
  }

  /// Token: HMAC-SHA256 de (usuarioId papel criadoEm) em base64url.
  static String _gerarToken(int usuarioId, String papel, DateTime momento) {
    final dados = '$usuarioId|$papel|${momento.toIso8601String()}';
    final hmac = Hmac(sha256, utf8.encode(dados));
    final bytes = hmac.convert(utf8.encode(dados)).bytes;
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

class _SessaoMemoria {
  const _SessaoMemoria({
    required this.token,
    required this.papel,
    required this.criadoEm,
    required this.expiraEm,
  });
  final String token;
  final String papel;
  final DateTime criadoEm;
  final DateTime expiraEm;
}
