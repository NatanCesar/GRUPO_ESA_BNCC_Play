import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/widgets/alternativa_button.dart';
import 'package:bncc_play_mobile/data/repositories/game_repository.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';
import 'package:bncc_play_mobile/features/game/game_controller.dart';

/// Tela de jogo: loop de questão com feedback visual imediato.
class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.alunoId,
    required this.apelido,
    this.eixo,
  });

  final int alunoId;
  final String apelido;
  final String? eixo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(
        game: GameRepository(banco: Provider.of(context)),
        questoes: QuestaoRepository(banco: Provider.of(context)),
        alunoId: alunoId,
        eixo: eixo,
      )..iniciar(),
      child: _GameScreenBody(apelido: apelido),
    );
  }
}

class _GameScreenBody extends StatelessWidget {
  const _GameScreenBody({required this.apelido});

  final String apelido;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        title: const Text('BNCC Play'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (ctrl.partida != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${ctrl.partida!.pontuacao} XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(context, ctrl),
    );
  }

  Widget _buildBody(BuildContext context, GameController ctrl) {
    if (ctrl.carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (ctrl.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                ctrl.erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    if (ctrl.finalizado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          Rotas.resultado,
          arguments: {'partida': ctrl.partida, 'apelido': apelido},
        );
      });
      return const Center(child: CircularProgressIndicator());
    }

    final q = ctrl.questaoAtual;
    if (q == null) return const SizedBox.shrink();

    return _QuestaoCard(ctrl: ctrl, questao: q, apelido: apelido);
  }
}

class _QuestaoCard extends StatelessWidget {
  const _QuestaoCard({
    required this.ctrl,
    required this.questao,
    required this.apelido,
  });

  final GameController ctrl;
  final dynamic questao;
  final String apelido;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progresso e streak
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ctrl.progresso / ctrl.totalQuestoes,
                    backgroundColor: AppColors.purple.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.purple,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${ctrl.progresso}/${ctrl.totalQuestoes}',
                style: TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (ctrl.partida!.streak >= 3) ...[
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 18,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ctrl.partida!.streak}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Enunciado
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              questao.enunciado,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Alternativas
          for (final (letra, texto) in [
            ('A', questao.opcaoA),
            ('B', questao.opcaoB),
            ('C', questao.opcaoC),
            ('D', questao.opcaoD),
          ])
            _buildAlternativa(context, letra, texto),
        ],
      ),
    );
  }

  Widget _buildAlternativa(BuildContext context, String letra, String texto) {
    final selecionada = ctrl.respostaSelecionada;
    final correta = questao.respostaCorreta;

    AlternativaEstado estado = AlternativaEstado.normal;
    if (selecionada != null) {
      if (letra == correta) {
        estado = AlternativaEstado.correta;
      } else if (letra == selecionada && letra != correta) {
        estado = AlternativaEstado.errada;
      }
    }

    return AlternativaButton(
      letra: letra,
      texto: texto,
      estado: estado,
      onTap: () => _responder(context, letra),
    );
  }

  void _responder(BuildContext context, String resposta) async {
    await ctrl.selecionarResposta(resposta);

    // Espera 1.5s para mostrar feedback.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (context.mounted) {
      await ctrl.proxima(apelido: apelido);
    }
  }
}
