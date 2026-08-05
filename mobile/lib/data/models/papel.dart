/// Papel do usuario no sistema. Os valores de [valor] sao os unicos aceitos
/// pela constraint da coluna `papel`.
enum Papel {
  professor('professor', 'Professor(a)'),
  aluno('aluno', 'Aluno(a)');

  const Papel(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static Papel dePersistencia(String valor) {
    for (final papel in Papel.values) {
      if (papel.valor == valor) return papel;
    }
    throw ArgumentError.value(valor, 'valor', 'Papel desconhecido');
  }
}
