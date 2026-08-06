/// Nivel de dificuldade de uma questao.
enum Dificuldade {
  facil('facil', 'Fácil'),
  medio('medio', 'Médio'),
  dificil('dificil', 'Difícil');

  const Dificuldade(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static Dificuldade dePersistencia(String valor) {
    for (final dif in Dificuldade.values) {
      if (dif.valor == valor) return dif;
    }
    throw ArgumentError.value(valor, 'valor', 'Dificuldade desconhecida');
  }
}
