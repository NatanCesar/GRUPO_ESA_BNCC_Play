import 'package:flutter/foundation.dart';

import 'package:bncc_play_mobile/core/validation/validators.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/data/errors.dart';

/// Controlador do formulario de criar/editar questao.
class QuestionFormController extends ChangeNotifier {
  QuestionFormController({
    required QuestaoRepository repository,
    required int professorId,
    Questao? questaoEdicao,
  }) : _repository = repository,
       _professorId = professorId,
       _questaoEdicao = questaoEdicao {
    if (questaoEdicao != null) {
      _enunciado = questaoEdicao.enunciado;
      _opcaoA = questaoEdicao.opcaoA;
      _opcaoB = questaoEdicao.opcaoB;
      _opcaoC = questaoEdicao.opcaoC;
      _opcaoD = questaoEdicao.opcaoD;
      _respostaCorreta = questaoEdicao.respostaCorreta;
      _eixo = questaoEdicao.eixo;
      _dificuldade = questaoEdicao.dificuldade;
      _categoria = questaoEdicao.categoria;
    }
  }

  final QuestaoRepository _repository;
  final int _professorId;
  final Questao? _questaoEdicao;
  bool get editando => _questaoEdicao != null;

  bool _salvando = false;
  bool get salvando => _salvando;

  String? _erroGeral;
  String? get erroGeral => _erroGeral;

  bool _sucesso = false;
  bool get sucesso => _sucesso;

  // Campos
  String _enunciado = '';
  String get enunciado => _enunciado;
  void setEnunciado(String v) {
    _enunciado = v;
    _erros['enunciado'] = Validators.enunciado(v);
    notifyListeners();
  }

  String _opcaoA = '';
  String get opcaoA => _opcaoA;
  void setOpcaoA(String v) {
    _opcaoA = v;
    _erros['opcaoA'] = Validators.opcaoQuestao(v);
    notifyListeners();
  }

  String _opcaoB = '';
  String get opcaoB => _opcaoB;
  void setOpcaoB(String v) {
    _opcaoB = v;
    _erros['opcaoB'] = Validators.opcaoQuestao(v);
    notifyListeners();
  }

  String _opcaoC = '';
  String get opcaoC => _opcaoC;
  void setOpcaoC(String v) {
    _opcaoC = v;
    _erros['opcaoC'] = Validators.opcaoQuestao(v);
    notifyListeners();
  }

  String _opcaoD = '';
  String get opcaoD => _opcaoD;
  void setOpcaoD(String v) {
    _opcaoD = v;
    _erros['opcaoD'] = Validators.opcaoQuestao(v);
    notifyListeners();
  }

  String? _respostaCorreta;
  String? get respostaCorreta => _respostaCorreta;
  void setRespostaCorreta(String? v) {
    _respostaCorreta = v;
    _erros['resposta'] = v == null ? 'Selecione a resposta correta' : null;
    notifyListeners();
  }

  EixoBNCC? _eixo;
  EixoBNCC? get eixo => _eixo;
  void setEixo(EixoBNCC? v) {
    _eixo = v;
    notifyListeners();
  }

  Dificuldade? _dificuldade;
  Dificuldade? get dificuldade => _dificuldade;
  void setDificuldade(Dificuldade? v) {
    _dificuldade = v;
    notifyListeners();
  }

  String _categoria = 'Geral';
  String get categoria => _categoria;
  void setCategoria(String v) {
    _categoria = v;
    _erros['categoria'] = v.trim().isEmpty ? 'Informe a categoria' : null;
    notifyListeners();
  }

  final Map<String, String?> _erros = {};
  Map<String, String?> get erros => Map.unmodifiable(_erros);

  /// Valida todos os campos antes de salvar.
  bool validar() {
    _erros['enunciado'] = Validators.enunciado(_enunciado);
    _erros['opcaoA'] = Validators.opcaoQuestao(_opcaoA);
    _erros['opcaoB'] = Validators.opcaoQuestao(_opcaoB);
    _erros['opcaoC'] = Validators.opcaoQuestao(_opcaoC);
    _erros['opcaoD'] = Validators.opcaoQuestao(_opcaoD);
    _erros['resposta'] = _respostaCorreta == null
        ? 'Selecione a resposta correta'
        : null;
    _erros['eixo'] = _eixo == null ? 'Selecione o eixo' : null;
    _erros['dificuldade'] = _dificuldade == null
        ? 'Selecione a dificuldade'
        : null;
    _erros['categoria'] = _categoria.trim().isEmpty
        ? 'Informe a categoria'
        : null;
    notifyListeners();
    return _erros.values.every((e) => e == null);
  }

  /// Salva (cria ou atualiza) a questao.
  Future<void> salvar() async {
    if (!validar()) return;

    _salvando = true;
    _erroGeral = null;
    notifyListeners();

    try {
      if (editando) {
        final atualizada = _questaoEdicao!.copiarCom(
          enunciado: _enunciado,
          opcaoA: _opcaoA,
          opcaoB: _opcaoB,
          opcaoC: _opcaoC,
          opcaoD: _opcaoD,
          respostaCorreta: _respostaCorreta!,
          eixo: _eixo!,
          dificuldade: _dificuldade!,
          categoria: _categoria,
        );
        await _repository.atualizar(atualizada);
      } else {
        await _repository.cadastrar(
          enunciado: _enunciado,
          opcaoA: _opcaoA,
          opcaoB: _opcaoB,
          opcaoC: _opcaoC,
          opcaoD: _opcaoD,
          respostaCorreta: _respostaCorreta!,
          eixo: _eixo!,
          dificuldade: _dificuldade!,
          categoria: _categoria,
          professorId: _professorId,
        );
      }
      _sucesso = true;
    } on QuestaoInvalidaException catch (e) {
      _erroGeral = e.mensagem;
    } on ErroDeDominio catch (e) {
      _erroGeral = e.mensagem;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }
}
