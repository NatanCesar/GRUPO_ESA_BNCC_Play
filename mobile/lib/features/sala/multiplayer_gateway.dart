import 'dart:async';

import 'package:flutter/foundation.dart';

enum EstadoSala { aguardando, jogando, finalizada }

class JogadorSala {
  const JogadorSala({
    required this.id,
    required this.nome,
    required this.pronto,
    this.pontuacao = 0,
    this.local = false,
  });

  final String id;
  final String nome;
  final bool pronto;
  final int pontuacao;
  final bool local;

  JogadorSala copiarCom({bool? pronto, int? pontuacao}) {
    return JogadorSala(
      id: id,
      nome: nome,
      pronto: pronto ?? this.pronto,
      pontuacao: pontuacao ?? this.pontuacao,
      local: local,
    );
  }
}

abstract class MultiplayerGateway extends ChangeNotifier {
  String get codigo;
  EstadoSala get estado;
  List<JogadorSala> get jogadores;
  int get rodada;
  int get totalRodadas;

  void abrirSala(String apelido);
  void alternarPronto();
  void iniciarPartida();
  void reiniciar();
}

class FakeMultiplayerGateway extends MultiplayerGateway {
  FakeMultiplayerGateway({this.intervalo = const Duration(milliseconds: 700)});

  final Duration intervalo;
  final List<Timer> _timers = [];
  final List<JogadorSala> _jogadores = [];
  EstadoSala _estado = EstadoSala.aguardando;
  int _rodada = 0;

  @override
  String get codigo => 'BNCC-2026';

  @override
  EstadoSala get estado => _estado;

  @override
  List<JogadorSala> get jogadores => List.unmodifiable(_jogadores);

  @override
  int get rodada => _rodada;

  @override
  int get totalRodadas => 5;

  @override
  void abrirSala(String apelido) {
    _cancelarTimers();
    _estado = EstadoSala.aguardando;
    _rodada = 0;
    _jogadores
      ..clear()
      ..add(
        JogadorSala(id: 'local', nome: apelido, pronto: false, local: true),
      );
    notifyListeners();

    const bots = ['Lia.dev', 'RafaCode', 'BiaTech'];
    for (var i = 0; i < bots.length; i++) {
      _timers.add(
        Timer(intervalo * (i + 1), () {
          _jogadores.add(
            JogadorSala(id: 'bot-$i', nome: bots[i], pronto: true),
          );
          notifyListeners();
        }),
      );
    }
  }

  @override
  void alternarPronto() {
    if (_estado != EstadoSala.aguardando) return;
    final indice = _jogadores.indexWhere((jogador) => jogador.local);
    if (indice < 0) return;
    _jogadores[indice] = _jogadores[indice].copiarCom(
      pronto: !_jogadores[indice].pronto,
    );
    notifyListeners();
  }

  @override
  void iniciarPartida() {
    JogadorSala? local;
    for (final jogador in _jogadores) {
      if (jogador.local) {
        local = jogador;
        break;
      }
    }
    if (_estado != EstadoSala.aguardando ||
        local?.pronto != true ||
        _jogadores.length < 2) {
      return;
    }
    _cancelarTimers();
    _estado = EstadoSala.jogando;
    _rodada = 0;
    notifyListeners();

    for (var rodada = 1; rodada <= totalRodadas; rodada++) {
      _timers.add(
        Timer(intervalo * rodada, () {
          _rodada = rodada;
          for (var i = 0; i < _jogadores.length; i++) {
            final ganho = 70 + ((rodada * 31 + i * 47) % 61);
            _jogadores[i] = _jogadores[i].copiarCom(
              pontuacao: _jogadores[i].pontuacao + ganho,
            );
          }
          if (rodada == totalRodadas) {
            _estado = EstadoSala.finalizada;
            _jogadores.sort((a, b) => b.pontuacao.compareTo(a.pontuacao));
          }
          notifyListeners();
        }),
      );
    }
  }

  @override
  void reiniciar() {
    String? apelido;
    for (final jogador in _jogadores) {
      if (jogador.local) {
        apelido = jogador.nome;
        break;
      }
    }
    abrirSala(apelido ?? 'Você');
  }

  void _cancelarTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    _cancelarTimers();
    super.dispose();
  }
}
