import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/core/widgets/gradient_header.dart';
import 'package:bncc_play_mobile/core/widgets/aviso_de_erro.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';

/// Tela de listagem de questoes com filtros (CT08, CT12).
class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<Questao> _questoes = [];
  bool _carregando = true;
  String? _erro;
  EixoBNCC? _eixoFiltro;
  Dificuldade? _dificuldadeFiltro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final session = context.read<SessionScope>();
    final usuario = session.usuario;
    if (usuario == null) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final repository = context.read<QuestaoRepository>();
      final questoes = await repository.filtrar(
        professorId: usuario.id!,
        eixo: _eixoFiltro,
        dificuldade: _dificuldadeFiltro,
      );
      if (mounted) {
        setState(() {
          _questoes = questoes;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Erro ao carregar questoes';
          _carregando = false;
        });
      }
    }
  }

  Future<void> _remover(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Questao'),
        content: const Text('Tem certeza que deseja remover esta questao?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      final repository = context.read<QuestaoRepository>();
      try {
        await repository.remover(id);
        _carregar();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao remover questao')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eixo = ModalRoute.of(context)!.settings.arguments as EixoBNCC?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeader(
            gradient: AppColors.purpleHeaderGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eixo?.rotulo ?? 'Questoes', style: AppTheme.headerTitle),
                const SizedBox(height: 4),
                Text(_eixoFiltro?.rotulo ?? 'Todas', style: AppTheme.headerSubtitle),
              ],
            ),
          ),
          _FiltrosBar(
            dificuldadeFiltro: _dificuldadeFiltro,
            onDificuldadeChanged: (d) {
              setState(() => _dificuldadeFiltro = d);
              _carregar();
            },
            onLimpar: () {
              setState(() => _dificuldadeFiltro = null);
              _carregar();
            },
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, Rotas.questionCreate);
          _carregar();
        },
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Questao', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildContent() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(child: AvisoDeErro(mensagem: _erro!));
    }

    if (_questoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma questao encontrada',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre sua primeira questao!',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _questoes.length,
        itemBuilder: (ctx, i) => _QuestaoCard(
          questao: _questoes[i],
          onEdit: () async {
            await Navigator.pushNamed(
              context,
              Rotas.questionEdit,
              arguments: _questoes[i].id,
            );
            _carregar();
          },
          onDelete: () => _remover(_questoes[i].id!),
        ),
      ),
    );
  }
}

class _FiltrosBar extends StatelessWidget {
  const _FiltrosBar({
    required this.dificuldadeFiltro,
    required this.onDificuldadeChanged,
    required this.onLimpar,
  });

  final Dificuldade? dificuldadeFiltro;
  final void Function(Dificuldade?) onDificuldadeChanged;
  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text('Dificuldade:', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final dif in Dificuldade.values) ...[
                    _FiltroChip(
                      label: dif.rotulo,
                      selected: dificuldadeFiltro == dif,
                      onTap: () => onDificuldadeChanged(
                        dificuldadeFiltro == dif ? null : dif,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          if (dificuldadeFiltro != null)
            IconButton(
              onPressed: onLimpar,
              icon: const Icon(Icons.clear, size: 20),
              color: AppColors.textMuted,
            ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple : AppColors.purpleLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : AppColors.purple,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _QuestaoCard extends StatelessWidget {
  const _QuestaoCard({
    required this.questao,
    required this.onEdit,
    required this.onDelete,
  });

  final Questao questao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _corDificuldade(questao.dificuldade),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    questao.dificuldade.rotulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.purple,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.danger,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              questao.enunciado,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _OpcaoLetra(letra: 'A', texto: questao.opcaoA, correta: questao.respostaCorreta == 'A'),
                const SizedBox(width: 8),
                _OpcaoLetra(letra: 'B', texto: questao.opcaoB, correta: questao.respostaCorreta == 'B'),
                const SizedBox(width: 8),
                _OpcaoLetra(letra: 'C', texto: questao.opcaoC, correta: questao.respostaCorreta == 'C'),
                const SizedBox(width: 8),
                _OpcaoLetra(letra: 'D', texto: questao.opcaoD, correta: questao.respostaCorreta == 'D'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _corDificuldade(Dificuldade dif) {
    switch (dif) {
      case Dificuldade.facil:
        return AppColors.green;
      case Dificuldade.medio:
        return Colors.orange;
      case Dificuldade.dificil:
        return AppColors.danger;
    }
  }
}

class _OpcaoLetra extends StatelessWidget {
  const _OpcaoLetra({
    required this.letra,
    required this.texto,
    required this.correta,
  });

  final String letra;
  final String texto;
  final bool correta;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: correta ? AppColors.greenLight : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: correta ? Border.all(color: AppColors.green, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$letra)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: correta ? AppColors.green : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 10,
                  color: correta ? AppColors.green : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (correta) ...[
              const SizedBox(width: 2),
              const Icon(Icons.check, size: 10, color: AppColors.green),
            ],
          ],
        ),
      ),
    );
  }
}
