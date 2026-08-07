import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/widgets/app_button.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/partida.dart';
import 'package:bncc_play_mobile/data/repositories/ranking_repository.dart';

/// Tela de resultado apos uma partida.
class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({
    super.key,
    required this.partida,
    required this.apelido,
    this.carregarPosicao,
  });

  final Partida partida;
  final String apelido;
  final Future<int?> Function(int alunoId)? carregarPosicao;

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  int? _posicao;

  @override
  void initState() {
    super.initState();
    _carregarPosicao();
  }

  Future<void> _carregarPosicao() async {
    final loader = widget.carregarPosicao;
    final pos = loader != null
        ? await loader(widget.partida.alunoId)
        : await RankingRepository(
            banco: Provider.of<AppDatabase>(context, listen: false),
          ).posicaoOrdinal(widget.partida.alunoId);
    if (mounted) {
      setState(() => _posicao = pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.partida;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.purple),
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 16),

              // Icone de acordo com o desempenho
              Icon(
                _iconeDesempenho(p.acertoPercentual),
                size: 80,
                color: _corDesempenho(p.acertoPercentual),
              ),
              const SizedBox(height: 16),

              const Text(
                'Partida Finalizada!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Card de XP
              _StatCard(
                icon: Icons.star,
                iconColor: Colors.amber,
                label: 'XP Ganho',
                valor: '${p.pontuacao}',
              ),
              const SizedBox(height: 16),

              // Card de acertos
              _StatCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                label: 'Acertos',
                valor: '${p.acertos}/${p.respondidas}',
              ),
              const SizedBox(height: 16),

              // Card de streak
              if (p.streak > 0)
                _StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  label: 'Melhor Streak',
                  valor: '${p.streak}',
                ),

              if (_posicao != null && _posicao! <= 50) ...[
                const SizedBox(height: 16),
                _StatCard(
                  icon: Icons.emoji_events,
                  iconColor: AppColors.purple,
                  label: 'Posição no Ranking',
                  valor: '#$_posicao',
                ),
              ],

              const SizedBox(height: 40),

              // Botoes
              AppButton(
                label: 'Jogar Novamente',
                icon: Icons.replay,
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Rotas.jogar,
                    arguments: {
                      'alunoId': p.alunoId,
                      'apelido': widget.apelido,
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Ver Ranking',
                icon: Icons.leaderboard,
                variant: AppButtonVariant.ghost,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Rotas.ranking,
                    arguments: {'alunoId': p.alunoId},
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Rotas.homeStudent,
                    (route) => false,
                  );
                },
                child: Text(
                  'Início',
                  style: TextStyle(color: AppColors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconeDesempenho(double percentual) {
    if (percentual >= 80) return Icons.emoji_events;
    if (percentual >= 60) return Icons.celebration;
    if (percentual >= 40) return Icons.fitness_center;
    return Icons.menu_book;
  }

  Color _corDesempenho(double percentual) {
    if (percentual >= 80) return Colors.amber;
    if (percentual >= 60) return Colors.green;
    if (percentual >= 40) return Colors.blue;
    return AppColors.purple;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
