import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/models/estatistica.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/repositories/estatistica_repository.dart';
import 'package:bncc_play_mobile/features/dashboard/dashboard_controller.dart';

/// Tela de dashboard pedagogico do professor (CT17).
///
/// Inclui guarda de acesso: apenas professores podem acessar.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.professorId, this.onVoltar});

  final int professorId;
  final VoidCallback? onVoltar;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Verifica se o usuario logado e professor e corresponde ao ID.
    WidgetsBinding.instance.addPostFrameCallback((_) => _verificarAcesso());
  }

  void _verificarAcesso() {
    final sessao = Provider.of<SessionScope>(context, listen: false);
    final usuario = sessao.usuario;

    if (usuario == null || usuario.papel != Papel.professor) {
      // Aluno tentando acessar dashboard via deep link.
      Navigator.pushReplacementNamed(context, Rotas.homeStudent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acesso restrito a professores.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (usuario.id != widget.professorId) {
      // Professor tentando ver dashboard de outro professor.
      Navigator.pushReplacementNamed(context, Rotas.homeTeacher);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessao = Provider.of<SessionScope>(context);
    final usuario = sessao.usuario;

    if (usuario == null || usuario.papel != Papel.professor) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return ChangeNotifierProvider(
      create: (_) => DashboardController(
        repository: EstatisticaRepository(banco: Provider.of(context)),
        professorId: widget.professorId,
      )..carregar(),
      child: _DashboardBody(onVoltar: widget.onVoltar),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({this.onVoltar});

  final VoidCallback? onVoltar;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: onVoltar ?? () => Navigator.maybePop(context),
        ),
      ),
      body: _buildBody(context, ctrl),
    );
  }

  Widget _buildBody(BuildContext context, DashboardController ctrl) {
    if (ctrl.carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (ctrl.erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(ctrl.erro!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ctrl.carregar(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final stats = ctrl.estatisticas;
    if (stats == null) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    return RefreshIndicator(
      onRefresh: () => ctrl.carregar(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cards de estatisticas
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icone: Icons.people,
                    valor: '${stats.totalAlunos}',
                    label: 'Alunos',
                    cor: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icone: Icons.sports_esports,
                    valor: '${stats.totalPartidas}',
                    label: 'Partidas',
                    cor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icone: Icons.star,
                    valor: stats.mediaPontuacao.toStringAsFixed(0),
                    label: 'Média XP',
                    cor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icone: Icons.check_circle,
                    valor: '${stats.taxaAcertoMedia.toStringAsFixed(1)}%',
                    label: 'Taxa Acerto',
                    cor: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alunos por eixo
            if (ctrl.alunosPorEixo.isNotEmpty) ...[
              _Secao(
                titulo: 'Alunos por Eixo',
                child: Column(
                  children: [
                    _BarraEixo(
                      label: EixoBNCC.tecnologia.rotulo,
                      valor: ctrl.alunosPorEixo['tecnologia'] ?? 0,
                      cor: AppColors.purple,
                    ),
                    const SizedBox(height: 8),
                    _BarraEixo(
                      label: EixoBNCC.culturaDigital.rotulo,
                      valor: ctrl.alunosPorEixo['cultura'] ?? 0,
                      cor: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _BarraEixo(
                      label: EixoBNCC.impacto.rotulo,
                      valor: ctrl.alunosPorEixo['impacto'] ?? 0,
                      cor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (ctrl.questoesFaceis.isNotEmpty) ...[
              _Secao(
                titulo: 'Questões com mais acertos',
                child: Column(
                  children: ctrl.questoesFaceis
                      .map((questao) => _QuestaoTaxaTile(questao: questao))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (ctrl.questoesDificeis.isNotEmpty) ...[
              _Secao(
                titulo: 'Questões com mais dificuldade',
                child: Column(
                  children: ctrl.questoesDificeis
                      .map((questao) => _QuestaoTaxaTile(questao: questao))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Top alunos
            if (ctrl.melhoresAlunos.isNotEmpty) ...[
              _Secao(
                titulo: 'Top Jogadores',
                child: Column(
                  children: ctrl.melhoresAlunos
                      .take(5)
                      .map((aluno) => _AlunoTile(aluno: aluno))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestaoTaxaTile extends StatelessWidget {
  const _QuestaoTaxaTile({required this.questao});

  final EstatisticaQuestao questao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              questao.enunciado,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${questao.taxaAcerto.toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icone,
    required this.valor,
    required this.label,
    required this.cor,
  });

  final IconData icone;
  final String valor;
  final String label;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 28),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

class _BarraEixo extends StatelessWidget {
  const _BarraEixo({
    required this.label,
    required this.valor,
    required this.cor,
  });

  final String label;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final maxVal = valor > 0 ? valor : 1;
    final percentual = valor > 0 ? (valor / (maxVal * 2)).clamp(0.1, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentual,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$valor',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _AlunoTile extends StatelessWidget {
  const _AlunoTile({required this.aluno});

  final ({int alunoId, String nome, int pontuacao, double taxa}) aluno;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Rotas.relatorioAluno,
            arguments: {'alunoId': aluno.alunoId},
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                aluno.nome,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${aluno.pontuacao}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                '${aluno.taxa.toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
