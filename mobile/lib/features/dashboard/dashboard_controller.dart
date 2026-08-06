import 'package:flutter/foundation.dart';

import 'package:bncc_play_mobile/data/models/estatistica.dart';
import 'package:bncc_play_mobile/data/repositories/estatistica_repository.dart';

/// Controlador do dashboard do professor.
class DashboardController extends ChangeNotifier {
  DashboardController({
    required EstatisticaRepository repository,
    required int professorId,
  }) : _repository = repository,
       _professorId = professorId;

  final EstatisticaRepository _repository;
  final int _professorId;

  EstatisticaGeral? _estatisticas;
  List<({int alunoId, String nome, int pontuacao, double taxa})>
  _melhoresAlunos = [];
  Map<String, int> _alunosPorEixo = {};
  List<EstatisticaQuestao> _questoesFaceis = [];
  List<EstatisticaQuestao> _questoesDificeis = [];
  bool _carregando = true;
  String? _erro;

  // Getters
  EstatisticaGeral? get estatisticas => _estatisticas;
  List<({int alunoId, String nome, int pontuacao, double taxa})>
  get melhoresAlunos => _melhoresAlunos;
  Map<String, int> get alunosPorEixo => _alunosPorEixo;
  List<EstatisticaQuestao> get questoesFaceis => _questoesFaceis;
  List<EstatisticaQuestao> get questoesDificeis => _questoesDificeis;
  bool get carregando => _carregando;
  String? get erro => _erro;

  /// Carrega todos os dados do dashboard.
  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.gerarEstatisticasGerais(_professorId),
        _repository.alunosComMelhorDesempenho(_professorId, limite: 10),
        _repository.contarAlunosPorEixo(_professorId),
        _repository.questoesMaisFaceis(professorId: _professorId),
        _repository.questoesMaisDificeis(professorId: _professorId),
      ]);

      _estatisticas = results[0] as EstatisticaGeral;
      _melhoresAlunos =
          results[1]
              as List<({int alunoId, String nome, int pontuacao, double taxa})>;
      _alunosPorEixo = results[2] as Map<String, int>;
      _questoesFaceis = results[3] as List<EstatisticaQuestao>;
      _questoesDificeis = results[4] as List<EstatisticaQuestao>;

      _carregando = false;
      notifyListeners();
    } catch (e) {
      _erro = e.toString();
      _carregando = false;
      notifyListeners();
    }
  }
}
