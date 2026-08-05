/// Limpeza de texto livre antes de chegar ao repositorio.
///
/// Ordem importa: primeiro as entidades viram caractere, senao
/// `&lt;script&gt;` sobreviveria a remocao de tag e voltaria a ser HTML
/// quando alguém renderizasse o texto.
abstract final class Sanitizer {
  static final _entidades = <String, String>{
    '&lt;': '<',
    '&gt;': '>',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
  };

  /// Bloco script: opening tag + qualquer conteudo ate fechar ou fim da string.
  /// Non-greedy (.*?) para parar no primeiro </script>.
  /// Case-insensitive, dotAll para . casar com quebra de linha.
  static final _script = RegExp(
    r'<\s*script[^>]*>.*?(<\s*/\s*script\s*>|$)',
    caseSensitive: false,
    dotAll: true,
  );

  /// Tag HTML solta (sem fechamento) ou malformada no fim da string.
  static final _tagHtml = RegExp(r'<[^>]*>|<[^>]*$');

  static final _espacos = RegExp(r'\s+');

  static String limpar(String? valor, {int maxLength = 200}) {
    var texto = valor ?? '';
    if (texto.isEmpty) return '';

    // 1. Entidades HTML viram caractere antes de qualquer remocao de tag.
    //    Assim `&lt;script&gt;` se torna `<script>` (texto) e e removido
    //    junto com o conteudo pelo regex de script abaixo.
    _entidades.forEach((entidade, caractere) {
      texto = texto.replaceAll(entidade, caractere);
    });

    // 2. Remove bloco script: opening tag + conteudo + closing tag.
    texto = texto.replaceAll(_script, '');

    // 3. Remove qualquer tag HTML solta restante (sobras de tag sem fechar).
    texto = texto.replaceAll(_tagHtml, '');

    // 4. Normaliza espacos repetidos e aparas das pontas.
    texto = texto.replaceAll(_espacos, ' ').trim();

    return texto.length > maxLength ? texto.substring(0, maxLength) : texto;
  }
}
