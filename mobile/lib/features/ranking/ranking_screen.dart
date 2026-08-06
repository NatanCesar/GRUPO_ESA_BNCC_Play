import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/core/widgets/top_bar.dart';
import 'package:bncc_play_mobile/data/models/ranking.dart';
import 'package:bncc_play_mobile/data/repositories/ranking_repository.dart';

/// Tela de ranking de jogadores.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.alunoId});

  final int alunoId;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RankingRepository _repository;
  List<RankingEntry> _ranking = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _repository = RankingRepository(banco: Provider.of(context));
    _carregarRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _carregarRanking();
    }
  }

  Future<void> _carregarRanking() async {
    setState(() => _carregando = true);
    try {
      final lista = await _repository.listarGeral(limite: 50);
      setState(() {
        _ranking = lista;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        title: const Text('Ranking'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Geral'),
            Tab(text: 'Tech'),
            Tab(text: 'Cultura'),
            Tab(text: 'Impacto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RankingTab(
            ranking: _ranking,
            carregando: _carregando,
            alunoId: widget.alunoId,
          ),
          _RankingTab(
            ranking: _ranking,
            carregando: _carregando,
            alunoId: widget.alunoId,
          ),
          _RankingTab(
            ranking: _ranking,
            carregando: _carregando,
            alunoId: widget.alunoId,
          ),
          _RankingTab(
            ranking: _ranking,
            carregando: _carregando,
            alunoId: widget.alunoId,
          ),
        ],
      ),
    );
  }
}

class _RankingTab extends StatelessWidget {
  const _RankingTab({
    required this.ranking,
    required this.carregando,
    required this.alunoId,
  });

  final List<RankingEntry> ranking;
  final bool carregando;
  final int alunoId;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (ranking.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhum jogador ainda',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Seja o primeiro a jogar!',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: recarregar ranking
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ranking.length,
        itemBuilder: (context, index) {
          return _RankingTile(
            entry: ranking[index],
            posicao: index + 1,
            isCurrentUser: ranking[index].alunoId == alunoId,
          );
        },
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.entry,
    required this.posicao,
    required this.isCurrentUser,
  });

  final RankingEntry entry;
  final int posicao;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.purple.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppColors.purple, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Posicao
          SizedBox(
            width: 40,
            child: _buildPosicao(),
          ),
          const SizedBox(width: 12),

          // Apelido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.apelido,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, 
                        color: isCurrentUser ? AppColors.purple : Colors.black87,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Voce',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.totalJogos} jogos | ${entry.taxaAcerto.toStringAsFixed(1)}% acerto',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.pontuacaoTotal}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.purple),
                  ),
                ],
              ),
              const Text(
                'XP',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPosicao() {
    if (posicao == 1) {
      return const Text('🥇', style: TextStyle(fontSize: 24));
    }
    if (posicao == 2) {
      return const Text('🥈', style: TextStyle(fontSize: 24));
    }
    if (posicao == 3) {
      return const Text('🥉', style: TextStyle(fontSize: 24));
    }
    return Text(
      '#$posicao',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, 
        color: Colors.grey.shade600,
      ),
    );
  }
}
