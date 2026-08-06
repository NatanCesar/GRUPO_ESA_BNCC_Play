import '../../data/models/papel.dart';
import '../../data/errors.dart';
import '../session/session_scope.dart';

/// Guarda de papel.
///
/// Chamada no repositorio, nao so na tela: esconder botao nao e controle de
/// acesso, e o teste precisa poder chamar o metodo direto e receber o erro.
abstract final class Permission {
  static void requireRole(SessionScope sessao, Papel esperado) {
    final usuario = sessao.exigirUsuario();
    if (usuario.papel != esperado) {
      throw const PermissionDeniedException();
    }
  }
}
