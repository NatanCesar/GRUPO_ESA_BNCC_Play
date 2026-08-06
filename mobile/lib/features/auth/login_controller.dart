import '../../core/session/session_scope.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/errors.dart';

/// Estado da tela de login.
///
/// Traduz os erros de dominio em mensagem de tela e abre a sessao no
/// sucesso. A tela nao conhece repositorio nem excecao.
///
/// Nao estende ChangeNotifier para evitar conflitos de listener em testes.
class LoginController {
  LoginController({required AuthRepository auth, required SessionScope sessao})
      : _auth = auth,
        _sessao = sessao;

  final AuthRepository _auth;
  final SessionScope _sessao;

  String? erroEmail;
  String? erroSenha;
  String? erroGeral;
  bool carregando = false;
  int segundosBloqueado = 0;

  /// Chamado quando qualquer campo de estado muda.
  VoidCallback? onChanged;

  Future<AppUser?> entrar({
    required String email,
    required String senha,
  }) async {
    erroEmail = email.trim().isEmpty ? 'Informe seu e-mail' : null;
    erroSenha = senha.isEmpty ? 'Informe sua senha' : null;
    erroGeral = null;
    onChanged?.call();

    if (erroEmail != null || erroSenha != null) return null;

    carregando = true;
    onChanged?.call();

    try {
      final usuario = await _auth.entrar(email: email, senha: senha);
      _sessao.abrir(usuario);
      segundosBloqueado = 0;
      return usuario;
    } on LoginBloqueadoException catch (e) {
      segundosBloqueado = e.segundosRestantes;
      erroGeral =
          'Muitas tentativas. Tente novamente em ${e.segundosRestantes}s';
      onChanged?.call();
      return null;
    } on ErroDeDominio catch (e) {
      erroGeral = e.mensagem;
      onChanged?.call();
      return null;
    } finally {
      carregando = false;
      onChanged?.call();
    }
  }

  void limparErro() {
    if (erroGeral == null && erroEmail == null && erroSenha == null) return;
    erroEmail = null;
    erroSenha = null;
    erroGeral = null;
    onChanged?.call();
  }
}

typedef VoidCallback = void Function();
