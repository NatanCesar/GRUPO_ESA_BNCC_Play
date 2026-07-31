/// Regras de campo do app.
///
/// Cada metodo devolve a mensagem de erro em portugues, ou nulo quando o
/// valor e aceito. A mensagem vai direto para o `errorText` do campo.
abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _usuario = RegExp(r'^[a-zA-Z0-9._]+$');

  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail';
    if (v.length > 120) return 'E-mail muito longo';
    if (!_email.hasMatch(v)) return 'E-mail invalido';
    return null;
  }

  /// A senha nao passa por trim: espaco e caractere valido do segredo.
  static String? senha(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Informe sua senha';
    if (v.length < 8) return 'A senha precisa de ao menos 8 caracteres';
    return null;
  }

  static String? nome(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome';
    if (v.length < 3 || v.length > 80) {
      return 'O nome precisa de 3 a 80 caracteres';
    }
    return null;
  }

  static String? usuario(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome de usuario';
    if (v.length < 3 || v.length > 30) {
      return 'O nome de usuario precisa de 3 a 30 caracteres';
    }
    if (!_usuario.hasMatch(v)) {
      return 'Use apenas letras, numeros, ponto e sublinhado';
    }
    return null;
  }

  static String? escola(String? valor) =>
      _textoCurto(valor, 'Informe sua escola', 'A escola precisa de 2 a 80 caracteres');

  static String? turma(String? valor) =>
      _textoCurto(valor, 'Informe sua turma', 'A turma precisa de 2 a 80 caracteres');

  static String? _textoCurto(String? valor, String vazio, String tamanho) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return vazio;
    if (v.length < 2 || v.length > 80) return tamanho;
    return null;
  }
}
