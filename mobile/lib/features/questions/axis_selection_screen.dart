import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/core/widgets/gradient_header.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';

/// Tela de selecao de eixo da BNCC Computacao (CT05).
///
/// Permite que o professor selecione o eixo tematico antes de gerenciar
/// questoes ou iniciar atividades.
class AxisSelectionScreen extends StatefulWidget {
  const AxisSelectionScreen({super.key});

  @override
  State<AxisSelectionScreen> createState() => _AxisSelectionScreenState();
}

class _AxisSelectionScreenState extends State<AxisSelectionScreen> {
  final Map<EixoBNCC, int> _contagens = {};

  @override
  void initState() {
    super.initState();
    _carregarContagens();
  }

  Future<void> _carregarContagens() async {
    final session = context.read<SessionScope>();
    final usuario = session.usuario;
    if (usuario == null) return;

    final repository = context.read<QuestaoRepository>();
    try {
      final contagens = await repository.contarPorEixo(usuario.id!);
      if (mounted) {
        setState(() => _contagens.addAll(contagens));
      }
    } catch (_) {
      // Ignora erro de contagem.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeader(
            gradient: AppColors.purpleHeaderGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selecione o Eixo', style: AppTheme.headerTitle),
                const SizedBox(height: 4),
                Text('BNCC Computação', style: AppTheme.headerSubtitle),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                for (final eixo in EixoBNCC.values) ...[
                  _EixoCard(
                    eixo: eixo,
                    quantidade: _contagens[eixo] ?? 0,
                    onTap: () => _selecionarEixo(context, eixo),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selecionarEixo(BuildContext context, EixoBNCC eixo) {
    Navigator.pushNamed(context, Rotas.questionList, arguments: eixo);
  }
}

class _EixoCard extends StatelessWidget {
  const _EixoCard({
    required this.eixo,
    required this.quantidade,
    required this.onTap,
  });

  final EixoBNCC eixo;
  final int quantidade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _iconeEixo(eixo),
                    color: AppColors.purple,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eixo.rotulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$quantidade ${quantidade == 1 ? 'questão' : 'questões'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconeEixo(EixoBNCC eixo) {
    switch (eixo) {
      case EixoBNCC.tecnologia:
        return Icons.laptop_chromebook;
      case EixoBNCC.culturaDigital:
        return Icons.public;
      case EixoBNCC.impacto:
        return Icons.balance;
    }
  }
}
