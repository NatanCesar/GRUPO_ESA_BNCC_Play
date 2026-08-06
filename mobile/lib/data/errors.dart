/// Erros que o repositorio devolve para o controlador traduzir em tela.
///
/// Sao selados para o controlador poder fazer switch exaustivo e o
/// compilador cobrar o tratamento de um caso novo.
sealed class ErroDeDominio implements Exception {
  const ErroDeDominio(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class EmailJaCadastradoException extends ErroDeDominio {
  const EmailJaCadastradoException()
      : super('Este e-mail ja esta cadastrado');
}

class UsuarioJaCadastradoException extends ErroDeDominio {
  const UsuarioJaCadastradoException()
      : super('Este nome de usuario ja esta em uso');
}

class CredenciaisInvalidasException extends ErroDeDominio {
  const CredenciaisInvalidasException()
      : super('E-mail ou senha incorretos');
}

class LoginBloqueadoException extends ErroDeDominio {
  const LoginBloqueadoException(this.segundosRestantes)
      : super('Muitas tentativas. Tente novamente em alguns instantes');

  final int segundosRestantes;
}

class SessaoExpiradaException extends ErroDeDominio {
  const SessaoExpiradaException()
      : super('Sua sessao expirou. Entre novamente');
}

class FalhaDePersistenciaException extends ErroDeDominio {
  const FalhaDePersistenciaException()
      : super('Nao foi possivel salvar. Tente novamente');
}

class PermissionDeniedException extends ErroDeDominio {
  const PermissionDeniedException()
      : super('Voce nao tem permissao para esta acao');
}

// Erros do ciclo 2 - Questoes

class QuestaoNaoEncontradaException extends ErroDeDominio {
  const QuestaoNaoEncontradaException()
      : super('Questao nao encontrada');
}

class QuestaoInvalidaException extends ErroDeDominio {
  const QuestaoInvalidaException(String mensagem)
      : super(mensagem);
}
