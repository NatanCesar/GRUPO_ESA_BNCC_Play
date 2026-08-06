import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/widgets/app_button.dart';

import 'multiplayer_gateway.dart';

class SalaScreen extends StatefulWidget {
  const SalaScreen({super.key, this.gateway});

  final MultiplayerGateway? gateway;

  @override
  State<SalaScreen> createState() => _SalaScreenState();
}

class _SalaScreenState extends State<SalaScreen> {
  late final MultiplayerGateway _gateway;
  late final bool _gerenciaGateway;

  @override
  void initState() {
    super.initState();
    _gerenciaGateway = widget.gateway == null;
    _gateway = widget.gateway ?? FakeMultiplayerGateway();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apelido =
          context.read<SessionScope>().usuario?.usuario ?? 'Jogador';
      _gateway.abrirSala(apelido);
    });
  }

  @override
  void dispose() {
    if (_gerenciaGateway) _gateway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gateway,
      builder: (context, _) {
        final local = _jogadorLocal;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            title: const Text('Sala Multiplayer'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    _rotuloEstado,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _CabecalhoSala(
                  codigo: _gateway.codigo,
                  jogadores: _gateway.jogadores.length,
                ),
                if (_gateway.estado == EstadoSala.jogando) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _gateway.rodada / _gateway.totalRodadas,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rodada ${_gateway.rodada} de ${_gateway.totalRodadas}',
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  _gateway.estado == EstadoSala.finalizada
                      ? 'Classificação final'
                      : 'Jogadores',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < _gateway.jogadores.length; i++)
                  _JogadorTile(
                    jogador: _gateway.jogadores[i],
                    posicao: _gateway.estado == EstadoSala.finalizada
                        ? i + 1
                        : null,
                  ),
                const SizedBox(height: 24),
                if (_gateway.estado == EstadoSala.aguardando) ...[
                  OutlinedButton.icon(
                    onPressed: _gateway.alternarPronto,
                    icon: Icon(
                      local?.pronto == true
                          ? Icons.check_circle
                          : Icons.hourglass_empty,
                    ),
                    label: Text(
                      local?.pronto == true ? 'Pronto' : 'Ficar pronto',
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Iniciar Partida',
                    icon: Icons.play_arrow,
                    onPressed:
                        local?.pronto == true && _gateway.jogadores.length >= 2
                        ? _gateway.iniciarPartida
                        : null,
                  ),
                ] else if (_gateway.estado == EstadoSala.finalizada)
                  AppButton(
                    label: 'Nova Simulação',
                    icon: Icons.refresh,
                    onPressed: _gateway.reiniciar,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  JogadorSala? get _jogadorLocal {
    for (final jogador in _gateway.jogadores) {
      if (jogador.local) return jogador;
    }
    return null;
  }

  String get _rotuloEstado {
    switch (_gateway.estado) {
      case EstadoSala.aguardando:
        return 'Aguardando';
      case EstadoSala.jogando:
        return 'Jogando';
      case EstadoSala.finalizada:
        return 'Finalizada';
    }
  }
}

class _CabecalhoSala extends StatelessWidget {
  const _CabecalhoSala({required this.codigo, required this.jogadores});

  final String codigo;
  final int jogadores;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  codigo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$jogadores participantes · Simulação local',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JogadorTile extends StatelessWidget {
  const _JogadorTile({required this.jogador, this.posicao});

  final JogadorSala jogador;
  final int? posicao;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: jogador.local ? AppColors.purpleLight : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: jogador.local ? Border.all(color: AppColors.purple) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: posicao == null
                ? Icon(
                    jogador.pronto ? Icons.check_circle : Icons.schedule,
                    color: jogador.pronto ? Colors.green : AppColors.textMuted,
                  )
                : Text(
                    '#$posicao',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              jogador.local ? '${jogador.nome} (você)' : jogador.nome,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${jogador.pontuacao} XP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
