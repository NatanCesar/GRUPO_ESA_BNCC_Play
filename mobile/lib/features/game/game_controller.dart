import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/partida.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/repositories/game_repository.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';

/// Controlador do loop de jogo — estado de uma partida em andamento.
class GameController extends ChangeNotifier {
  GameController({
    required GameRepository game,
    required QuestaoRepository questoes,
    required int alunoId,
    String? eixo,
    int questoesPorPartida = 5,
    Random? random,
  })  : _game = game,
        _questoes = questoes,
        _alunoId = alunoId,
        _eixo = eixo,
        _questoesCount = questoesPorPartida,
        _random = random ?? Random();

  final GameRepository _game;
  final QuestaoRepository _questoes;
  final int _alunoId;
  final String? _eixo;
  final int _questoesCount;
  final Random _random;

  Partida? _partida;
  List<Questao> _questoesSelecionadas = [];
  int _indiceAtual = 0;
  String? _respostaSelecionada;
  bool? _acertou;
  bool _carregando = true;
  String? _erro;
  bool _finalizado = false;

  // Getters
  Partida? get partida => _partida;
  List<Questao> get questoes => _questoesSelecionadas;
  int get indiceAtual => _indiceAtual;
  int get totalQuestoes => _questoesCount;
  String? get respostaSelecionada => _respostaSelecionada;
  bool? get acertou => _acertou;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get finalizado => _finalizado;

  Questao? get questaoAtual =>
      _indiceAtual < _questoesSelecionadas.length
          ? _questoesSelecionadas[_indiceAtual]
          : null;

  int get progresso => _indiceAtual + 1;

  /// Inicia o loop de jogo: busca questoes e cria a partida.
  Future<void> iniciar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final todas = await _questoes.filtrar(
        professorId: null,
        eixo: _eixo != null ? EixoBNCC.dePersistencia(_eixo!) : null,
      );

      if (todas.isEmpty) {
        _erro = 'Nenhuma questao disponivel';
        _carregando = false;
        notifyListeners();
        return;
      }

      final embaralhada = List<Questao>.from(todas)..shuffle(_random);
      _questoesSelecionadas = embaralhada.take(_questoesCount).toList();

      _partida = await _game.iniciarPartida(_alunoId, eixo: _eixo);

      _carregando = false;
      _indiceAtual = 0;
      notifyListeners();
    } catch (e) {
      _erro = e.toString();
      _carregando = false;
      notifyListeners();
    }
  }

  /// Registra a resposta selecionada e mostra o feedback.
  Future<void> selecionarResposta(String resposta) async {
    if (_respostaSelecionada != null || _finalizado) return;

    _respostaSelecionada = resposta;
    final q = questaoAtual;
    if (q == null) return;

    _acertou = resposta == q.respostaCorreta;

    _partida = await _game.registrarResposta(
      partidaId: _partida!.id!,
      respostaAluno: resposta,
      acertou: _acertou!,
    );

    notifyListeners();
  }

  /// Avanca para a proxima questao (ou encerra se for a ultima).
  Future<void> proxima({required String apelido}) async {
    _respostaSelecionada = null;
    _acertou = null;

    if (_indiceAtual + 1 >= _questoesSelecionadas.length) {
      _partida = await _game.encerrarPartida(_partida!.id!, apelido);
      _finalizado = true;
    } else {
      _indiceAtual++;
    }

    notifyListeners();
  }

  /// Reinicia o jogo.
  void reiniciar() {
    _partida = null;
    _questoesSelecionadas = [];
    _indiceAtual = 0;
    _respostaSelecionada = null;
    _acertou = null;
    _carregando = true;
    _erro = null;
    _finalizado = false;
    iniciar();
  }
}
