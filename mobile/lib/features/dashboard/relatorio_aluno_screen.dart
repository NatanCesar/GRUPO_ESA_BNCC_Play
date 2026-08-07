import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/data/models/partida.dart';
import 'package:bncc_play_mobile/data/models/resposta.dart';
import 'package:bncc_play_mobile/data/repositories/game_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';

/// Tela de relatorio de desempenho de um aluno especifico (CT18).
class RelatorioAlunoScreen extends StatefulWidget {
  const RelatorioAlunoScreen({super.key, required this.alunoId});

  final int alunoId;

  @override
  State<RelatorioAlunoScreen> createState() => _RelatorioAlunoScreenState();
}

class _RelatorioAlunoScreenState extends State<RelatorioAlunoScreen> {
  late GameRepository _repository;
  List<Partida> _historico = [];
  List<RespostaDetalhada> _respostas = [];
  bool _carregando = true;
  bool _inicializado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    _repository = GameRepository(banco: Provider.of(context));
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    try {
      final professor = context.read<SessionScope>().usuario;
      final aluno = await context.read<UserRepository>().porId(widget.alunoId);
      if (professor == null ||
          professor.papel != Papel.professor ||
          aluno?.professorId != professor.id) {
        setState(() {
          _erro = 'Você não tem permissão para acessar este relatório.';
          _carregando = false;
        });
        return;
      }
      final resultados = await Future.wait([
        _repository.historico(widget.alunoId),
        _repository.historicoRespostas(widget.alunoId),
      ]);
      setState(() {
        _historico = resultados[0] as List<Partida>;
        _respostas = resultados[1] as List<RespostaDetalhada>;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível carregar o relatório.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        title: const Text('Relatório de Desempenho'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (_erro != null) {
      return Center(child: Text(_erro!, textAlign: TextAlign.center));
    }

    if (_historico.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma partida registrada',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Calcula stats agregados.
    final totalPartidas = _historico.length;
    final totalXp = _historico.fold<int>(0, (s, p) => s + p.pontuacao);
    final totalAcertos = _historico.fold<int>(0, (s, p) => s + p.acertos);
    final totalRespondidas = _historico.fold<int>(
      0,
      (s, p) => s + p.respondidas,
    );
    final melhorStreak = _historico.fold<int>(
      0,
      (best, p) => p.streak > best ? p.streak : best,
    );
    final taxaMedia = totalRespondidas > 0
        ? (totalAcertos / totalRespondidas) * 100
        : 0.0;

    return RefreshIndicator(
      onRefresh: _carregarHistorico,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumo geral
            _Secao(
              titulo: 'Resumo Geral',
              child: Column(
                children: [
                  _StatRow(label: 'Total de partidas', valor: '$totalPartidas'),
                  _StatRow(label: 'Total de XP', valor: '$totalXp'),
                  _StatRow(
                    label: 'Taxa de acerto média',
                    valor: '${taxaMedia.toStringAsFixed(1)}%',
                  ),
                  _StatRow(label: 'Melhor streak', valor: '$melhorStreak'),
                ],
              ),
            ),
            if (_respostas.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Secao(
                titulo: 'Respostas por questão',
                child: Column(
                  children: _respostas
                      .take(50)
                      .map((resposta) => _RespostaTile(resposta: resposta))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Historico de partidas
            _Secao(
              titulo: 'Histórico de Partidas',
              child: Column(
                children: _historico
                    .take(20)
                    .map((p) => _PartidaTile(partida: p))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RespostaTile extends StatelessWidget {
  const _RespostaTile({required this.resposta});

  final RespostaDetalhada resposta;

  @override
  Widget build(BuildContext context) {
    final cor = resposta.correta ? Colors.green : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            resposta.correta ? Icons.check_circle : Icons.cancel,
            color: cor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resposta.enunciado,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  resposta.correta
                      ? 'Resposta: ${resposta.respostaAluno}'
                      : 'Resposta: ${resposta.respostaAluno} · Correta: ${resposta.respostaCorreta}',
                  style: TextStyle(fontSize: 12, color: cor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartidaTile extends StatelessWidget {
  const _PartidaTile({required this.partida});

  final Partida partida;

  @override
  Widget build(BuildContext context) {
    final data = _formatarData(partida.terminadaEm ?? partida.iniciadaEm);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${partida.acertos}/${partida.respondidas} acertos',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${partida.pontuacao} XP',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (partida.streak > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${partida.streak}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}
