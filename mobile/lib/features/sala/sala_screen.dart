import 'package:flutter/material.dart';

import 'package:bncc_play_mobile/core/theme/app_colors.dart';
import 'package:bncc_play_mobile/core/widgets/app_button.dart';

/// Tela de sala multiplayer (casca navegavel).
///
/// A logica real de multiplayer depende de servidor e fica para quando
/// o backend estiver implementado.
class SalaScreen extends StatelessWidget {
  const SalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        title: const Text('Sala Multiplayer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info da sala
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.group,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sala dos Desafiantes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Codigo: DESAFIO2026',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Aviso
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.construction, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modo multiplayer em desenvolvimento. '
                      'A logica de sala com server-side sync sera implementada.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lista de jogadores (placeholder)
            const Text(
              'Jogadores na sala',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _JogadorTile(
              nome: 'MariaSilva',
              avatar: '👩‍🏫',
              status: 'Pronto',
              isReady: true,
            ),
            _JogadorTile(
              nome: 'JoaoGames',
              avatar: '🎮',
              status: 'Jogando',
              isReady: true,
            ),
            _JogadorTile(
              nome: 'AnaEstuda',
              avatar: '📚',
              status: 'Aguardando',
              isReady: false,
            ),
            _JogadorTile(
              nome: 'Pedrinho',
              avatar: '🧑',
              status: 'Aguardando',
              isReady: false,
            ),

            const SizedBox(height: 32),

            // Botao de entrada
            AppButton(
              label: 'Entrar na Partida',
              icon: Icons.play_arrow,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Multiplayer em desenvolvimento'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JogadorTile extends StatelessWidget {
  const _JogadorTile({
    required this.nome,
    required this.avatar,
    required this.status,
    required this.isReady,
  });

  final String nome;
  final String avatar;
  final String status;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isReady ? Colors.green.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: isReady ? Colors.green.shade700 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
