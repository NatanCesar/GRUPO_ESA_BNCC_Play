import 'package:flutter/material.dart';

/// Assinatura visual oficial do BNCC Play.
///
/// Use [AppLogo.mark] em espacos pequenos, nos quais o texto da versao
/// completa ficaria ilegivel.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width, this.height, this.fit = BoxFit.contain})
    : _asset = 'assets/images/logo.png';

  const AppLogo.mark({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : _asset = 'assets/images/logo_mark.png';

  final String _asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: 'BNCC Play',
    );
  }
}
