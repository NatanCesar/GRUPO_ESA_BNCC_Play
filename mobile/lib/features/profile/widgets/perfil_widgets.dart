import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Circulo translucido com o emoji do papel, dentro do cabecalho.
class AvatarDePerfil extends StatelessWidget {
  const AvatarDePerfil({super.key, required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 44)),
    );
  }
}

class CartaoDeEstatistica extends StatelessWidget {
  const CartaoDeEstatistica({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    this.cor = AppColors.purple,
  });

  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icone, size: 20, color: cor),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontFamily: AppTheme.poppins,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemDeMenu extends StatelessWidget {
  const ItemDeMenu({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.detalhe,
    required this.onTap,
    this.cor = AppColors.purple,
    this.fundoDoIcone = AppColors.purpleLight,
  });

  final IconData icone;
  final String rotulo;
  final String detalhe;
  final VoidCallback onTap;
  final Color cor;
  final Color fundoDoIcone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fundoDoIcone,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, size: 20, color: cor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rotulo,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalhe,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotaoSair extends StatelessWidget {
  const BotaoSair({super.key, required this.onSair});

  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerLight,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSair,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Sair da Conta',
                style: TextStyle(
                  fontFamily: AppTheme.poppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
