/// Eixos tematicos da BNCC Computacao.
enum EixoBNCC {
  tecnologia('tecnologia', 'Pensamento Computacional'),
  culturaDigital('cultura', 'Cultura Digital'),
  impacto('impacto', 'Mundo Digital');

  const EixoBNCC(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static EixoBNCC dePersistencia(String valor) {
    for (final eixo in EixoBNCC.values) {
      if (eixo.valor == valor) return eixo;
    }
    throw ArgumentError.value(valor, 'valor', 'EixoBNCC desconhecido');
  }
}
