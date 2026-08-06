import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/models/papel.dart';
import '../../data/errors.dart';

/// Usuario logado e prazo de inatividade.
///
/// A expiracao e calculada sobre [_ultimaAtividade] em vez de tocada por um
/// Timer: sem cronometro nao ha o que descartar, e o teste controla o
/// relogio em vez de esperar meia hora.
class SessionScope extends ChangeNotifier {
  SessionScope({DateTime Function() agora = DateTime.now}) : _agora = agora;

  static const Duration tempoDeInatividade = Duration(minutes: 30);

  final DateTime Function() _agora;

  AppUser? _usuario;
  DateTime? _ultimaAtividade;

  AppUser? get usuario => _expirou ? null : _usuario;

  Papel? get papel => usuario?.papel;

  bool get autenticado => usuario != null;

  bool get _expirou {
    final marca = _ultimaAtividade;
    if (_usuario == null || marca == null) return true;
    return _agora().difference(marca) > tempoDeInatividade;
  }

  void abrir(AppUser usuario) {
    _usuario = usuario;
    _ultimaAtividade = _agora();
    notifyListeners();
  }

  /// Renova o prazo. Chamado a cada acao que passa por um repositorio.
  void registrarAtividade() {
    if (_usuario == null) return;
    _ultimaAtividade = _agora();
  }

  void encerrar() {
    _usuario = null;
    _ultimaAtividade = null;
    notifyListeners();
  }

  /// Usuario logado, ou erro. Usar onde a tela nao faz sentido sem sessao.
  AppUser exigirUsuario() {
    final atual = usuario;
    if (atual == null) throw const SessaoExpiradaException();
    return atual;
  }
}
