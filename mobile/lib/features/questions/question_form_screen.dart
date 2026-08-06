import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/core/widgets/gradient_header.dart';
import 'package:bncc_play_mobile/core/widgets/app_button.dart';
import 'package:bncc_play_mobile/core/widgets/app_text_field.dart';
import 'package:bncc_play_mobile/core/widgets/aviso_de_erro.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';

/// Tela de formulario para criar ou editar questao (CT06).
class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key, this.questaoId});

  final int? questaoId;

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _enunciadoController;
  late final TextEditingController _opcaoAController;
  late final TextEditingController _opcaoBController;
  late final TextEditingController _opcaoCController;
  late final TextEditingController _opcaoDController;

  String? _respostaCorreta;
  EixoBNCC? _eixo;
  Dificuldade? _dificuldade;

  Map<String, String?> _erros = {};
  bool _salvando = false;
  bool _sucesso = false;
  String? _erroGeral;
  Questao? _questaoOriginal;

  @override
  void initState() {
    super.initState();
    _enunciadoController = TextEditingController();
    _opcaoAController = TextEditingController();
    _opcaoBController = TextEditingController();
    _opcaoCController = TextEditingController();
    _opcaoDController = TextEditingController();

    if (widget.questaoId != null) {
      _carregarQuestao();
    }
  }

  @override
  void dispose() {
    _enunciadoController.dispose();
    _opcaoAController.dispose();
    _opcaoBController.dispose();
    _opcaoCController.dispose();
    _opcaoDController.dispose();
    super.dispose();
  }

  Future<void> _carregarQuestao() async {
    final repository = context.read<QuestaoRepository>();
    try {
      final questao = await repository.porId(widget.questaoId!);
      if (questao != null && mounted) {
        setState(() {
          _questaoOriginal = questao;
          _enunciadoController.text = questao.enunciado;
          _opcaoAController.text = questao.opcaoA;
          _opcaoBController.text = questao.opcaoB;
          _opcaoCController.text = questao.opcaoC;
          _opcaoDController.text = questao.opcaoD;
          _respostaCorreta = questao.respostaCorreta;
          _eixo = questao.eixo;
          _dificuldade = questao.dificuldade;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _erroGeral = 'Erro ao carregar questao');
      }
    }
  }

  Future<void> _salvar() async {
    // Validacao simples
    final erros = <String, String?>{};
    if (_enunciadoController.text.trim().isEmpty) {
      erros['enunciado'] = 'Informe o enunciado';
    }
    if (_opcaoAController.text.trim().isEmpty) {
      erros['opcaoA'] = 'Informe a opcao A';
    }
    if (_opcaoBController.text.trim().isEmpty) {
      erros['opcaoB'] = 'Informe a opcao B';
    }
    if (_opcaoCController.text.trim().isEmpty) {
      erros['opcaoC'] = 'Informe a opcao C';
    }
    if (_opcaoDController.text.trim().isEmpty) {
      erros['opcaoD'] = 'Informe a opcao D';
    }
    if (_respostaCorreta == null) {
      erros['resposta'] = 'Selecione a resposta correta';
    }
    if (_eixo == null) {
      erros['eixo'] = 'Selecione o eixo';
    }
    if (_dificuldade == null) {
      erros['dificuldade'] = 'Selecione a dificuldade';
    }

    if (erros.isNotEmpty) {
      setState(() => _erros = erros);
      return;
    }

    setState(() {
      _salvando = true;
      _erroGeral = null;
    });

    final session = context.read<SessionScope>();
    final repository = context.read<QuestaoRepository>();
    final usuario = session.usuario;

    if (usuario == null) {
      setState(() {
        _salvando = false;
        _erroGeral = 'Sessao expirada';
      });
      return;
    }

    try {
      if (_questaoOriginal != null) {
        // Editando
        final atualizada = _questaoOriginal!.copiarCom(
          enunciado: _enunciadoController.text.trim(),
          opcaoA: _opcaoAController.text.trim(),
          opcaoB: _opcaoBController.text.trim(),
          opcaoC: _opcaoCController.text.trim(),
          opcaoD: _opcaoDController.text.trim(),
          respostaCorreta: _respostaCorreta!,
          eixo: _eixo!,
          dificuldade: _dificuldade!,
        );
        await repository.atualizar(atualizada);
      } else {
        // Criando
        await repository.cadastrar(
          enunciado: _enunciadoController.text.trim(),
          opcaoA: _opcaoAController.text.trim(),
          opcaoB: _opcaoBController.text.trim(),
          opcaoC: _opcaoCController.text.trim(),
          opcaoD: _opcaoDController.text.trim(),
          respostaCorreta: _respostaCorreta!,
          eixo: _eixo!,
          dificuldade: _dificuldade!,
          professorId: usuario.id!,
        );
      }
      _sucesso = true;
    } catch (e) {
      setState(() => _erroGeral = e.toString());
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.questaoId != null;

    if (_sucesso) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: AppColors.green),
              const SizedBox(height: 24),
              Text(
                editando ? 'Questao atualizada!' : 'Questao cadastrada!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Voltar para questoes',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeader(
            gradient: AppColors.purpleHeaderGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editando ? 'Editar Questao' : 'Nova Questao',
                  style: AppTheme.headerTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  editando ? 'Altere os dados' : 'Cadastre uma questao',
                  style: AppTheme.headerSubtitle,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_erroGeral != null) ...[
                      AvisoDeErro(mensagem: _erroGeral!),
                      const SizedBox(height: 16),
                    ],

                    // Enunciado
                    AppTextField(
                      controller: _enunciadoController,
                      label: 'Enunciado',
                      hint: 'Digite a pergunta da questao',
                      errorText: _erros['enunciado'],
                    ),
                    const SizedBox(height: 20),

                    // Opcoes
                    const Text(
                      'Alternativas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _OpcaoField(
                      letra: 'A',
                      controller: _opcaoAController,
                      error: _erros['opcaoA'],
                      correta: _respostaCorreta == 'A',
                      onCorretaChanged: () => setState(() => _respostaCorreta = 'A'),
                    ),
                    const SizedBox(height: 12),
                    _OpcaoField(
                      letra: 'B',
                      controller: _opcaoBController,
                      error: _erros['opcaoB'],
                      correta: _respostaCorreta == 'B',
                      onCorretaChanged: () => setState(() => _respostaCorreta = 'B'),
                    ),
                    const SizedBox(height: 12),
                    _OpcaoField(
                      letra: 'C',
                      controller: _opcaoCController,
                      error: _erros['opcaoC'],
                      correta: _respostaCorreta == 'C',
                      onCorretaChanged: () => setState(() => _respostaCorreta = 'C'),
                    ),
                    const SizedBox(height: 12),
                    _OpcaoField(
                      letra: 'D',
                      controller: _opcaoDController,
                      error: _erros['opcaoD'],
                      correta: _respostaCorreta == 'D',
                      onCorretaChanged: () => setState(() => _respostaCorreta = 'D'),
                    ),
                    if (_erros['resposta'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _erros['resposta']!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Eixo
                    const Text(
                      'Eixo BNCC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final eixo in EixoBNCC.values)
                          _SelecaoChip(
                            label: eixo.rotulo,
                            icone: _iconeEixo(eixo),
                            selected: _eixo == eixo,
                            onTap: () => setState(() => _eixo = eixo),
                          ),
                      ],
                    ),
                    if (_erros['eixo'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _erros['eixo']!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Dificuldade
                    const Text(
                      'Dificuldade',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final dif in Dificuldade.values) ...[
                          Expanded(
                            child: _DificuldadeCard(
                              dificuldade: dif,
                              selected: _dificuldade == dif,
                              onTap: () => setState(() => _dificuldade = dif),
                            ),
                          ),
                          if (dif != Dificuldade.values.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    if (_erros['dificuldade'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _erros['dificuldade']!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Botao salvar
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: editando ? 'Salvar Alteracoes' : 'Cadastrar Questao',
                        onPressed: _salvando ? null : _salvar,
                        loading: _salvando,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _iconeEixo(EixoBNCC eixo) {
    switch (eixo) {
      case EixoBNCC.tecnologia:
        return '💻';
      case EixoBNCC.culturaDigital:
        return '🌐';
      case EixoBNCC.impacto:
        return '⚖️';
    }
  }
}

class _OpcaoField extends StatelessWidget {
  const _OpcaoField({
    required this.letra,
    required this.controller,
    required this.error,
    required this.correta,
    required this.onCorretaChanged,
  });

  final String letra;
  final TextEditingController controller;
  final String? error;
  final bool correta;
  final VoidCallback onCorretaChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onCorretaChanged,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: correta ? AppColors.green : Colors.transparent,
              border: Border.all(
                color: correta ? AppColors.green : AppColors.divider,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letra,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: correta ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextField(
            controller: controller,
            label: 'Opcao $letra',
            hint: 'Alternativa $letra',
            errorText: error,
          ),
        ),
      ],
    );
  }
}

class _SelecaoChip extends StatelessWidget {
  const _SelecaoChip({
    required this.label,
    required this.icone,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icone, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DificuldadeCard extends StatelessWidget {
  const _DificuldadeCard({
    required this.dificuldade,
    required this.selected,
    required this.onTap,
  });

  final Dificuldade dificuldade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _corDificuldade() : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _corDificuldade() : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              _iconeDificuldade(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              dificuldade.rotulo,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _corDificuldade() {
    switch (dificuldade) {
      case Dificuldade.facil:
        return AppColors.green;
      case Dificuldade.medio:
        return Colors.orange;
      case Dificuldade.dificil:
        return AppColors.danger;
    }
  }

  String _iconeDificuldade() {
    switch (dificuldade) {
      case Dificuldade.facil:
        return '😊';
      case Dificuldade.medio:
        return '😐';
      case Dificuldade.dificil:
        return '😰';
    }
  }
}
