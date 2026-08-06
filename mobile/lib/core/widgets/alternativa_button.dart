import 'package:flutter/material.dart';
import 'package:bncc_play_mobile/core/theme/app_colors.dart';

/// Botao de alternativa no quiz com feedback de acerto/erro.
class AlternativaButton extends StatelessWidget {
  const AlternativaButton({
    super.key,
    required this.letra,
    required this.texto,
    required this.onTap,
    this.estado = AlternativaEstado.normal,
  });

  final String letra;
  final String texto;
  final VoidCallback onTap;
  final AlternativaEstado estado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: _corFundo,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: estado == AlternativaEstado.normal ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _corBorda, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _corBorda.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      letra,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _corBorda,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 15,
                      color: _corTexto,
                      fontWeight: estado == AlternativaEstado.correta
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (estado == AlternativaEstado.correta)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                if (estado == AlternativaEstado.errada)
                  const Icon(Icons.cancel, color: Colors.red, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _corFundo {
    switch (estado) {
      case AlternativaEstado.normal:
        return Colors.white;
      case AlternativaEstado.correta:
        return Colors.green.shade50;
      case AlternativaEstado.errada:
        return Colors.red.shade50;
    }
  }

  Color get _corBorda {
    switch (estado) {
      case AlternativaEstado.normal:
        return AppColors.purple.withValues(alpha: 0.3);
      case AlternativaEstado.correta:
        return Colors.green;
      case AlternativaEstado.errada:
        return Colors.red;
    }
  }

  Color get _corTexto {
    switch (estado) {
      case AlternativaEstado.normal:
        return Colors.black87;
      case AlternativaEstado.correta:
        return Colors.green.shade900;
      case AlternativaEstado.errada:
        return Colors.red.shade900;
    }
  }
}

enum AlternativaEstado { normal, correta, errada }
