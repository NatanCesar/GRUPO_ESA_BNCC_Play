import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Barra superior com botao de voltar opcional.
///
/// Usada nos cabecalhos escuros das telas de cadastro e listagem.
/// O parametro [titulo] omite o botao de voltar; [onVoltar] omite o titulo.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.titulo,
    this.onVoltar,
  });

  /// Texto do titulo, omitido se for [null].
  final String? titulo;

  /// Callback do botao de voltar. Se for [null], o botao nao aparece.
  final VoidCallback? onVoltar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onVoltar != null) ...[
          _BotaoVoltar(onVoltar: onVoltar!),
          const SizedBox(width: 8),
        ],
        if (titulo != null)
          Expanded(
            child: Text(titulo!, style: AppTheme.topBarTitle),
          ),
      ],
    );
  }
}

class _BotaoVoltar extends StatelessWidget {
  const _BotaoVoltar({required this.onVoltar});

  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onVoltar,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
