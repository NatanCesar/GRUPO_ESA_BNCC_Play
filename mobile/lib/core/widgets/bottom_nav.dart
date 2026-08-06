import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Item de navegacao inferior.
class ItemDeNav {
  const ItemDeNav({
    required this.id,
    required this.icone,
    required this.rotulo,
    this.habilitado = true,
  });

  final String id;
  final IconData icone;
  final String rotulo;

  /// Item de ciclo futuro fica visivel e apagado, mas continua clicavel: o
  /// toque explica que a tela ainda nao chegou.
  final bool habilitado;
}

/// Barra inferior do prototipo: icone acima, rotulo abaixo, ativo colorido.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.itens,
    required this.ativo,
    required this.onSelecionar,
    this.cor = AppColors.purple,
  });

  final List<ItemDeNav> itens;
  final String ativo;
  final ValueChanged<String> onSelecionar;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in itens)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelecionar(item.id),
                    child: Opacity(
                      opacity: item.habilitado ? 1 : 0.4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icone,
                            size: 22,
                            color: item.id == ativo ? cor : AppColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.rotulo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.inter,
                              fontSize: 11,
                              fontWeight: item.id == ativo
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  item.id == ativo ? cor : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
