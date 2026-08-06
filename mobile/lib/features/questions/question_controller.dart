import 'package:flutter/foundation.dart';

import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/data/errors.dart';

/// Controlador para CRUD de questoes.
class QuestionController extends ChangeNotifier {
  QuestionController({required QuestaoRepository repository})
      : _repository = repository;

  final QuestaoRepository _repository;

  List<Questao> _questoes = [];
  List<Questao> get questoes => _questoes;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erroGeral;
  String? get erroGeral => _erroGeral;

  EixoBNCC? _filtroEixo;
  EixoBNCC? get filtroEixo => _filtroEixo;

  Dificuldade? _filtroDificuldade;
  Dificuldade? get filtroDificuldade => _filtroDificuldade;

  Map<EixoBNCC, int> _contagemPorEixo = {};
  Map<EixoBNCC, int> get contagemPorEixo => _contagemPorEixo;

  /// Carrega questoes do professor com filtros atuais.
  Future<void> carregarQuestoes(int professorId) async {
    _carregando = true;
    _erroGeral = null;
    notifyListeners();

    try {
      _questoes = await _repository.filtrar(
        professorId: professorId,
        eixo: _filtroEixo,
        dificuldade: _filtroDificuldade,
      );
    } on ErroDeDominio catch (e) {
      _erroGeral = e.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Carrega contagem de questoes por eixo.
  Future<void> carregarContagem(int professorId) async {
    try {
      _contagemPorEixo = await _repository.contarPorEixo(professorId);
      notifyListeners();
    } catch (_) {
      // Contagem e opcional, nao bloqueia.
    }
  }

  /// Define filtro por eixo.
  void setFiltroEixo(EixoBNCC? eixo) {
    _filtroEixo = eixo;
    notifyListeners();
  }

  /// Define filtro por dificuldade.
  void setFiltroDificuldade(Dificuldade? dificuldade) {
    _filtroDificuldade = dificuldade;
    notifyListeners();
  }

  /// Limpa todos os filtros.
  void limparFiltros() {
    _filtroEixo = null;
    _filtroDificuldade = null;
    notifyListeners();
  }

  /// Remove uma questao.
  Future<bool> removerQuestao(int id, int professorId) async {
    try {
      await _repository.remover(id);
      await carregarQuestoes(professorId);
      return true;
    } on ErroDeDominio catch (e) {
      _erroGeral = e.mensagem;
      notifyListeners();
      return false;
    }
  }

  /// Busca uma questao por id.
  Future<Questao?> buscarQuestao(int id) async {
    return _repository.porId(id);
  }
}
