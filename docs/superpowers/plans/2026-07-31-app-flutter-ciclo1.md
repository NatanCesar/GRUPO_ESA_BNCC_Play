# App Flutter BNCC Play — Ciclo 1 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Entregar o app Flutter BNCC Play rodando 100% local com autenticação, cadastro de professor e aluno, perfis editáveis e suíte de testes rastreável a CT01–CT04, CT11 e CT12.

**Architecture:** Feature-first. Telas em `lib/features/<feature>/`, código compartilhado em `lib/core/`, acesso a dado em `lib/data/`. Repositórios e sessão injetados por `provider` na raiz; nenhuma tela instancia repositório. Persistência em sqflite versionado; nos testes o mesmo código roda em banco de memória via `sqflite_common_ffi`.

**Tech Stack:** Flutter (Dart SDK ^3.12.2), sqflite, provider, crypto, path; `sqflite_common_ffi` e `integration_test` em dev.

**Spec:** `docs/superpowers/specs/2026-07-31-app-flutter-ciclo1-design.md`

## Global Constraints

- Todo texto de UI, mensagem de erro e nome de teste em **português do Brasil**.
- Comentários de código em português, sem acento (o código existente segue esse padrão — `lib/theme/app_colors.dart`).
- Nenhuma alteração em `backend/` ou `frontend/`.
- Senha nunca em texto puro: banco, log ou mensagem de erro.
- Papéis válidos: exatamente `'professor'` e `'aluno'`.
- Bloqueio de login: 5 falhas consecutivas por e-mail → 60 segundos bloqueado.
- Expiração de sessão: 30 minutos de inatividade.
- Campos de cadastro do professor: Nome completo, E-mail institucional, Nome de usuário, Escola, Senha. Do aluno: Nome completo, E-mail, Nome de usuário, Turma, Senha. **Nenhum campo além desses** (CT03 não funcional cobra minimização de dados).
- Viewport de referência dos testes de widget: `Size(390, 844)`, `devicePixelRatio = 1.0`.
- Fidelidade visual ao protótipo: `/home/diogomnd/Downloads/BNCC Play Mobile Prototype/src/app/App.tsx`. As linhas exatas de cada tela estão citadas na tarefa correspondente.
- Cores só de `AppColors`; estilos de texto só de `AppTheme`. Nada de `Color(0x...)` solto em tela.
- Commits em português, prefixo Conventional Commits, sem acento no assunto.
- Todo comando roda a partir de `mobile/`.
- O método de sanitização chama-se `Sanitizer.limpar`, não `Sanitizer.strip` como consta no spec — nome de API em português, igual ao resto do código. Este plano é a referência.

## Estrutura de arquivos

| Arquivo | Responsabilidade |
|---|---|
| `lib/core/theme/app_colors.dart` | Paleta (movido de `lib/theme/`) |
| `lib/core/theme/app_theme.dart` | Tema e estilos nomeados (movido) |
| `lib/core/widgets/app_button.dart` | Botão do protótipo (movido) |
| `lib/core/widgets/app_text_field.dart` | Campo de formulário (movido) |
| `lib/core/widgets/gradient_header.dart` | Cabeçalho com gradiente (movido) |
| `lib/core/widgets/top_bar.dart` | Barra com voltar e título |
| `lib/core/widgets/app_badge.dart` | Etiqueta arredondada |
| `lib/core/widgets/bottom_nav.dart` | Navegação inferior |
| `lib/core/validation/validators.dart` | Regras de campo, devolvem mensagem ou nulo |
| `lib/core/validation/sanitizer.dart` | Remoção de HTML e normalização de texto livre |
| `lib/core/security/password_hasher.dart` | PBKDF2-HMAC-SHA256 |
| `lib/core/security/permission.dart` | `requireRole` e `PermissionDeniedException` |
| `lib/core/session/session_scope.dart` | Usuário logado, papel, expiração |
| `lib/core/routes.dart` | Nomes de rota e tabela de rotas |
| `lib/data/db/app_database.dart` | Abertura, schema e migração |
| `lib/data/models/papel.dart` | Enum `Papel` |
| `lib/data/models/app_user.dart` | Modelo de usuário e conversão de/para linha |
| `lib/data/repositories/erros.dart` | Exceções de domínio |
| `lib/data/repositories/user_repository.dart` | CRUD de usuário |
| `lib/data/repositories/auth_repository.dart` | Login e bloqueio por tentativas |
| `lib/features/auth/*` | Splash, login, escolha de perfil, cadastros, esqueci a senha |
| `lib/features/home/*` | Home do professor e do aluno |
| `lib/features/profile/*` | Perfis e edição |

---

### Task 1: Versionar `mobile/` e mover o compartilhado para `core/`

`mobile/` está fora do git e pode se perder. Antes de qualquer feature, versionar e reorganizar, provando com a suíte que já existe que nada quebrou.

**Files:**
- Create: `mobile/.gitignore` (verificar o gerado pelo Flutter; manter)
- Move: `mobile/lib/theme/` → `mobile/lib/core/theme/`
- Move: `mobile/lib/widgets/` → `mobile/lib/core/widgets/`
- Move: `mobile/lib/screens/login_screen.dart` → `mobile/lib/features/auth/login_screen.dart`
- Move: `mobile/test/login_screen_test.dart` → `mobile/test/features/login_screen_test.dart`
- Move: `mobile/test/login_golden_test.dart` → `mobile/test/features/login_golden_test.dart`
- Modify: `mobile/lib/main.dart`

**Interfaces:**
- Consumes: nada.
- Produces: caminhos de import `package:bncc_play_mobile/core/theme/app_colors.dart`, `.../core/theme/app_theme.dart`, `.../core/widgets/app_button.dart`, `.../core/widgets/app_text_field.dart`, `.../core/widgets/gradient_header.dart`, `.../features/auth/login_screen.dart`.

- [ ] **Step 1: Confirmar que a suíte atual passa antes de mexer**

```bash
cd mobile && flutter test
```
Esperado: todos os testes de `test/login_screen_test.dart` e `test/login_golden_test.dart` passam. Se o golden falhar aqui, regerar antes de continuar com `flutter test --update-goldens` e conferir a imagem a olho.

- [ ] **Step 2: Verificar o que o `.gitignore` do Flutter está cobrindo**

```bash
cd mobile && cat .gitignore && git check-ignore -v dist/bncc-play-login.apk .dart_tool/package_config.json
```
Esperado: `.dart_tool/` ignorado. `dist/` **não** está ignorado — o APK de 20 MB entraria no repositório. Acrescentar ao fim de `mobile/.gitignore`:

```gitignore
# Artefatos de build publicados manualmente
/dist/
```

- [ ] **Step 3: Mover os arquivos**

```bash
cd mobile
mkdir -p lib/core lib/features/auth test/features
mv lib/theme lib/core/theme
mv lib/widgets lib/core/widgets
mv lib/screens/login_screen.dart lib/features/auth/login_screen.dart
rmdir lib/screens
mv test/login_screen_test.dart test/features/login_screen_test.dart
mv test/login_golden_test.dart test/features/login_golden_test.dart
```

- [ ] **Step 4: Corrigir os imports**

Em `lib/core/widgets/app_button.dart`, `app_text_field.dart` e `gradient_header.dart`, trocar `import '../theme/app_colors.dart';` por `import '../theme/app_colors.dart';` — o caminho relativo continua correto porque tema e widgets desceram juntos. Nada a mudar nesses três.

Em `lib/features/auth/login_screen.dart`, trocar o bloco de imports por:

```dart
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_header.dart';
```

Em `lib/main.dart`:

```dart
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
```

Em `test/features/login_screen_test.dart` e `test/features/login_golden_test.dart`:

```dart
import 'package:bncc_play_mobile/features/auth/login_screen.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
```

O golden test aponta para `goldens/login_screen.png` por caminho relativo. Como o teste desceu um nível, corrigir para `../goldens/login_screen.png`.

- [ ] **Step 5: Rodar a suíte e a análise**

```bash
cd mobile && flutter analyze && flutter test
```
Esperado: `No issues found.` e todos os testes passando. Mesmo número de testes de antes — mover arquivo não muda comportamento.

- [ ] **Step 6: Commit**

```bash
git add mobile
git commit -m "chore: versiona o app Flutter e move o compartilhado para core

O diretorio mobile/ estava fora do controle de versao. Entra inteiro, com
tema, widgets, tela de login e a suite de testes existente. A organizacao
passa a ser feature-first: core/ para o compartilhado, features/ para as
telas. Nenhuma mudanca de comportamento."
```

---

### Task 2: Dependências e `Validators`

**Files:**
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/core/validation/validators.dart`
- Test: `mobile/test/unit/validators_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces: `abstract final class Validators` com os métodos estáticos `String? email(String?)`, `String? senha(String?)`, `String? nome(String?)`, `String? usuario(String?)`, `String? escola(String?)`, `String? turma(String?)`. Todos devolvem a mensagem de erro em português, ou `null` quando o valor é aceito.

- [ ] **Step 1: Declarar as dependências**

Em `mobile/pubspec.yaml`, dentro de `dependencies:` (abaixo de `flutter:`):

```yaml
  sqflite: ^2.4.1
  path: ^1.9.0
  provider: ^6.1.2
  crypto: ^3.0.6
```

Dentro de `dev_dependencies:`:

```yaml
  sqflite_common_ffi: ^2.3.4
  integration_test:
    sdk: flutter
```

Rodar:

```bash
cd mobile && flutter pub get
```
Esperado: `Got dependencies!` sem conflito de versão.

- [ ] **Step 2: Escrever o teste que falha**

Criar `mobile/test/unit/validators_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/validation/validators.dart';

void main() {
  group('Validators.email', () {
    test('aceita e-mail bem formado', () {
      expect(Validators.email('maria@escola.edu.br'), isNull);
    });

    test('cobra o preenchimento quando vem vazio ou so com espaco', () {
      expect(Validators.email(''), 'Informe seu e-mail');
      expect(Validators.email('   '), 'Informe seu e-mail');
      expect(Validators.email(null), 'Informe seu e-mail');
    });

    test('recusa formato invalido', () {
      expect(Validators.email('maria'), 'E-mail invalido');
      expect(Validators.email('maria@'), 'E-mail invalido');
      expect(Validators.email('maria@escola'), 'E-mail invalido');
      expect(Validators.email('maria escola@x.com'), 'E-mail invalido');
    });

    test('recusa e-mail acima de 120 caracteres', () {
      final longo = '${'a' * 115}@x.com';
      expect(Validators.email(longo), 'E-mail muito longo');
    });
  });

  group('Validators.senha', () {
    test('aceita senha com oito caracteres ou mais', () {
      expect(Validators.senha('segredo1'), isNull);
      expect(Validators.senha('Professor@123'), isNull);
    });

    test('cobra o preenchimento quando vem vazia', () {
      expect(Validators.senha(''), 'Informe sua senha');
      expect(Validators.senha(null), 'Informe sua senha');
    });

    test('recusa senha com menos de oito caracteres', () {
      expect(Validators.senha('curta1'), 'A senha precisa de ao menos 8 caracteres');
    });

    test('nao apara espaco da senha', () {
      // Espaco e caractere valido de senha; aparar mudaria o segredo.
      expect(Validators.senha('  a  b  '), isNull);
    });
  });

  group('Validators.nome', () {
    test('aceita nome dentro do limite', () {
      expect(Validators.nome('Maria Silva'), isNull);
    });

    test('cobra o preenchimento quando vem so com espaco', () {
      expect(Validators.nome('   '), 'Informe seu nome');
    });

    test('recusa nome curto demais', () {
      expect(Validators.nome('Jo'), 'O nome precisa de 3 a 80 caracteres');
    });

    test('recusa nome longo demais', () {
      expect(Validators.nome('a' * 81), 'O nome precisa de 3 a 80 caracteres');
    });

    test('conta o nome ja sem os espacos das pontas', () {
      expect(Validators.nome('  Ana  '), isNull);
    });
  });

  group('Validators.usuario', () {
    test('aceita letras, numeros, ponto e sublinhado', () {
      expect(Validators.usuario('maria.silva_2'), isNull);
    });

    test('cobra o preenchimento', () {
      expect(Validators.usuario(''), 'Informe seu nome de usuario');
    });

    test('recusa fora do tamanho', () {
      expect(Validators.usuario('ab'), 'O nome de usuario precisa de 3 a 30 caracteres');
      expect(Validators.usuario('a' * 31), 'O nome de usuario precisa de 3 a 30 caracteres');
    });

    test('recusa caractere especial e espaco', () {
      const msg = 'Use apenas letras, numeros, ponto e sublinhado';
      expect(Validators.usuario('maria silva'), msg);
      expect(Validators.usuario('maria@silva'), msg);
      expect(Validators.usuario('<script>'), msg);
    });
  });

  group('Validators.escola e Validators.turma', () {
    test('aceitam texto dentro do limite', () {
      expect(Validators.escola('E.E. Monteiro Lobato'), isNull);
      expect(Validators.turma('9 ano B'), isNull);
    });

    test('cobram o preenchimento', () {
      expect(Validators.escola('  '), 'Informe sua escola');
      expect(Validators.turma(''), 'Informe sua turma');
    });

    test('recusam fora do tamanho', () {
      expect(Validators.escola('a'), 'A escola precisa de 2 a 80 caracteres');
      expect(Validators.turma('a' * 81), 'A turma precisa de 2 a 80 caracteres');
    });
  });
}
```

- [ ] **Step 3: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/unit/validators_test.dart
```
Esperado: falha de compilação — `Target of URI doesn't exist: 'package:bncc_play_mobile/core/validation/validators.dart'`.

- [ ] **Step 4: Implementar**

Criar `mobile/lib/core/validation/validators.dart`:

```dart
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
```

- [ ] **Step 5: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/unit/validators_test.dart
```
Esperado: todos passando.

- [ ] **Step 6: Commit**

```bash
git add mobile/pubspec.yaml mobile/pubspec.lock mobile/lib/core/validation/validators.dart mobile/test/unit/validators_test.dart
git commit -m "feat: adiciona validadores de campo e as dependencias do ciclo

Entram sqflite, path, provider e crypto, mais sqflite_common_ffi e
integration_test em dev. Validators concentra as regras de e-mail, senha,
nome, usuario, escola e turma, devolvendo mensagem em portugues.

Cobre o teste nao funcional de CT04: entrada com caractere especial ou
texto longo demais e recusada com mensagem, nao truncada em silencio."
```

---

### Task 3: `Sanitizer`

Utilitário que tira HTML e script de todo texto livre antes de gravar. Cobre o teste não funcional de CT06; nasce aqui porque nome, escola e turma também são texto livre.

**Files:**
- Create: `mobile/lib/core/validation/sanitizer.dart`
- Test: `mobile/test/unit/sanitizer_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces: `abstract final class Sanitizer` com `static String limpar(String? valor, {int maxLength = 200})`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/unit/sanitizer_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/validation/sanitizer.dart';

void main() {
  group('Sanitizer.limpar', () {
    test('devolve texto comum sem mudanca', () {
      expect(Sanitizer.limpar('Maria Silva'), 'Maria Silva');
    });

    test('devolve string vazia para nulo', () {
      expect(Sanitizer.limpar(null), '');
    });

    test('remove tag html simples', () {
      expect(Sanitizer.limpar('O que e <b>algoritmo</b>?'), 'O que e algoritmo?');
    });

    test('remove bloco script inteiro, conteudo junto', () {
      expect(
        Sanitizer.limpar('Ola<script>alert("xss")</script>mundo'),
        'Olamundo',
      );
    });

    test('remove script com atributo e caixa alta', () {
      expect(
        Sanitizer.limpar('<SCRIPT SRC="http://x.com/a.js">roubar()</SCRIPT>fim'),
        'fim',
      );
    });

    test('remove tag mesmo sem fechamento', () {
      expect(Sanitizer.limpar('texto <img src=x onerror=alert(1)'), 'texto');
    });

    test('nao deixa entidade html virar tag depois', () {
      expect(Sanitizer.limpar('&lt;script&gt;alert(1)&lt;/script&gt;'), 'alert(1)');
    });

    test('normaliza espaco repetido e quebra de linha', () {
      expect(Sanitizer.limpar('Maria   \n\n  Silva'), 'Maria Silva');
    });

    test('apara espaco das pontas', () {
      expect(Sanitizer.limpar('   Ana   '), 'Ana');
    });

    test('corta no maxLength depois de limpar', () {
      expect(Sanitizer.limpar('a' * 300), 'a' * 200);
      expect(Sanitizer.limpar('abcdef', maxLength: 3), 'abc');
    });

    test('preserva acento e cedilha', () {
      expect(Sanitizer.limpar('João Conceição'), 'João Conceição');
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/unit/sanitizer_test.dart
```
Esperado: falha de compilação — arquivo `sanitizer.dart` não existe.

- [ ] **Step 3: Implementar**

Criar `mobile/lib/core/validation/sanitizer.dart`:

```dart
/// Limpeza de texto livre antes de chegar ao repositorio.
///
/// Ordem importa: primeiro as entidades viram caractere, senao
/// `&lt;script&gt;` sobreviveria a remocao de tag e voltaria a ser HTML
/// quando alguem renderizasse o texto.
abstract final class Sanitizer {
  static final _entidades = <String, String>{
    '&lt;': '<',
    '&gt;': '>',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
  };

  /// Bloco script inteiro, com ou sem fechamento, conteudo junto.
  static final _script = RegExp(
    r'<\s*script[^>]*>.*?(<\s*/\s*script\s*>|$)',
    caseSensitive: false,
    dotAll: true,
  );

  /// Qualquer tag restante, inclusive a que ficou sem fechar no fim da string.
  static final _tag = RegExp(r'<[^>]*>|<[^>]*$');

  static final _espacos = RegExp(r'\s+');

  static String limpar(String? valor, {int maxLength = 200}) {
    var texto = valor ?? '';
    if (texto.isEmpty) return '';

    _entidades.forEach((entidade, caractere) {
      texto = texto.replaceAll(entidade, caractere);
    });

    texto = texto.replaceAll(_script, '');
    texto = texto.replaceAll(_tag, '');
    texto = texto.replaceAll(_espacos, ' ').trim();

    return texto.length > maxLength ? texto.substring(0, maxLength) : texto;
  }
}
```

- [ ] **Step 4: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/unit/sanitizer_test.dart
```
Esperado: todos passando. Se `'&lt;script&gt;alert(1)&lt;/script&gt;'` falhar devolvendo string vazia, é sinal de que a ordem foi invertida na implementação — as entidades têm de virar caractere antes da remoção do bloco script.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/core/validation/sanitizer.dart mobile/test/unit/sanitizer_test.dart
git commit -m "feat: adiciona sanitizacao de texto livre

Remove bloco script, tag html solta e tag sem fechamento, decodificando as
entidades antes para que &lt;script&gt; nao sobreviva a limpeza. Normaliza
espaco e corta no tamanho maximo do campo.

Cobre o teste nao funcional de CT06."
```

---

### Task 4: `PasswordHasher`

**Files:**
- Create: `mobile/lib/core/security/password_hasher.dart`
- Test: `mobile/test/unit/password_hasher_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces: `class PasswordHasher` com `const PasswordHasher({int iteracoes = 100000})`, `SenhaCifrada cifrar(String senha)`, `SenhaCifrada cifrarComSalt(String senha, String salt)` e `bool confere(String senha, {required String hash, required String salt})`. `class SenhaCifrada` com os campos `final String hash` e `final String salt`, ambos em base64.

Nos testes o hasher é criado com `PasswordHasher(iteracoes: 1000)` — 100.000 iterações em Dart puro deixariam a suíte lenta sem provar nada a mais. O app usa o padrão.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/unit/password_hasher_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';

void main() {
  // Iteracoes baixas so no teste: o custo alto nao prova nada aqui.
  const hasher = PasswordHasher(iteracoes: 1000);

  group('PasswordHasher', () {
    test('nao devolve a senha em texto puro', () {
      final cifrada = hasher.cifrar('Professor@123');

      expect(cifrada.hash, isNot(contains('Professor')));
      expect(cifrada.hash, isNotEmpty);
      expect(cifrada.salt, isNotEmpty);
    });

    test('gera salt diferente a cada chamada', () {
      final a = hasher.cifrar('Professor@123');
      final b = hasher.cifrar('Professor@123');

      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
    });

    test('confere a senha correta', () {
      final cifrada = hasher.cifrar('Professor@123');

      expect(
        hasher.confere('Professor@123', hash: cifrada.hash, salt: cifrada.salt),
        isTrue,
      );
    });

    test('recusa senha errada', () {
      final cifrada = hasher.cifrar('Professor@123');

      expect(
        hasher.confere('Professor@124', hash: cifrada.hash, salt: cifrada.salt),
        isFalse,
      );
      expect(
        hasher.confere('', hash: cifrada.hash, salt: cifrada.salt),
        isFalse,
      );
    });

    test('recusa quando o salt nao e o do hash', () {
      final a = hasher.cifrar('Professor@123');
      final b = hasher.cifrar('Professor@123');

      expect(hasher.confere('Professor@123', hash: a.hash, salt: b.salt), isFalse);
    });

    test('mesmo salt e mesma senha geram o mesmo hash', () {
      final cifrada = hasher.cifrar('Professor@123');
      final repetido = hasher.cifrarComSalt('Professor@123', cifrada.salt);

      expect(repetido.hash, cifrada.hash);
    });

    test('numero de iteracoes muda o hash', () {
      const outro = PasswordHasher(iteracoes: 2000);
      final cifrada = hasher.cifrar('Professor@123');

      expect(
        outro.confere('Professor@123', hash: cifrada.hash, salt: cifrada.salt),
        isFalse,
      );
    });

    test('preserva acento na senha', () {
      final cifrada = hasher.cifrar('senhaÇã123');

      expect(
        hasher.confere('senhaÇã123', hash: cifrada.hash, salt: cifrada.salt),
        isTrue,
      );
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/unit/password_hasher_test.dart
```
Esperado: falha de compilação — arquivo `password_hasher.dart` não existe.

- [ ] **Step 3: Implementar**

Criar `mobile/lib/core/security/password_hasher.dart`:

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Senha cifrada pronta para gravar: os dois campos vao em base64.
class SenhaCifrada {
  const SenhaCifrada({required this.hash, required this.salt});

  final String hash;
  final String salt;
}

/// PBKDF2-HMAC-SHA256 sobre o pacote crypto, que oferece o HMAC mas nao o
/// PBKDF2. A derivacao e curta o bastante para viver aqui sem outra
/// dependencia nativa.
class PasswordHasher {
  const PasswordHasher({this.iteracoes = 100000});

  /// Custo da derivacao. O app usa o padrao; os testes baixam para nao
  /// pagar 100 mil rodadas em cada caso.
  final int iteracoes;

  static const _bytesDeSalt = 16;
  static const _bytesDeChave = 32;

  SenhaCifrada cifrar(String senha) =>
      cifrarComSalt(senha, _novoSalt());

  SenhaCifrada cifrarComSalt(String senha, String salt) {
    final derivada = _pbkdf2(
      utf8.encode(senha),
      base64Decode(salt),
    );
    return SenhaCifrada(hash: base64Encode(derivada), salt: salt);
  }

  bool confere(String senha, {required String hash, required String salt}) {
    late final Uint8List esperado;
    try {
      esperado = base64Decode(hash);
    } on FormatException {
      return false;
    }
    final obtido = base64Decode(cifrarComSalt(senha, salt).hash);
    return _iguaisEmTempoConstante(esperado, obtido);
  }

  String _novoSalt() {
    final rnd = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(_bytesDeSalt, (_) => rnd.nextInt(256)),
    );
    return base64Encode(bytes);
  }

  Uint8List _pbkdf2(List<int> senha, List<int> salt) {
    final hmac = Hmac(sha256, senha);
    final saida = BytesBuilder();
    var bloco = 1;

    while (saida.length < _bytesDeChave) {
      // U1 = HMAC(senha, salt || INT_32_BE(bloco))
      final entrada = <int>[
        ...salt,
        (bloco >> 24) & 0xff,
        (bloco >> 16) & 0xff,
        (bloco >> 8) & 0xff,
        bloco & 0xff,
      ];
      var u = Uint8List.fromList(hmac.convert(entrada).bytes);
      final acumulado = Uint8List.fromList(u);

      for (var i = 1; i < iteracoes; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < acumulado.length; j++) {
          acumulado[j] ^= u[j];
        }
      }

      saida.add(acumulado);
      bloco++;
    }

    return Uint8List.fromList(saida.toBytes().sublist(0, _bytesDeChave));
  }

  /// Comparacao sem saida antecipada, para o tempo de resposta nao vazar
  /// quantos bytes iniciais bateram.
  bool _iguaisEmTempoConstante(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diferenca = 0;
    for (var i = 0; i < a.length; i++) {
      diferenca |= a[i] ^ b[i];
    }
    return diferenca == 0;
  }
}
```

- [ ] **Step 4: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/unit/password_hasher_test.dart
```
Esperado: todos passando, em menos de 5 segundos.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/core/security/password_hasher.dart mobile/test/unit/password_hasher_test.dart
git commit -m "feat: adiciona cifragem de senha com PBKDF2-HMAC-SHA256

Salt de 16 bytes por usuario, 100 mil iteracoes no app e comparacao em
tempo constante na verificacao. O numero de iteracoes e injetavel para a
suite nao pagar o custo cheio.

Sustenta os testes funcionais de CT03 e CT04: a senha nunca fica em texto
puro."
```

---

### Task 5: Modelos e exceções de domínio

**Files:**
- Create: `mobile/lib/data/models/papel.dart`
- Create: `mobile/lib/data/models/app_user.dart`
- Create: `mobile/lib/data/repositories/erros.dart`
- Test: `mobile/test/data/app_user_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces:
  - `enum Papel { professor, aluno }` com `String get valor` (`'professor'` / `'aluno'`), `String get rotulo` (`'Professor(a)'` / `'Aluno(a)'`) e `static Papel dePersistencia(String)`.
  - `class AppUser` — campos `int? id`, `String nome`, `String email`, `String usuario`, `Papel papel`, `String? escola`, `String? turma`, `String? avatar`, `DateTime criadoEm`, `DateTime atualizadoEm`. Métodos `Map<String, Object?> paraLinha({required String senhaHash, required String salt})`, `static AppUser deLinha(Map<String, Object?>)` e `AppUser copiarCom({String? nome, String? email, String? usuario, String? escola, String? turma, String? avatar, DateTime? atualizadoEm})`.
  - `erros.dart` com `sealed class ErroDeDominio implements Exception` e o campo `final String mensagem`; subclasses `EmailJaCadastradoException`, `UsuarioJaCadastradoException`, `CredenciaisInvalidasException`, `LoginBloqueadoException` (com `final int segundosRestantes`), `SessaoExpiradaException`, `FalhaDePersistenciaException`. `PermissionDeniedException` nasce na Task 9, em `core/security/permission.dart`.

O modelo não carrega `senhaHash` nem `salt`: quem sai do repositório para a UI não deve ter como vazar credencial. O hash entra por parâmetro em `paraLinha` e fica no banco.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/data/app_user_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';

void main() {
  final agora = DateTime.utc(2026, 7, 31, 12, 30);

  AppUser professor() => AppUser(
        id: 1,
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
        criadoEm: agora,
        atualizadoEm: agora,
      );

  group('Papel', () {
    test('converte para o valor gravado no banco', () {
      expect(Papel.professor.valor, 'professor');
      expect(Papel.aluno.valor, 'aluno');
    });

    test('le o valor vindo do banco', () {
      expect(Papel.dePersistencia('professor'), Papel.professor);
      expect(Papel.dePersistencia('aluno'), Papel.aluno);
    });

    test('recusa valor desconhecido', () {
      expect(() => Papel.dePersistencia('admin'), throwsArgumentError);
    });

    test('tem rotulo para a interface', () {
      expect(Papel.professor.rotulo, 'Professor(a)');
      expect(Papel.aluno.rotulo, 'Aluno(a)');
    });
  });

  group('AppUser.paraLinha', () {
    test('grava data em ISO-8601 UTC', () {
      final linha = professor().paraLinha(senhaHash: 'h', salt: 's');

      expect(linha['criado_em'], '2026-07-31T12:30:00.000Z');
      expect(linha['atualizado_em'], '2026-07-31T12:30:00.000Z');
    });

    test('grava o papel como texto e leva hash e salt', () {
      final linha = professor().paraLinha(senhaHash: 'h', salt: 's');

      expect(linha['papel'], 'professor');
      expect(linha['senha_hash'], 'h');
      expect(linha['salt'], 's');
    });

    test('nao inclui id nulo, para o banco gerar', () {
      final novo = AppUser(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        papel: Papel.aluno,
        turma: '9 ano B',
        criadoEm: agora,
        atualizadoEm: agora,
      );

      expect(novo.paraLinha(senhaHash: 'h', salt: 's').containsKey('id'), isFalse);
    });
  });

  group('AppUser.deLinha', () {
    test('reconstroi o usuario a partir da linha', () {
      final linha = <String, Object?>{
        'id': 7,
        'nome': 'Joao Santos',
        'email': 'joao@email.com',
        'usuario': 'joaosantos',
        'papel': 'aluno',
        'escola': null,
        'turma': '9 ano B',
        'avatar': null,
        'criado_em': '2026-07-31T12:30:00.000Z',
        'atualizado_em': '2026-07-31T12:30:00.000Z',
      };

      final user = AppUser.deLinha(linha);

      expect(user.id, 7);
      expect(user.papel, Papel.aluno);
      expect(user.turma, '9 ano B');
      expect(user.escola, isNull);
      expect(user.criadoEm, agora);
    });

    test('ida e volta preserva os campos', () {
      final original = professor();
      final linha = original.paraLinha(senhaHash: 'h', salt: 's')
        ..putIfAbsent('id', () => original.id);

      final voltou = AppUser.deLinha(linha);

      expect(voltou.nome, original.nome);
      expect(voltou.email, original.email);
      expect(voltou.usuario, original.usuario);
      expect(voltou.papel, original.papel);
      expect(voltou.escola, original.escola);
    });
  });

  group('AppUser.copiarCom', () {
    test('troca so o que foi passado', () {
      final novo = professor().copiarCom(email: 'novo@escola.com');

      expect(novo.email, 'novo@escola.com');
      expect(novo.nome, 'Maria Silva');
      expect(novo.id, 1);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/data/app_user_test.dart
```
Esperado: falha de compilação — `papel.dart` e `app_user.dart` não existem.

- [ ] **Step 3: Implementar o enum**

Criar `mobile/lib/data/models/papel.dart`:

```dart
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
```

- [ ] **Step 4: Implementar o modelo**

Criar `mobile/lib/data/models/app_user.dart`:

```dart
import 'papel.dart';

/// Usuario do app.
///
/// Nao carrega hash nem salt de proposito: o que sai do repositorio para a
/// interface nao deve ter como vazar credencial. O hash entra por parametro
/// em [paraLinha] e fica so no banco.
class AppUser {
  const AppUser({
    this.id,
    required this.nome,
    required this.email,
    required this.usuario,
    required this.papel,
    this.escola,
    this.turma,
    this.avatar,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final int? id;
  final String nome;
  final String email;
  final String usuario;
  final Papel papel;
  final String? escola;
  final String? turma;
  final String? avatar;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Map<String, Object?> paraLinha({
    required String senhaHash,
    required String salt,
  }) {
    return <String, Object?>{
      'nome': nome,
      'email': email,
      'usuario': usuario,
      'senha_hash': senhaHash,
      'salt': salt,
      'papel': papel.valor,
      'escola': escola,
      'turma': turma,
      'avatar': avatar,
      'criado_em': criadoEm.toUtc().toIso8601String(),
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

  static AppUser deLinha(Map<String, Object?> linha) {
    return AppUser(
      id: linha['id'] as int?,
      nome: linha['nome'] as String,
      email: linha['email'] as String,
      usuario: linha['usuario'] as String,
      papel: Papel.dePersistencia(linha['papel'] as String),
      escola: linha['escola'] as String?,
      turma: linha['turma'] as String?,
      avatar: linha['avatar'] as String?,
      criadoEm: DateTime.parse(linha['criado_em'] as String),
      atualizadoEm: DateTime.parse(linha['atualizado_em'] as String),
    );
  }

  AppUser copiarCom({
    String? nome,
    String? email,
    String? usuario,
    String? escola,
    String? turma,
    String? avatar,
    DateTime? atualizadoEm,
  }) {
    return AppUser(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      usuario: usuario ?? this.usuario,
      papel: papel,
      escola: escola ?? this.escola,
      turma: turma ?? this.turma,
      avatar: avatar ?? this.avatar,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
```

`DateTime.parse` devolve um `DateTime` em UTC quando a string termina em `Z`, então o teste de ida e volta compara igual sem conversão extra.

- [ ] **Step 5: Implementar as exceções**

Criar `mobile/lib/data/repositories/erros.dart`:

```dart
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
```

- [ ] **Step 6: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/data/app_user_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/data mobile/test/data
git commit -m "feat: adiciona modelo de usuario, papel e erros de dominio

AppUser nao carrega hash nem salt: o hash entra por parametro em paraLinha
e nao volta do banco para a interface. Datas gravadas em ISO-8601 UTC,
porque sqflite nao tem tipo de data. Erros sao selados para o controlador
tratar por switch exaustivo."
```

---

### Task 6: `AppDatabase`

**Files:**
- Create: `mobile/lib/data/db/app_database.dart`
- Create: `mobile/test/support/db_de_teste.dart`
- Test: `mobile/test/data/app_database_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces:
  - `class AppDatabase` com `static const int versaoAtual = 1`, `static Future<AppDatabase> abrir({String? caminho})`, `Database get db`, `Future<void> fechar()`.
  - `mobile/test/support/db_de_teste.dart` com `Future<AppDatabase> abrirBancoDeTeste()` — usado por todo teste de repositório daqui em diante.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/data/app_database_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;

  setUp(() async => banco = await abrirBancoDeTeste());
  tearDown(() async => banco.fechar());

  group('AppDatabase', () {
    test('abre na versao atual', () async {
      expect(await banco.db.getVersion(), AppDatabase.versaoAtual);
    });

    test('cria as tabelas do ciclo 1', () async {
      final tabelas = await banco.db.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );
      final nomes = tabelas.map((t) => t['name']).toList();

      expect(nomes, contains('users'));
      expect(nomes, contains('login_attempts'));
    });

    test('recusa papel fora de professor e aluno', () async {
      expect(
        () => banco.db.insert('users', {
          'nome': 'Fulano',
          'email': 'fulano@x.com',
          'usuario': 'fulano',
          'senha_hash': 'h',
          'salt': 's',
          'papel': 'admin',
          'criado_em': '2026-07-31T12:00:00.000Z',
          'atualizado_em': '2026-07-31T12:00:00.000Z',
        }),
        throwsA(anything),
      );
    });

    test('recusa e-mail repetido', () async {
      Map<String, Object?> linha(String usuario) => {
            'nome': 'Fulano',
            'email': 'fulano@x.com',
            'usuario': usuario,
            'senha_hash': 'h',
            'salt': 's',
            'papel': 'aluno',
            'criado_em': '2026-07-31T12:00:00.000Z',
            'atualizado_em': '2026-07-31T12:00:00.000Z',
          };

      await banco.db.insert('users', linha('fulano'));

      expect(() => banco.db.insert('users', linha('outro')), throwsA(anything));
    });

    test('recusa nome de usuario repetido', () async {
      Map<String, Object?> linha(String email) => {
            'nome': 'Fulano',
            'email': email,
            'usuario': 'fulano',
            'senha_hash': 'h',
            'salt': 's',
            'papel': 'aluno',
            'criado_em': '2026-07-31T12:00:00.000Z',
            'atualizado_em': '2026-07-31T12:00:00.000Z',
          };

      await banco.db.insert('users', linha('a@x.com'));

      expect(() => banco.db.insert('users', linha('b@x.com')), throwsA(anything));
    });
  });
}
```

- [ ] **Step 2: Escrever o apoio de teste**

Criar `mobile/test/support/db_de_teste.dart`:

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';

/// Abre um banco novo em memoria, com o mesmo schema do app.
///
/// `sqfliteFfiInit` e `databaseFactory` sao globais e idempotentes, entao
/// podem ser chamados a cada teste sem vazamento entre eles.
Future<AppDatabase> abrirBancoDeTeste() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return AppDatabase.abrir(caminho: inMemoryDatabasePath);
}
```

- [ ] **Step 3: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/data/app_database_test.dart
```
Esperado: falha de compilação — `app_database.dart` não existe.

- [ ] **Step 4: Implementar**

Criar `mobile/lib/data/db/app_database.dart`:

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Banco local do app.
///
/// A versao sobe a cada ciclo; `onUpgrade` acrescenta tabela sem apagar o
/// que ja existe. Ciclo 1 e a versao 1.
class AppDatabase {
  AppDatabase._(this._db);

  static const int versaoAtual = 1;
  static const String _arquivo = 'bncc_play.db';

  final Database _db;

  Database get db => _db;

  static Future<AppDatabase> abrir({String? caminho}) async {
    final destino = caminho ?? p.join(await getDatabasesPath(), _arquivo);

    final banco = await openDatabase(
      destino,
      version: versaoAtual,
      onConfigure: (db) async {
        // Fora do onConfigure a constraint de chave estrangeira fica
        // desligada no SQLite, e as tabelas dos ciclos seguintes dependem
        // dela.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async => _criarVersao1(db),
      onUpgrade: (db, anterior, atual) async {
        // Ciclo 1 nao tem migracao anterior. Os ciclos seguintes
        // acrescentam aqui, em degraus de uma versao.
      },
    );

    return AppDatabase._(banco);
  }

  static Future<void> _criarVersao1(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        nome          TEXT    NOT NULL,
        email         TEXT    NOT NULL UNIQUE,
        usuario       TEXT    NOT NULL UNIQUE,
        senha_hash    TEXT    NOT NULL,
        salt          TEXT    NOT NULL,
        papel         TEXT    NOT NULL CHECK (papel IN ('professor', 'aluno')),
        escola        TEXT,
        turma         TEXT,
        avatar        TEXT,
        criado_em     TEXT    NOT NULL,
        atualizado_em TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE login_attempts (
        email         TEXT PRIMARY KEY,
        falhas        INTEGER NOT NULL DEFAULT 0,
        bloqueado_ate TEXT
      )
    ''');
  }

  Future<void> fechar() => _db.close();
}
```

- [ ] **Step 5: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/data/app_database_test.dart
```
Esperado: todos passando. Se der `MissingPluginException`, é sinal de que o teste não passou por `abrirBancoDeTeste` — o `databaseFactory` do ffi tem de ser instalado antes de qualquer abertura.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/data/db mobile/test/data/app_database_test.dart mobile/test/support
git commit -m "feat: adiciona banco local em sqflite

Schema da versao 1 com users e login_attempts, papel restrito por CHECK e
unicidade em email e usuario. Chave estrangeira ligada no onConfigure para
os ciclos seguintes. Testes rodam o mesmo schema em memoria via
sqflite_common_ffi."
```

---

### Task 7: `UserRepository` — CT03, CT04, CT11, CT12 funcionais

**Files:**
- Create: `mobile/lib/data/repositories/user_repository.dart`
- Test: `mobile/test/data/user_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `PasswordHasher`, `SenhaCifrada`, `Sanitizer`, `AppUser`, `Papel`, exceções de `erros.dart`.
- Produces: `class UserRepository` com `UserRepository({required AppDatabase banco, PasswordHasher hasher = const PasswordHasher(), DateTime Function() agora = DateTime.now})` e os métodos:
  - `Future<AppUser> cadastrar({required String nome, required String email, required String usuario, required String senha, required Papel papel, String? escola, String? turma})`
  - `Future<AppUser?> porEmail(String email)`
  - `Future<AppUser?> porId(int id)`
  - `Future<AppUser> atualizar(AppUser usuario)`

`agora` é injetável para os testes de expiração e bloqueio controlarem o relógio sem `sleep`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/data/user_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/erros.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;
  late UserRepository repo;

  setUp(() async {
    banco = await abrirBancoDeTeste();
    repo = UserRepository(
      banco: banco,
      hasher: const PasswordHasher(iteracoes: 1000),
    );
  });
  tearDown(() async => banco.fechar());

  Future<void> cadastrarProfessor() => repo.cadastrar(
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

  group('CT03 - Cadastro de Professor', () {
    test('funcional: cadastra e devolve o professor com id', () async {
      final professor = await cadastrarProfessor();

      expect(professor.id, isNotNull);
      expect(professor.nome, 'Maria Silva');
      expect(professor.email, 'professor@escola.com');
      expect(professor.papel, Papel.professor);
      expect(professor.escola, 'E.E. Monteiro Lobato');
      expect(professor.turma, isNull);
    });

    test('funcional: o professor cadastrado e encontrado por e-mail', () async {
      await cadastrarProfessor();

      final achado = await repo.porEmail('professor@escola.com');

      expect(achado, isNotNull);
      expect(achado!.usuario, 'mariasilva');
    });

    test('nao funcional: a senha nao fica em texto puro no banco', () async {
      await cadastrarProfessor();

      final linhas = await banco.db.query('users');

      expect(linhas.single['senha_hash'], isNot(contains('Professor')));
      expect(linhas.single.containsKey('senha'), isFalse);
      expect(linhas.single['salt'], isNotNull);
    });

    test('nao funcional: minimizacao, a linha so tem os campos previstos',
        () async {
      await cadastrarProfessor();

      final linha = (await banco.db.query('users')).single;

      expect(
        linha.keys.toSet(),
        {
          'id', 'nome', 'email', 'usuario', 'senha_hash', 'salt', 'papel',
          'escola', 'turma', 'avatar', 'criado_em', 'atualizado_em',
        },
      );
    });

    test('recusa e-mail ja cadastrado', () async {
      await cadastrarProfessor();

      expect(
        () => repo.cadastrar(
          nome: 'Outra Pessoa',
          email: 'professor@escola.com',
          usuario: 'outrapessoa',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Outra',
        ),
        throwsA(isA<EmailJaCadastradoException>()),
      );
    });

    test('recusa nome de usuario ja em uso', () async {
      await cadastrarProfessor();

      expect(
        () => repo.cadastrar(
          nome: 'Outra Pessoa',
          email: 'outro@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Outra',
        ),
        throwsA(isA<UsuarioJaCadastradoException>()),
      );
    });

    test('normaliza e-mail para minusculo e sem espaco', () async {
      await repo.cadastrar(
        nome: 'Maria Silva',
        email: '  Professor@Escola.COM  ',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

      expect(await repo.porEmail('professor@escola.com'), isNotNull);
    });

    test('exige escola para professor', () async {
      expect(
        () => repo.cadastrar(
          nome: 'Maria Silva',
          email: 'professor@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CT04 - Cadastro de Aluno', () {
    test('funcional: cadastra o aluno com turma', () async {
      final aluno = await repo.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      expect(aluno.papel, Papel.aluno);
      expect(aluno.turma, '9 ano B');
      expect(aluno.escola, isNull);
    });

    test('nao funcional: remove script do nome antes de gravar', () async {
      final aluno = await repo.cadastrar(
        nome: 'Joao<script>alert(1)</script>Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      expect(aluno.nome, 'JoaoSantos');
    });

    test('exige turma para aluno', () async {
      expect(
        () => repo.cadastrar(
          nome: 'Joao Santos',
          email: 'joao@email.com',
          usuario: 'joaosantos',
          senha: 'Aluno@12345',
          papel: Papel.aluno,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CT11 e CT12 - Alteracao de cadastro', () {
    test('funcional: altera o e-mail do aluno', () async {
      final aluno = await repo.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      final alterado = await repo.atualizar(
        aluno.copiarCom(email: 'joao.novo@email.com'),
      );

      expect(alterado.email, 'joao.novo@email.com');
      expect((await repo.porId(aluno.id!))!.email, 'joao.novo@email.com');
    });

    test('funcional: altera a escola do professor', () async {
      final professor = await cadastrarProfessor();

      final alterado = await repo.atualizar(
        professor.copiarCom(escola: 'E.E. Santos Dumont'),
      );

      expect(alterado.escola, 'E.E. Santos Dumont');
    });

    test('carimba atualizado_em na alteracao', () async {
      final professor = await cadastrarProfessor();

      final alterado = await repo.atualizar(
        professor.copiarCom(nome: 'Maria Silva Souza'),
      );

      expect(
        alterado.atualizadoEm.isAfter(professor.atualizadoEm) ||
            alterado.atualizadoEm.isAtSameMomentAs(professor.atualizadoEm),
        isTrue,
      );
      expect(alterado.criadoEm, professor.criadoEm);
    });

    test('recusa alteracao para e-mail de outra conta', () async {
      await cadastrarProfessor();
      final aluno = await repo.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      expect(
        () => repo.atualizar(aluno.copiarCom(email: 'professor@escola.com')),
        throwsA(isA<EmailJaCadastradoException>()),
      );
    });

    test('sanitiza o texto na alteracao', () async {
      final professor = await cadastrarProfessor();

      final alterado = await repo.atualizar(
        professor.copiarCom(escola: 'E.E. <b>Nova</b>'),
      );

      expect(alterado.escola, 'E.E. Nova');
    });

    test('recusa alteracao de usuario sem id', () async {
      final professor = await cadastrarProfessor();
      final semId = AppUserSemId.de(professor);

      expect(() => repo.atualizar(semId), throwsA(isA<ArgumentError>()));
    });
  });

  group('UserRepository.porEmail', () {
    test('devolve nulo quando nao existe', () async {
      expect(await repo.porEmail('ninguem@x.com'), isNull);
    });

    test('ignora caixa e espaco na busca', () async {
      await cadastrarProfessor();

      expect(await repo.porEmail('  PROFESSOR@escola.com '), isNotNull);
    });
  });
}
```

O teste `recusa alteracao de usuario sem id` precisa de um `AppUser` sem `id`. Acrescentar no fim do arquivo de teste, fora de `main`:

```dart
import 'package:bncc_play_mobile/data/models/app_user.dart';

/// Copia um usuario zerando o id, para exercitar o caminho de erro de
/// `atualizar`. `copiarCom` preserva o id de proposito, entao a copia e
/// feita a mao aqui.
abstract final class AppUserSemId {
  static AppUser de(AppUser origem) => AppUser(
        nome: origem.nome,
        email: origem.email,
        usuario: origem.usuario,
        papel: origem.papel,
        escola: origem.escola,
        turma: origem.turma,
        avatar: origem.avatar,
        criadoEm: origem.criadoEm,
        atualizadoEm: origem.atualizadoEm,
      );
}
```

O `import` vai junto dos outros no topo do arquivo, não no fim.

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/data/user_repository_test.dart
```
Esperado: falha de compilação — `user_repository.dart` não existe.

- [ ] **Step 3: Implementar**

Criar `mobile/lib/data/repositories/user_repository.dart`:

```dart
import 'package:sqflite/sqflite.dart';

import '../../core/security/password_hasher.dart';
import '../../core/validation/sanitizer.dart';
import '../db/app_database.dart';
import '../models/app_user.dart';
import '../models/papel.dart';
import 'erros.dart';

/// Leitura e escrita de usuario.
///
/// E aqui que o texto livre e sanitizado e que a senha vira hash. Nenhuma
/// tela chama o banco direto, entao esta e a fronteira onde as regras valem
/// mesmo que a interface seja contornada.
class UserRepository {
  UserRepository({
    required AppDatabase banco,
    this.hasher = const PasswordHasher(),
    DateTime Function() agora = DateTime.now,
  })  : _db = banco.db,
        _agora = agora;

  final Database _db;
  final PasswordHasher hasher;
  final DateTime Function() _agora;

  Future<AppUser> cadastrar({
    required String nome,
    required String email,
    required String usuario,
    required String senha,
    required Papel papel,
    String? escola,
    String? turma,
  }) async {
    final nomeLimpo = Sanitizer.limpar(nome, maxLength: 80);
    final emailLimpo = _normalizarEmail(email);
    final usuarioLimpo = Sanitizer.limpar(usuario, maxLength: 30);
    final escolaLimpa =
        papel == Papel.professor ? Sanitizer.limpar(escola, maxLength: 80) : null;
    final turmaLimpa =
        papel == Papel.aluno ? Sanitizer.limpar(turma, maxLength: 80) : null;

    if (papel == Papel.professor && (escolaLimpa == null || escolaLimpa.isEmpty)) {
      throw ArgumentError.value(escola, 'escola', 'Professor precisa de escola');
    }
    if (papel == Papel.aluno && (turmaLimpa == null || turmaLimpa.isEmpty)) {
      throw ArgumentError.value(turma, 'turma', 'Aluno precisa de turma');
    }

    await _garantirEmailLivre(emailLimpo);
    await _garantirUsuarioLivre(usuarioLimpo);

    final momento = _agora().toUtc();
    final cifrada = hasher.cifrar(senha);

    final novo = AppUser(
      nome: nomeLimpo,
      email: emailLimpo,
      usuario: usuarioLimpo,
      papel: papel,
      escola: escolaLimpa,
      turma: turmaLimpa,
      criadoEm: momento,
      atualizadoEm: momento,
    );

    final id = await _executar(
      () => _db.insert(
        'users',
        novo.paraLinha(senhaHash: cifrada.hash, salt: cifrada.salt),
      ),
    );

    return (await porId(id))!;
  }

  Future<AppUser?> porEmail(String email) async {
    final linhas = await _executar(
      () => _db.query(
        'users',
        where: 'email = ?',
        whereArgs: [_normalizarEmail(email)],
        limit: 1,
      ),
    );
    return linhas.isEmpty ? null : AppUser.deLinha(linhas.first);
  }

  Future<AppUser?> porId(int id) async {
    final linhas = await _executar(
      () => _db.query('users', where: 'id = ?', whereArgs: [id], limit: 1),
    );
    return linhas.isEmpty ? null : AppUser.deLinha(linhas.first);
  }

  Future<AppUser> atualizar(AppUser usuario) async {
    final id = usuario.id;
    if (id == null) {
      throw ArgumentError.notNull('usuario.id');
    }

    final atualizado = usuario.copiarCom(
      nome: Sanitizer.limpar(usuario.nome, maxLength: 80),
      email: _normalizarEmail(usuario.email),
      usuario: Sanitizer.limpar(usuario.usuario, maxLength: 30),
      escola: usuario.escola == null
          ? null
          : Sanitizer.limpar(usuario.escola, maxLength: 80),
      turma: usuario.turma == null
          ? null
          : Sanitizer.limpar(usuario.turma, maxLength: 80),
      atualizadoEm: _agora().toUtc(),
    );

    await _garantirEmailLivre(atualizado.email, exceto: id);
    await _garantirUsuarioLivre(atualizado.usuario, exceto: id);

    // A senha nao muda por aqui: o update lista as colunas de proposito,
    // para nao haver caminho que sobrescreva hash ou salt sem intencao.
    await _executar(
      () => _db.update(
        'users',
        {
          'nome': atualizado.nome,
          'email': atualizado.email,
          'usuario': atualizado.usuario,
          'escola': atualizado.escola,
          'turma': atualizado.turma,
          'avatar': atualizado.avatar,
          'atualizado_em': atualizado.atualizadoEm.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      ),
    );

    return (await porId(id))!;
  }

  String _normalizarEmail(String email) => email.trim().toLowerCase();

  Future<void> _garantirEmailLivre(String email, {int? exceto}) async {
    final existente = await porEmail(email);
    if (existente != null && existente.id != exceto) {
      throw const EmailJaCadastradoException();
    }
  }

  Future<void> _garantirUsuarioLivre(String usuario, {int? exceto}) async {
    final linhas = await _executar(
      () => _db.query(
        'users',
        columns: ['id'],
        where: 'usuario = ?',
        whereArgs: [usuario],
        limit: 1,
      ),
    );
    if (linhas.isNotEmpty && linhas.first['id'] != exceto) {
      throw const UsuarioJaCadastradoException();
    }
  }

  /// Falha de SQL nao chega a interface: vira erro de dominio.
  Future<T> _executar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on DatabaseException {
      throw const FalhaDePersistenciaException();
    }
  }
}
```

- [ ] **Step 4: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/data/user_repository_test.dart
```
Esperado: todos passando.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/data/repositories/user_repository.dart mobile/test/data/user_repository_test.dart
git commit -m "feat: adiciona repositorio de usuario

Cadastro, busca e alteracao com sanitizacao do texto livre, e-mail
normalizado para minusculo e unicidade conferida antes do insert para a
mensagem sair em portugues. O update lista as colunas de proposito: nao ha
caminho que sobrescreva hash ou salt sem intencao.

Cobre os testes funcionais de CT03, CT04, CT11 e CT12, e os nao funcionais
de CT03 (minimizacao) e CT04 (tratamento de entrada)."
```

---

### Task 8: `AuthRepository` e bloqueio por tentativas — CT01, CT02

**Files:**
- Create: `mobile/lib/data/repositories/auth_repository.dart`
- Test: `mobile/test/data/auth_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `UserRepository`, `PasswordHasher`, `AppUser`, exceções.
- Produces: `class AuthRepository` com `AuthRepository({required AppDatabase banco, required UserRepository usuarios, PasswordHasher hasher = const PasswordHasher(), DateTime Function() agora = DateTime.now})` e:
  - `Future<AppUser> entrar({required String email, required String senha})`
  - `static const int maxTentativas = 5`
  - `static const Duration duracaoDoBloqueio = Duration(seconds: 60)`

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/data/auth_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/auth_repository.dart';
import 'package:bncc_play_mobile/data/repositories/erros.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import '../support/db_de_teste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;
  late UserRepository usuarios;
  late AuthRepository auth;

  // Relogio controlado: sem isso o teste do bloqueio precisaria dormir 60s.
  var relogio = DateTime.utc(2026, 7, 31, 12, 0, 0);

  setUp(() async {
    relogio = DateTime.utc(2026, 7, 31, 12, 0, 0);
    banco = await abrirBancoDeTeste();
    const hasher = PasswordHasher(iteracoes: 1000);
    usuarios = UserRepository(
      banco: banco,
      hasher: hasher,
      agora: () => relogio,
    );
    auth = AuthRepository(
      banco: banco,
      usuarios: usuarios,
      hasher: hasher,
      agora: () => relogio,
    );

    await usuarios.cadastrar(
      nome: 'Maria Silva',
      email: 'professor@escola.com',
      usuario: 'mariasilva',
      senha: 'Professor@123',
      papel: Papel.professor,
      escola: 'E.E. Monteiro Lobato',
    );
  });
  tearDown(() async => banco.fechar());

  Future<void> errarSenha(int vezes) async {
    for (var i = 0; i < vezes; i++) {
      try {
        await auth.entrar(email: 'professor@escola.com', senha: 'errada123');
      } on ErroDeDominio {
        // esperado
      }
    }
  }

  group('CT01 - Efetivacao de Login do Professor', () {
    test('funcional: credenciais validas autenticam o professor', () async {
      final logado = await auth.entrar(
        email: 'professor@escola.com',
        senha: 'Professor@123',
      );

      expect(logado.nome, 'Maria Silva');
      expect(logado.papel, Papel.professor);
    });

    test('funcional: aceita e-mail com caixa e espaco diferentes', () async {
      final logado = await auth.entrar(
        email: '  PROFESSOR@Escola.com ',
        senha: 'Professor@123',
      );

      expect(logado.email, 'professor@escola.com');
    });

    test('recusa senha errada', () async {
      expect(
        () => auth.entrar(email: 'professor@escola.com', senha: 'errada123'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
    });

    test('e-mail inexistente devolve o mesmo erro da senha errada', () async {
      // Mensagem unica de proposito: distinguir os dois casos revelaria
      // quais e-mails existem no sistema.
      expect(
        () => auth.entrar(email: 'ninguem@x.com', senha: 'qualquer1'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
    });

    test('nao funcional: cinco senhas erradas bloqueiam a conta', () async {
      await errarSenha(5);

      expect(
        () => auth.entrar(email: 'professor@escola.com', senha: 'Professor@123'),
        throwsA(isA<LoginBloqueadoException>()),
      );
    });

    test('nao funcional: quatro erros ainda deixam entrar', () async {
      await errarSenha(4);

      final logado = await auth.entrar(
        email: 'professor@escola.com',
        senha: 'Professor@123',
      );

      expect(logado.nome, 'Maria Silva');
    });

    test('nao funcional: o bloqueio informa quantos segundos faltam', () async {
      await errarSenha(5);
      relogio = relogio.add(const Duration(seconds: 20));

      try {
        await auth.entrar(email: 'professor@escola.com', senha: 'Professor@123');
        fail('deveria ter bloqueado');
      } on LoginBloqueadoException catch (e) {
        expect(e.segundosRestantes, 40);
      }
    });

    test('nao funcional: passados 60 segundos o login volta a funcionar',
        () async {
      await errarSenha(5);
      relogio = relogio.add(const Duration(seconds: 61));

      final logado = await auth.entrar(
        email: 'professor@escola.com',
        senha: 'Professor@123',
      );

      expect(logado.nome, 'Maria Silva');
    });

    test('nao funcional: durante o bloqueio nem a senha certa passa', () async {
      await errarSenha(5);

      expect(
        () => auth.entrar(email: 'professor@escola.com', senha: 'Professor@123'),
        throwsA(isA<LoginBloqueadoException>()),
      );
    });

    test('login com sucesso zera o contador de falhas', () async {
      await errarSenha(4);
      await auth.entrar(email: 'professor@escola.com', senha: 'Professor@123');
      await errarSenha(4);

      final logado = await auth.entrar(
        email: 'professor@escola.com',
        senha: 'Professor@123',
      );

      expect(logado.nome, 'Maria Silva');
    });

    test('o bloqueio de uma conta nao atinge a outra', () async {
      await usuarios.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );
      await errarSenha(5);

      final aluno = await auth.entrar(
        email: 'joao@email.com',
        senha: 'Aluno@12345',
      );

      expect(aluno.papel, Papel.aluno);
    });
  });

  group('CT02 - Efetivacao de Login do Aluno', () {
    test('funcional: o aluno entra com as proprias credenciais', () async {
      await usuarios.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );

      final logado = await auth.entrar(
        email: 'joao@email.com',
        senha: 'Aluno@12345',
      );

      expect(logado.papel, Papel.aluno);
      expect(logado.turma, '9 ano B');
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/data/auth_repository_test.dart
```
Esperado: falha de compilação — `auth_repository.dart` não existe.

- [ ] **Step 3: Implementar**

Criar `mobile/lib/data/repositories/auth_repository.dart`:

```dart
import 'package:sqflite/sqflite.dart';

import '../../core/security/password_hasher.dart';
import '../db/app_database.dart';
import '../models/app_user.dart';
import 'erros.dart';
import 'user_repository.dart';

/// Autenticacao local, com bloqueio por tentativas.
///
/// O contador vive em `login_attempts`, chaveado por e-mail, e nao em
/// memoria: fechar o app nao pode ser o jeito de escapar do bloqueio.
class AuthRepository {
  AuthRepository({
    required AppDatabase banco,
    required UserRepository usuarios,
    this.hasher = const PasswordHasher(),
    DateTime Function() agora = DateTime.now,
  })  : _db = banco.db,
        _usuarios = usuarios,
        _agora = agora;

  static const int maxTentativas = 5;
  static const Duration duracaoDoBloqueio = Duration(seconds: 60);

  final Database _db;
  final UserRepository _usuarios;
  final PasswordHasher hasher;
  final DateTime Function() _agora;

  Future<AppUser> entrar({
    required String email,
    required String senha,
  }) async {
    final chave = email.trim().toLowerCase();

    final restante = await _segundosDeBloqueio(chave);
    if (restante > 0) {
      // Sai antes de olhar a senha: durante o bloqueio nem a correta passa.
      throw LoginBloqueadoException(restante);
    }

    final usuario = await _usuarios.porEmail(chave);
    if (usuario == null) {
      // Sem usuario nao ha o que contar, e a mensagem e a mesma da senha
      // errada para nao revelar quais e-mails existem.
      throw const CredenciaisInvalidasException();
    }

    final credencial = await _credencialDe(usuario.id!);
    final confere = hasher.confere(
      senha,
      hash: credencial.$1,
      salt: credencial.$2,
    );

    if (!confere) {
      await _registrarFalha(chave);
      throw const CredenciaisInvalidasException();
    }

    await _limparTentativas(chave);
    return usuario;
  }

  Future<(String, String)> _credencialDe(int id) async {
    final linhas = await _db.query(
      'users',
      columns: ['senha_hash', 'salt'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    final linha = linhas.single;
    return (linha['senha_hash'] as String, linha['salt'] as String);
  }

  Future<int> _segundosDeBloqueio(String email) async {
    final linhas = await _db.query(
      'login_attempts',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (linhas.isEmpty) return 0;

    final ate = linhas.first['bloqueado_ate'] as String?;
    if (ate == null) return 0;

    final fim = DateTime.parse(ate);
    final falta = fim.difference(_agora().toUtc()).inSeconds;
    return falta > 0 ? falta : 0;
  }

  Future<void> _registrarFalha(String email) async {
    final linhas = await _db.query(
      'login_attempts',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    final falhas = linhas.isEmpty ? 1 : (linhas.first['falhas'] as int) + 1;

    if (falhas >= maxTentativas) {
      final ate = _agora().toUtc().add(duracaoDoBloqueio);
      await _gravarTentativa(email, falhas: 0, bloqueadoAte: ate);
      return;
    }

    await _gravarTentativa(email, falhas: falhas, bloqueadoAte: null);
  }

  Future<void> _gravarTentativa(
    String email, {
    required int falhas,
    required DateTime? bloqueadoAte,
  }) {
    return _db.insert(
      'login_attempts',
      {
        'email': email,
        'falhas': falhas,
        'bloqueado_ate': bloqueadoAte?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _limparTentativas(String email) {
    return _db.delete('login_attempts', where: 'email = ?', whereArgs: [email]);
  }
}
```

- [ ] **Step 4: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/data/auth_repository_test.dart
```
Esperado: todos passando. Se `o bloqueio informa quantos segundos faltam` devolver 39 ou 41, o cálculo está arredondando: `inSeconds` trunca, e o relógio injetado não avança sozinho — conferir que `_agora` está sendo usado em vez de `DateTime.now()`.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/data/repositories/auth_repository.dart mobile/test/data/auth_repository_test.dart
git commit -m "feat: adiciona autenticacao com bloqueio por tentativas

Cinco falhas no mesmo e-mail bloqueiam por 60 segundos, contados em tabela
e nao em memoria: fechar o app nao escapa do bloqueio. Durante o bloqueio a
senha nem chega a ser conferida. E-mail inexistente devolve a mesma
mensagem da senha errada, para nao revelar quais contas existem.

Cobre CT01 funcional e nao funcional, e CT02 funcional."
```

---

### Task 9: `SessionScope` e `Permission` — CT12 não funcional

**Files:**
- Create: `mobile/lib/core/session/session_scope.dart`
- Create: `mobile/lib/core/security/permission.dart`
- Test: `mobile/test/unit/session_scope_test.dart`

**Interfaces:**
- Consumes: `AppUser`, `Papel`, `SessaoExpiradaException`.
- Produces:
  - `class SessionScope extends ChangeNotifier` com `SessionScope({DateTime Function() agora = DateTime.now})`, `static const Duration tempoDeInatividade = Duration(minutes: 30)`, `AppUser? get usuario`, `Papel? get papel`, `bool get autenticado`, `void abrir(AppUser)`, `void registrarAtividade()`, `void encerrar()`, `AppUser exigirUsuario()`.
  - `abstract final class Permission` com `static void requireRole(SessionScope sessao, Papel esperado)`.
  - `class PermissionDeniedException extends ErroDeDominio`.

`autenticado` é falso quando a sessão expirou — expirar é um cálculo sobre `ultimaAtividade`, não um cronômetro. Um `Timer` daria trabalho de descarte e não é observável em teste.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/unit/session_scope_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/security/permission.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/erros.dart';

void main() {
  var relogio = DateTime.utc(2026, 7, 31, 12, 0, 0);

  AppUser usuarioDe(Papel papel) => AppUser(
        id: 1,
        nome: papel == Papel.professor ? 'Maria Silva' : 'Joao Santos',
        email: 'x@y.com',
        usuario: 'x',
        papel: papel,
        escola: papel == Papel.professor ? 'E.E. Monteiro Lobato' : null,
        turma: papel == Papel.aluno ? '9 ano B' : null,
        criadoEm: relogio,
        atualizadoEm: relogio,
      );

  late SessionScope sessao;

  setUp(() {
    relogio = DateTime.utc(2026, 7, 31, 12, 0, 0);
    sessao = SessionScope(agora: () => relogio);
  });

  group('SessionScope', () {
    test('comeca sem usuario e nao autenticada', () {
      expect(sessao.usuario, isNull);
      expect(sessao.papel, isNull);
      expect(sessao.autenticado, isFalse);
    });

    test('abrir guarda o usuario e autentica', () {
      sessao.abrir(usuarioDe(Papel.professor));

      expect(sessao.usuario!.nome, 'Maria Silva');
      expect(sessao.papel, Papel.professor);
      expect(sessao.autenticado, isTrue);
    });

    test('abrir avisa os ouvintes', () {
      var avisos = 0;
      sessao.addListener(() => avisos++);

      sessao.abrir(usuarioDe(Papel.aluno));

      expect(avisos, 1);
    });

    test('encerrar limpa o usuario e avisa', () {
      sessao.abrir(usuarioDe(Papel.aluno));
      var avisos = 0;
      sessao.addListener(() => avisos++);

      sessao.encerrar();

      expect(sessao.usuario, isNull);
      expect(sessao.autenticado, isFalse);
      expect(avisos, 1);
    });
  });

  group('CT12 - expiracao de sessao', () {
    test('nao funcional: 29 minutos parado ainda vale', () {
      sessao.abrir(usuarioDe(Papel.professor));
      relogio = relogio.add(const Duration(minutes: 29));

      expect(sessao.autenticado, isTrue);
    });

    test('nao funcional: 31 minutos parado expira', () {
      sessao.abrir(usuarioDe(Papel.professor));
      relogio = relogio.add(const Duration(minutes: 31));

      expect(sessao.autenticado, isFalse);
    });

    test('nao funcional: atividade renova o prazo', () {
      sessao.abrir(usuarioDe(Papel.professor));
      relogio = relogio.add(const Duration(minutes: 20));
      sessao.registrarAtividade();
      relogio = relogio.add(const Duration(minutes: 20));

      expect(sessao.autenticado, isTrue);
    });

    test('nao funcional: exigirUsuario lanca quando a sessao expirou', () {
      sessao.abrir(usuarioDe(Papel.professor));
      relogio = relogio.add(const Duration(minutes: 31));

      expect(() => sessao.exigirUsuario(), throwsA(isA<SessaoExpiradaException>()));
    });

    test('exigirUsuario devolve o usuario quando a sessao vale', () {
      sessao.abrir(usuarioDe(Papel.aluno));

      expect(sessao.exigirUsuario().nome, 'Joao Santos');
    });

    test('exigirUsuario lanca quando nunca houve login', () {
      expect(() => sessao.exigirUsuario(), throwsA(isA<SessaoExpiradaException>()));
    });
  });

  group('Permission.requireRole', () {
    test('deixa passar o papel esperado', () {
      sessao.abrir(usuarioDe(Papel.professor));

      expect(() => Permission.requireRole(sessao, Papel.professor), returnsNormally);
    });

    test('recusa o papel errado', () {
      sessao.abrir(usuarioDe(Papel.aluno));

      expect(
        () => Permission.requireRole(sessao, Papel.professor),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('recusa quando nao ha sessao', () {
      expect(
        () => Permission.requireRole(sessao, Papel.professor),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/unit/session_scope_test.dart
```
Esperado: falha de compilação — `session_scope.dart` e `permission.dart` não existem.

- [ ] **Step 3: Implementar a sessão**

Criar `mobile/lib/core/session/session_scope.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/erros.dart';

/// Usuario logado e prazo de inatividade.
///
/// A expiracao e calculada sobre [_ultimaAtividade] em vez de tocada por um
/// Timer: sem cronometro nao ha o que descartar, e o teste controla o
/// relogio em vez de esperar meia hora.
class SessionScope extends ChangeNotifier {
  SessionScope({DateTime Function() agora = DateTime.now}) : _agora = agora;

  static const Duration tempoDeInatividade = Duration(minutes: 30);

  final DateTime Function() _agora;

  AppUser? _usuario;
  DateTime? _ultimaAtividade;

  AppUser? get usuario => _expirou ? null : _usuario;

  Papel? get papel => usuario?.papel;

  bool get autenticado => usuario != null;

  bool get _expirou {
    final marca = _ultimaAtividade;
    if (_usuario == null || marca == null) return true;
    return _agora().difference(marca) > tempoDeInatividade;
  }

  void abrir(AppUser usuario) {
    _usuario = usuario;
    _ultimaAtividade = _agora();
    notifyListeners();
  }

  /// Renova o prazo. Chamado a cada acao que passa por um repositorio.
  void registrarAtividade() {
    if (_usuario == null) return;
    _ultimaAtividade = _agora();
  }

  void encerrar() {
    _usuario = null;
    _ultimaAtividade = null;
    notifyListeners();
  }

  /// Usuario logado, ou erro. Usar onde a tela nao faz sentido sem sessao.
  AppUser exigirUsuario() {
    final atual = usuario;
    if (atual == null) throw const SessaoExpiradaException();
    return atual;
  }
}
```

- [ ] **Step 4: Implementar a permissão**

Criar `mobile/lib/core/security/permission.dart`:

```dart
import '../../data/models/papel.dart';
import '../../data/repositories/erros.dart';
import '../session/session_scope.dart';

class PermissionDeniedException extends ErroDeDominio {
  const PermissionDeniedException()
      : super('Voce nao tem permissao para esta acao');
}

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
```

- [ ] **Step 5: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/unit/session_scope_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/core/session mobile/lib/core/security/permission.dart mobile/test/unit/session_scope_test.dart
git commit -m "feat: adiciona sessao com expiracao e guarda de papel

A sessao expira por calculo sobre a ultima atividade, nao por Timer: nada a
descartar e o teste controla o relogio. Permission.requireRole lanca
PermissionDenied para ser chamada do repositorio, nao so da tela.

Cobre o teste nao funcional de CT12 e prepara os de CT10 e CT17."
```

---

### Task 10: Rotas, raiz do app e splash

**Files:**
- Create: `mobile/lib/core/routes.dart`
- Create: `mobile/lib/features/auth/splash_screen.dart`
- Modify: `mobile/lib/main.dart`
- Test: `mobile/test/features/splash_screen_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `UserRepository`, `AuthRepository`, `SessionScope`, `AppTheme`.
- Produces: `abstract final class Rotas` com as constantes `splash`, `login`, `registerType`, `registerTeacher`, `registerStudent`, `forgotPassword`, `homeTeacher`, `homeStudent`, `profileTeacher`, `profileStudent`, `editProfile` (`'/'`, `'/login'`, `'/cadastro'`, `'/cadastro/professor'`, `'/cadastro/aluno'`, `'/esqueci-senha'`, `'/professor'`, `'/aluno'`, `'/professor/perfil'`, `'/aluno/perfil'`, `'/perfil/editar'`) e `static Map<String, WidgetBuilder> tabela()`. Também `class BnccPlayApp extends StatelessWidget` com `const BnccPlayApp({super.key, required this.banco})`.

As telas ainda não existem quando esta tarefa roda. A tabela de rotas nasce apontando só para splash e login (que já existe); cada tarefa seguinte acrescenta a sua linha. Isso mantém o app compilando entre tarefas.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/splash_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/features/auth/splash_screen.dart';

Future<void> pumpSplash(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        Rotas.registerType: (_) => const Scaffold(body: Text('escolha de perfil')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SplashScreen - conteudo', () {
    testWidgets('mostra a marca e a chamada', (tester) async {
      await pumpSplash(tester);

      expect(find.text('BNCC Play'), findsOneWidget);
      expect(
        find.text('Aprenda computação jogando'),
        findsOneWidget,
      );
    });

    testWidgets('mostra as duas acoes', (tester) async {
      await pumpSplash(tester);

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });
  });

  group('SplashScreen - navegacao', () {
    testWidgets('Entrar leva ao login', (tester) async {
      await pumpSplash(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });

    testWidgets('Criar conta leva a escolha de perfil', (tester) async {
      await pumpSplash(tester);

      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('escolha de perfil'), findsOneWidget);
    });
  });

  group('SplashScreen - layout', () {
    testWidgets('cabe em telefone estreito sem estourar', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/splash_screen_test.dart
```
Esperado: falha de compilação — `routes.dart` e `splash_screen.dart` não existem.

- [ ] **Step 3: Implementar as rotas**

Criar `mobile/lib/core/routes.dart`:

```dart
import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/splash_screen.dart';

/// Nomes de rota do app.
///
/// A tabela cresce a cada tarefa do ciclo; manter aqui a lista inteira
/// evita string de rota espalhada pelas telas.
abstract final class Rotas {
  static const splash = '/';
  static const login = '/login';
  static const registerType = '/cadastro';
  static const registerTeacher = '/cadastro/professor';
  static const registerStudent = '/cadastro/aluno';
  static const forgotPassword = '/esqueci-senha';
  static const homeTeacher = '/professor';
  static const homeStudent = '/aluno';
  static const profileTeacher = '/professor/perfil';
  static const profileStudent = '/aluno/perfil';
  static const editProfile = '/perfil/editar';

  static Map<String, WidgetBuilder> tabela() => <String, WidgetBuilder>{
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
      };
}
```

- [ ] **Step 4: Implementar a splash**

A referência visual é `SplashScreen` em `App.tsx:190-237`: fundo com o gradiente roxo ocupando a tela inteira, ícone de controle em caixa translúcida, marca em Poppins ExtraBold, chamada em Inter, dois botões empilhados.

Criar `mobile/lib/features/auth/splash_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';

/// Porta de entrada do app: leva ao login ou ao cadastro.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: ConstrainedBox(
                // Ocupa a altura toda quando sobra espaco e vira rolagem
                // quando falta, em vez de estourar.
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 96,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BNCC Play',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerTitle.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aprenda computação jogando',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerSubtitle,
                    ),
                    const SizedBox(height: 48),
                    _BotaoClaro(
                      label: 'Entrar',
                      icon: Icons.login,
                      onPressed: () =>
                          Navigator.pushNamed(context, Rotas.login),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Criar conta',
                      icon: Icons.person_add,
                      variant: AppButtonVariant.ghost,
                      onPressed: () =>
                          Navigator.pushNamed(context, Rotas.registerType),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botao branco sobre o gradiente. O AppButton primario e roxo e sumiria
/// no fundo, entao esta variante existe so aqui.
class _BotaoClaro extends StatelessWidget {
  const _BotaoClaro({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.purple),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTheme.buttonLabel.copyWith(color: AppColors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Ligar a raiz do app**

Substituir todo o conteúdo de `mobile/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'core/session/session_scope.dart';
import 'core/theme/app_theme.dart';
import 'data/db/app_database.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final banco = await AppDatabase.abrir();
  runApp(BnccPlayApp(banco: banco));
}

class BnccPlayApp extends StatelessWidget {
  const BnccPlayApp({super.key, required this.banco});

  final AppDatabase banco;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: banco),
        Provider<UserRepository>(
          create: (_) => UserRepository(banco: banco),
        ),
        ProxyProvider<UserRepository, AuthRepository>(
          update: (_, usuarios, __) =>
              AuthRepository(banco: banco, usuarios: usuarios),
        ),
        ChangeNotifierProvider<SessionScope>(create: (_) => SessionScope()),
      ],
      child: MaterialApp(
        title: 'BNCC Play',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: Rotas.splash,
        routes: Rotas.tabela(),
      ),
    );
  }
}
```

- [ ] **Step 6: Rodar tudo e conferir que passa**

```bash
cd mobile && flutter analyze && flutter test
```
Esperado: `No issues found.` e toda a suíte passando, incluindo os testes de login da Task 1.

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/core/routes.dart mobile/lib/features/auth/splash_screen.dart mobile/lib/main.dart mobile/test/features/splash_screen_test.dart
git commit -m "feat: adiciona splash, tabela de rotas e injecao na raiz

O app abre o banco antes de subir a interface e injeta repositorios e
sessao por provider. A tabela de rotas nasce com splash e login; cada tela
seguinte acrescenta a sua linha."
```

---

### Task 11: Login com autenticação real — CT01, CT02

Substitui os avisos "em desenvolvimento" por autenticação e navegação. Os testes que checavam o SnackBar de desenvolvimento são reescritos; isso é a mudança esperada, não regressão.

**Files:**
- Create: `mobile/lib/features/auth/login_controller.dart`
- Modify: `mobile/lib/features/auth/login_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/login_screen_test.dart` (reescrita parcial)
- Create: `mobile/test/support/fakes.dart`

**Interfaces:**
- Consumes: `AuthRepository`, `SessionScope`, `Validators`, `Rotas`, exceções.
- Produces:
  - `class LoginController extends ChangeNotifier` com `LoginController({required AuthRepository auth, required SessionScope sessao})`, os campos `String? erroEmail`, `String? erroSenha`, `String? erroGeral`, `bool carregando`, `int segundosBloqueado` e `Future<AppUser?> entrar({required String email, required String senha})`.
  - `mobile/test/support/fakes.dart` com `Future<({AuthRepository auth, UserRepository usuarios, AppDatabase banco, SessionScope sessao})> ambienteDeTeste()` — monta banco em memória, repositórios com hasher barato e sessão, para os testes de widget das próximas tarefas.

- [ ] **Step 1: Escrever o apoio compartilhado dos testes de tela**

Criar `mobile/test/support/fakes.dart`:

```dart
import 'package:bncc_play_mobile/core/security/password_hasher.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/repositories/auth_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';

import 'db_de_teste.dart';

typedef AmbienteDeTeste = ({
  AppDatabase banco,
  UserRepository usuarios,
  AuthRepository auth,
  SessionScope sessao,
});

/// Monta o conjunto que uma tela precisa: banco em memoria, repositorios
/// com hasher barato e sessao limpa. Quem chama fecha o banco no tearDown.
Future<AmbienteDeTeste> ambienteDeTeste() async {
  final banco = await abrirBancoDeTeste();
  const hasher = PasswordHasher(iteracoes: 1000);
  final usuarios = UserRepository(banco: banco, hasher: hasher);
  final auth = AuthRepository(banco: banco, usuarios: usuarios, hasher: hasher);
  return (
    banco: banco,
    usuarios: usuarios,
    auth: auth,
    sessao: SessionScope(),
  );
}
```

- [ ] **Step 2: Reescrever o teste da tela de login**

Substituir `mobile/test/features/login_screen_test.dart`. Os grupos *conteudo*, *validacao* e *layout* que já existem ficam como estão — eles descrevem a tela, não o destino dos botões. Trocar o helper `pumpLogin` e o grupo *acoes* por:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/auth_repository.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/auth/login_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

/// Monta a tela num viewport de telefone real (390x844, o frame do Figma),
/// com os repositorios de verdade sobre banco em memoria.
Future<void> pumpLogin(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        Provider<AuthRepository>.value(value: ambiente.auth),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LoginScreen(),
        routes: {
          Rotas.homeTeacher: (_) => const Scaffold(body: Text('home do professor')),
          Rotas.homeStudent: (_) => const Scaffold(body: Text('home do aluno')),
          Rotas.registerType: (_) => const Scaffold(body: Text('escolha de perfil')),
          Rotas.forgotPassword: (_) => const Scaffold(body: Text('esqueci a senha')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  Future<void> cadastrarProfessor() => ambiente.usuarios.cadastrar(
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );

  Future<void> preencher(
    WidgetTester tester, {
    required String email,
    required String senha,
  }) async {
    await tester.enterText(find.byType(TextField).first, email);
    await tester.enterText(find.byType(TextField).last, senha);
  }

  // ... aqui continuam os grupos 'LoginScreen - conteudo',
  // 'LoginScreen - validacao' e 'LoginScreen - layout' que ja existem ...

  group('CT01 - Efetivacao de Login do Professor', () {
    testWidgets('funcional: credenciais validas abrem a home do professor',
        (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      await preencher(
        tester,
        email: 'professor@escola.com',
        senha: 'Professor@123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('home do professor'), findsOneWidget);
      expect(ambiente.sessao.usuario!.nome, 'Maria Silva');
    });

    testWidgets('senha errada mostra o erro e nao navega', (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      await preencher(
        tester,
        email: 'professor@escola.com',
        senha: 'errada123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
      expect(find.text('home do professor'), findsNothing);
      expect(ambiente.sessao.autenticado, isFalse);
    });

    testWidgets('nao funcional: apos cinco erros a tela avisa o bloqueio',
        (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      for (var i = 0; i < 5; i++) {
        await preencher(
          tester,
          email: 'professor@escola.com',
          senha: 'errada123',
        );
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();
      }

      expect(
        find.textContaining('Muitas tentativas'),
        findsOneWidget,
      );
    });

    testWidgets('nao funcional: durante o bloqueio a senha certa nao entra',
        (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      for (var i = 0; i < 5; i++) {
        await preencher(
          tester,
          email: 'professor@escola.com',
          senha: 'errada123',
        );
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();
      }

      await preencher(
        tester,
        email: 'professor@escola.com',
        senha: 'Professor@123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('home do professor'), findsNothing);
      expect(find.textContaining('Muitas tentativas'), findsOneWidget);
    });

    testWidgets('a senha nunca aparece na tela', (tester) async {
      await cadastrarProfessor();
      await pumpLogin(tester);

      await preencher(
        tester,
        email: 'professor@escola.com',
        senha: 'errada123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('errada123'), findsNothing);
    });
  });

  group('CT02 - Efetivacao de Login do Aluno', () {
    testWidgets('funcional: o aluno cai na home do aluno', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '9 ano B',
      );
      await pumpLogin(tester);

      await preencher(tester, email: 'joao@email.com', senha: 'Aluno@12345');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('home do aluno'), findsOneWidget);
      expect(ambiente.sessao.papel, Papel.aluno);
    });
  });

  group('LoginScreen - acoes secundarias', () {
    testWidgets('Criar conta leva a escolha de perfil', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('escolha de perfil'), findsOneWidget);
    });

    testWidgets('Esqueci minha senha leva a recuperacao', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      expect(find.text('esqueci a senha'), findsOneWidget);
    });
  });
}
```

O botão "Entrar como Aluno" do protótipo sai da tela: com um único formulário que decide o destino pelo papel do usuário, ele não tem função e o teste que o exercitava vira ruído. Remover também a asserção correspondente no grupo *conteudo* e o `_OuDivider` que só existia para separá-lo.

- [ ] **Step 3: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/login_screen_test.dart
```
Esperado: falha de compilação — `login_controller.dart` não existe e a tela ainda não lê os providers.

- [ ] **Step 4: Implementar o controlador**

Criar `mobile/lib/features/auth/login_controller.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../core/session/session_scope.dart';
import '../../core/validation/validators.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/erros.dart';

/// Estado da tela de login.
///
/// Traduz os erros de dominio em mensagem de tela e abre a sessao no
/// sucesso. A tela nao conhece repositorio nem excecao.
class LoginController extends ChangeNotifier {
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

  Future<AppUser?> entrar({
    required String email,
    required String senha,
  }) async {
    // Campo vazio e cobrado sem ir ao banco, com a mesma mensagem que a
    // tela ja usava antes desta tarefa.
    erroEmail = email.trim().isEmpty ? 'Informe seu e-mail' : null;
    erroSenha = senha.isEmpty ? 'Informe sua senha' : null;
    erroGeral = null;

    if (erroEmail != null || erroSenha != null) {
      notifyListeners();
      return null;
    }

    carregando = true;
    notifyListeners();

    try {
      final usuario = await _auth.entrar(email: email, senha: senha);
      _sessao.abrir(usuario);
      segundosBloqueado = 0;
      return usuario;
    } on LoginBloqueadoException catch (e) {
      segundosBloqueado = e.segundosRestantes;
      erroGeral =
          'Muitas tentativas. Tente novamente em ${e.segundosRestantes}s';
      return null;
    } on ErroDeDominio catch (e) {
      erroGeral = e.mensagem;
      return null;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    if (erroGeral == null && erroEmail == null && erroSenha == null) return;
    erroEmail = null;
    erroSenha = null;
    erroGeral = null;
    notifyListeners();
  }
}
```

`LoginBloqueadoException` vem antes de `ErroDeDominio` no `catch` porque é subclasse dele — invertida a ordem, o bloqueio cairia no genérico e a contagem de segundos se perderia.

- [ ] **Step 5: Ligar a tela ao controlador**

Em `mobile/lib/features/auth/login_screen.dart`:

1. Acrescentar aos imports:

```dart
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_controller.dart';
```

2. No `_LoginScreenState`, trocar os campos `_emailError` e `_senhaError` por um controlador criado no `initState`:

```dart
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
      auth: context.read<AuthRepository>(),
      sessao: context.read<SessionScope>(),
    )..addListener(_aoMudar);
    _emailController.addListener(_controller.limparErro);
    _senhaController.addListener(_controller.limparErro);
  }

  void _aoMudar() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_aoMudar);
    _controller.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
```

3. Trocar `_entrar` por:

```dart
  Future<void> _entrar() async {
    final usuario = await _controller.entrar(
      email: _emailController.text,
      senha: _senhaController.text,
    );
    if (usuario == null || !mounted) return;

    final destino = usuario.papel == Papel.professor
        ? Rotas.homeTeacher
        : Rotas.homeStudent;
    Navigator.pushReplacementNamed(context, destino);
  }
```

`pushReplacementNamed` e não `pushNamed`: depois de entrar, voltar para o login com o botão do sistema não deve ser possível.

4. Nos dois `AppTextField`, trocar `errorText: _emailError` por `errorText: _controller.erroEmail` e `errorText: _senhaError` por `errorText: _controller.erroSenha`.

5. Acima do botão Entrar, mostrar o erro geral:

```dart
                    if (_controller.erroGeral != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _controller.erroGeral!,
                                style: AppTheme.fieldError,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
```

6. Trocar os destinos das ações secundárias:

```dart
                        onTap: () =>
                            Navigator.pushNamed(context, Rotas.forgotPassword),
```

```dart
                          onTap: () =>
                              Navigator.pushNamed(context, Rotas.registerType),
```

7. Remover o `AppButton` "Entrar como Aluno", o `_OuDivider` e a classe `_OuDivider`, junto com o `SizedBox` que os separava. Remover também o método `_avisar` e o `_clearErrorWhenTyping`, agora cobertos por `LoginController.limparErro`.

- [ ] **Step 6: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/login_screen_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.` O golden do login vai quebrar — a tela perdeu um botão e um divisor. Regerar e conferir a imagem a olho:

```bash
cd mobile && flutter test --update-goldens test/features/login_golden_test.dart
```

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/features/auth mobile/test/features mobile/test/support/fakes.dart mobile/test/goldens
git commit -m "feat: liga a tela de login a autenticacao real

O login agora consulta o repositorio, abre a sessao e navega para a home do
papel do usuario. O bloqueio por tentativas aparece em tela com a contagem
de segundos. Sai o botao Entrar como Aluno: com um formulario unico que
decide o destino pelo papel, ele nao tinha funcao.

Cobre CT01 funcional e nao funcional, e CT02 funcional."
```

---

### Task 12: Escolha de perfil

**Files:**
- Create: `mobile/lib/core/widgets/top_bar.dart`
- Create: `mobile/lib/features/auth/register_type_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/register_type_screen_test.dart`

**Interfaces:**
- Consumes: `Rotas`, `AppColors`, `AppTheme`.
- Produces: `class TopBar extends StatelessWidget` com `const TopBar({super.key, this.titulo, this.onVoltar})`; `class RegisterTypeScreen extends StatelessWidget`.

Referência visual: `App.tsx:279-313` — cabeçalho roxo com "Quem é você?", dois cartões brancos com emoji em caixa colorida, título, descrição e a linha "Começar →".

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/register_type_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/features/auth/register_type_screen.dart';

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const RegisterTypeScreen(),
      routes: {
        Rotas.registerTeacher: (_) =>
            const Scaffold(body: Text('cadastro do professor')),
        Rotas.registerStudent: (_) =>
            const Scaffold(body: Text('cadastro do aluno')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RegisterTypeScreen - conteudo', () {
    testWidgets('mostra a pergunta e as duas opcoes', (tester) async {
      await pumpTela(tester);

      expect(find.text('Quem é você?'), findsOneWidget);
      expect(find.text('Escolha seu perfil para começar'), findsOneWidget);
      expect(find.text('Sou Professor(a)'), findsOneWidget);
      expect(find.text('Sou Aluno(a)'), findsOneWidget);
    });

    testWidgets('descreve o que cada perfil faz', (tester) async {
      await pumpTela(tester);

      expect(
        find.text(
          'Cadastre questões, acompanhe turmas e visualize relatórios pedagógicos',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Jogue, aprenda, suba no ranking e desafie seus colegas'),
        findsOneWidget,
      );
    });
  });

  group('RegisterTypeScreen - navegacao', () {
    testWidgets('professor leva ao cadastro do professor', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Sou Professor(a)'));
      await tester.pumpAndSettle();

      expect(find.text('cadastro do professor'), findsOneWidget);
    });

    testWidgets('aluno leva ao cadastro do aluno', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Sou Aluno(a)'));
      await tester.pumpAndSettle();

      expect(find.text('cadastro do aluno'), findsOneWidget);
    });
  });

  group('RegisterTypeScreen - layout', () {
    testWidgets('cabe em telefone estreito', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const RegisterTypeScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/register_type_screen_test.dart
```
Esperado: falha de compilação — `register_type_screen.dart` não existe.

- [ ] **Step 3: Implementar a barra superior**

Criar `mobile/lib/core/widgets/top_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra do topo do cabecalho: seta de voltar e titulo opcional.
///
/// Vive dentro do GradientHeader, entao pinta em branco.
class TopBar extends StatelessWidget {
  const TopBar({super.key, this.titulo, this.onVoltar});

  final String? titulo;
  final VoidCallback? onVoltar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onVoltar != null)
          IconButton(
            onPressed: onVoltar,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            tooltip: 'Voltar',
          ),
        if (titulo != null) ...[
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              titulo!,
              style: AppTheme.headerTitle.copyWith(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: Implementar a tela**

Criar `mobile/lib/features/auth/register_type_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';

/// Escolha entre cadastro de professor e de aluno.
class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(onVoltar: () => Navigator.maybePop(context)),
                    const SizedBox(height: 8),
                    Text(
                      'Quem é você?',
                      style: AppTheme.headerTitle.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Escolha seu perfil para começar',
                      style: AppTheme.headerSubtitle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    _CartaoDePerfil(
                      emoji: '👩‍🏫',
                      titulo: 'Sou Professor(a)',
                      descricao:
                          'Cadastre questões, acompanhe turmas e visualize relatórios pedagógicos',
                      cor: AppColors.purple,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.registerTeacher,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CartaoDePerfil(
                      emoji: '🎮',
                      titulo: 'Sou Aluno(a)',
                      descricao:
                          'Jogue, aprenda, suba no ranking e desafie seus colegas',
                      cor: AppColors.green,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Rotas.registerStudent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoDePerfil extends StatelessWidget {
  const _CartaoDePerfil({
    required this.emoji,
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.onTap,
  });

  final String emoji;
  final String titulo;
  final String descricao;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontFamily: AppTheme.poppins,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Começar',
                          style: TextStyle(
                            fontFamily: AppTheme.inter,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: cor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: cor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Registrar a rota**

Em `mobile/lib/core/routes.dart`, acrescentar o import e a linha da tabela:

```dart
import '../features/auth/register_type_screen.dart';
```

```dart
        registerType: (_) => const RegisterTypeScreen(),
```

- [ ] **Step 6: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/register_type_screen_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/core/widgets/top_bar.dart mobile/lib/features/auth/register_type_screen.dart mobile/lib/core/routes.dart mobile/test/features/register_type_screen_test.dart
git commit -m "feat: adiciona a escolha entre perfil de professor e de aluno

Entra tambem a TopBar, barra de voltar e titulo usada pelas telas com
cabecalho a partir daqui."
```

---

### Task 13: Cadastro de professor — CT03

**Files:**
- Create: `mobile/lib/features/auth/register_controller.dart`
- Create: `mobile/lib/features/auth/register_teacher_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/register_teacher_screen_test.dart`

**Interfaces:**
- Consumes: `UserRepository`, `SessionScope`, `Validators`, `Papel`, `Rotas`.
- Produces: `class RegisterController extends ChangeNotifier` com `RegisterController({required UserRepository usuarios, required SessionScope sessao, required Papel papel})`, `Map<String, String?> get erros`, `bool carregando`, `String? erroGeral`, `Future<AppUser?> cadastrar({required String nome, required String email, required String usuario, required String senha, String? escola, String? turma})`. As chaves de `erros` são `'nome'`, `'email'`, `'usuario'`, `'senha'`, `'escola'`, `'turma'`.

O mesmo controlador serve as duas telas de cadastro; o que muda é o `papel` e o campo extra.

Referência visual: `App.tsx:318-352`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/register_teacher_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/auth/register_teacher_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const RegisterTeacherScreen(),
        routes: {
          Rotas.homeTeacher: (_) => const Scaffold(body: Text('home do professor')),
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Preenche os cinco campos na ordem em que aparecem na tela.
Future<void> preencher(
  WidgetTester tester, {
  String nome = 'Maria Silva',
  String email = 'professor@escola.com',
  String usuario = 'mariasilva',
  String escola = 'E.E. Monteiro Lobato',
  String senha = 'Professor@123',
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nome);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), usuario);
  await tester.enterText(campos.at(3), escola);
  await tester.enterText(campos.at(4), senha);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  group('CT03 - Cadastro de Professor', () {
    testWidgets('nao funcional: minimizacao, so os cinco campos previstos',
        (tester) async {
      await pumpTela(tester);

      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Nome completo'), findsOneWidget);
      expect(find.text('E-mail institucional'), findsOneWidget);
      expect(find.text('Nome de usuário'), findsOneWidget);
      expect(find.text('Escola'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('funcional: cadastro valido grava e abre a home',
        (tester) async {
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('home do professor'), findsOneWidget);

      final gravado = await ambiente.usuarios.porEmail('professor@escola.com');
      expect(gravado, isNotNull);
      expect(gravado!.papel, Papel.professor);
      expect(gravado.escola, 'E.E. Monteiro Lobato');
      expect(ambiente.sessao.usuario!.nome, 'Maria Silva');
    });

    testWidgets('formulario vazio cobra os cinco campos', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu nome'), findsOneWidget);
      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe seu nome de usuario'), findsOneWidget);
      expect(find.text('Informe sua escola'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('nao funcional: recusa e-mail mal formado', (tester) async {
      await pumpTela(tester);
      await preencher(tester, email: 'maria.escola');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail invalido'), findsOneWidget);
      expect(find.text('home do professor'), findsNothing);
    });

    testWidgets('nao funcional: recusa senha curta', (tester) async {
      await pumpTela(tester);
      await preencher(tester, senha: 'curta1');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha precisa de ao menos 8 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('nao funcional: recusa nome de usuario com caractere especial',
        (tester) async {
      await pumpTela(tester);
      await preencher(tester, usuario: 'maria silva');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('Use apenas letras, numeros, ponto e sublinhado'),
        findsOneWidget,
      );
    });

    testWidgets('nao funcional: recusa nome longo demais', (tester) async {
      await pumpTela(tester);
      await preencher(tester, nome: 'a' * 81);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('O nome precisa de 3 a 80 caracteres'), findsOneWidget);
    });

    testWidgets('avisa quando o e-mail ja existe', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Outra Pessoa',
        email: 'professor@escola.com',
        usuario: 'outrapessoa',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Outra',
      );
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Este e-mail ja esta cadastrado'), findsOneWidget);
      expect(find.text('home do professor'), findsNothing);
    });

    testWidgets('a senha fica escondida no campo', (tester) async {
      await pumpTela(tester);

      final senha = tester.widget<TextField>(find.byType(TextField).at(4));
      expect(senha.obscureText, isTrue);
    });
  });

  group('RegisterTeacherScreen - navegacao', () {
    testWidgets('Entrar leva ao login', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });

  group('RegisterTeacherScreen - layout', () {
    testWidgets('rola quando a tela e curta', (tester) async {
      tester.view.physicalSize = const Size(390, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpTela(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/register_teacher_screen_test.dart
```
Esperado: falha de compilação — `register_teacher_screen.dart` não existe.

- [ ] **Step 3: Implementar o controlador**

Criar `mobile/lib/features/auth/register_controller.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../core/session/session_scope.dart';
import '../../core/validation/validators.dart';
import '../../data/models/app_user.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/erros.dart';
import '../../data/repositories/user_repository.dart';

/// Estado das duas telas de cadastro. O que muda entre elas e o [papel] e o
/// campo extra: escola para professor, turma para aluno.
class RegisterController extends ChangeNotifier {
  RegisterController({
    required UserRepository usuarios,
    required SessionScope sessao,
    required this.papel,
  })  : _usuarios = usuarios,
        _sessao = sessao;

  final UserRepository _usuarios;
  final SessionScope _sessao;
  final Papel papel;

  final Map<String, String?> erros = <String, String?>{};
  bool carregando = false;
  String? erroGeral;

  Future<AppUser?> cadastrar({
    required String nome,
    required String email,
    required String usuario,
    required String senha,
    String? escola,
    String? turma,
  }) async {
    erros
      ..clear()
      ..addAll({
        'nome': Validators.nome(nome),
        'email': Validators.email(email),
        'usuario': Validators.usuario(usuario),
        'senha': Validators.senha(senha),
        if (papel == Papel.professor) 'escola': Validators.escola(escola),
        if (papel == Papel.aluno) 'turma': Validators.turma(turma),
      });
    erros.removeWhere((_, mensagem) => mensagem == null);
    erroGeral = null;

    if (erros.isNotEmpty) {
      notifyListeners();
      return null;
    }

    carregando = true;
    notifyListeners();

    try {
      final novo = await _usuarios.cadastrar(
        nome: nome,
        email: email,
        usuario: usuario,
        senha: senha,
        papel: papel,
        escola: escola,
        turma: turma,
      );
      // Cadastrar ja entra: o protopipo leva direto para a home.
      _sessao.abrir(novo);
      return novo;
    } on ErroDeDominio catch (e) {
      erroGeral = e.mensagem;
      return null;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void limparErros() {
    if (erros.isEmpty && erroGeral == null) return;
    erros.clear();
    erroGeral = null;
    notifyListeners();
  }
}
```

- [ ] **Step 4: Implementar a tela**

Criar `mobile/lib/features/auth/register_teacher_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/user_repository.dart';
import 'register_controller.dart';

/// Cadastro de professor. Cinco campos, nem um a mais: CT03 cobra
/// minimizacao de dados.
class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _usuario = TextEditingController();
  final _escola = TextEditingController();
  final _senha = TextEditingController();

  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(
      usuarios: context.read<UserRepository>(),
      sessao: context.read<SessionScope>(),
      papel: Papel.professor,
    )..addListener(_aoMudar);
  }

  void _aoMudar() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_aoMudar);
    _controller.dispose();
    for (final campo in [_nome, _email, _usuario, _escola, _senha]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _criarConta() async {
    final novo = await _controller.cadastrar(
      nome: _nome.text,
      email: _email.text,
      usuario: _usuario.text,
      senha: _senha.text,
      escola: _escola.text,
    );
    if (novo == null || !mounted) return;
    Navigator.pushReplacementNamed(context, Rotas.homeTeacher);
  }

  @override
  Widget build(BuildContext context) {
    final erros = _controller.erros;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(
                      titulo: 'Cadastro Professor',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text('👩‍🏫', style: TextStyle(fontSize: 34)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Crie sua conta gratuita e comece a ensinar de forma gamificada',
                            style: AppTheme.headerSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Nome completo',
                      controller: _nome,
                      hint: 'Maria Silva',
                      icon: Icons.person,
                      errorText: erros['nome'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail institucional',
                      controller: _email,
                      hint: 'maria@escola.edu.br',
                      icon: Icons.email,
                      errorText: erros['email'],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nome de usuário',
                      controller: _usuario,
                      hint: 'mariasilva',
                      icon: Icons.alternate_email,
                      errorText: erros['usuario'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Escola',
                      controller: _escola,
                      hint: 'E.E. Monteiro Lobato',
                      icon: Icons.school,
                      errorText: erros['escola'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Senha',
                      controller: _senha,
                      hint: 'Mínimo 8 caracteres',
                      icon: Icons.lock,
                      errorText: erros['senha'],
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _criarConta(),
                    ),
                    const SizedBox(height: 24),
                    if (_controller.erroGeral != null) ...[
                      _AvisoDeErro(mensagem: _controller.erroGeral!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: 'Criar Conta',
                      icon: Icons.how_to_reg,
                      onPressed: _criarConta,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text('Já tem conta?', style: AppTheme.footerText),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, Rotas.login),
                          child: const Text('Entrar', style: AppTheme.footerLink),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caixa vermelha de erro da operacao, acima do botao de acao.
class _AvisoDeErro extends StatelessWidget {
  const _AvisoDeErro({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(mensagem, style: AppTheme.fieldError)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Registrar a rota**

Em `mobile/lib/core/routes.dart`:

```dart
import '../features/auth/register_teacher_screen.dart';
```

```dart
        registerTeacher: (_) => const RegisterTeacherScreen(),
```

- [ ] **Step 6: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/register_teacher_screen_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/features/auth/register_controller.dart mobile/lib/features/auth/register_teacher_screen.dart mobile/lib/core/routes.dart mobile/test/features/register_teacher_screen_test.dart
git commit -m "feat: adiciona cadastro de professor

Cinco campos, nem um a mais, como cobra o teste nao funcional de CT03.
Cadastrar ja abre a sessao e leva a home, como no prototipo. O
RegisterController serve as duas telas de cadastro, parametrizado por papel.

Cobre CT03 funcional e nao funcional."
```

---

### Task 14: Cadastro de aluno — CT04

**Files:**
- Create: `mobile/lib/features/auth/register_student_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/register_student_screen_test.dart`

**Interfaces:**
- Consumes: `RegisterController` (Task 13), `UserRepository`, `SessionScope`, `Rotas`.
- Produces: `class RegisterStudentScreen extends StatefulWidget`.

Mesma estrutura da Task 13, com três diferenças: cabeçalho verde, campo Turma no lugar de Escola, destino `Rotas.homeStudent`. O gradiente verde não existe em `AppColors` ainda — entra nesta tarefa.

Referência visual: `App.tsx:353-385`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/register_student_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/auth/register_student_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const RegisterStudentScreen(),
        routes: {
          Rotas.homeStudent: (_) => const Scaffold(body: Text('home do aluno')),
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> preencher(
  WidgetTester tester, {
  String nome = 'Joao Santos',
  String email = 'joao@email.com',
  String usuario = 'joaosantos',
  String turma = '9 ano B',
  String senha = 'Aluno@12345',
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nome);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), usuario);
  await tester.enterText(campos.at(3), turma);
  await tester.enterText(campos.at(4), senha);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  group('CT04 - Cadastro de Aluno', () {
    testWidgets('nao funcional: minimizacao, so os cinco campos previstos',
        (tester) async {
      await pumpTela(tester);

      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Nome completo'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Nome de usuário'), findsOneWidget);
      expect(find.text('Turma'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('funcional: conta criada com sucesso', (tester) async {
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('home do aluno'), findsOneWidget);

      final gravado = await ambiente.usuarios.porEmail('joao@email.com');
      expect(gravado!.papel, Papel.aluno);
      expect(gravado.turma, '9 ano B');
      expect(gravado.escola, isNull);
    });

    testWidgets('nao funcional: script no nome nao chega ao banco',
        (tester) async {
      await pumpTela(tester);
      await preencher(tester, nome: 'Joao<script>alert(1)</script>Santos');

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      final gravado = await ambiente.usuarios.porEmail('joao@email.com');
      expect(gravado!.nome, 'JoaoSantos');
    });

    testWidgets('nao funcional: recusa texto longo demais na turma',
        (tester) async {
      await pumpTela(tester);
      await preencher(tester, turma: 'a' * 81);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('A turma precisa de 2 a 80 caracteres'), findsOneWidget);
      expect(find.text('home do aluno'), findsNothing);
    });

    testWidgets('formulario vazio cobra os cinco campos', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu nome'), findsOneWidget);
      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe seu nome de usuario'), findsOneWidget);
      expect(find.text('Informe sua turma'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('avisa quando o nome de usuario ja existe', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Outro Joao',
        email: 'outro@email.com',
        usuario: 'joaosantos',
        senha: 'Aluno@12345',
        papel: Papel.aluno,
        turma: '8 ano A',
      );
      await pumpTela(tester);
      await preencher(tester);

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Este nome de usuario ja esta em uso'), findsOneWidget);
    });
  });

  group('RegisterStudentScreen - navegacao', () {
    testWidgets('Entrar leva ao login', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/register_student_screen_test.dart
```
Esperado: falha de compilação — `register_student_screen.dart` não existe.

- [ ] **Step 3: Acrescentar o gradiente verde**

Em `mobile/lib/core/theme/app_colors.dart`, abaixo de `headerGradient`:

```dart
  /// Gradiente do cabecalho das telas de aluno, equivalente a
  /// `linear-gradient(135deg, GREEN, #1a7a44)`.
  static const greenHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, greenDark],
  );
```

Em `mobile/lib/core/widgets/gradient_header.dart`, aceitar o gradiente por parâmetro sem quebrar quem já usa:

```dart
  const GradientHeader({super.key, required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;
```

e trocar a decoração:

```dart
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.headerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
```

O `const` do `BoxDecoration` sai porque `gradient` agora é variável; o `BorderRadius` continua constante.

- [ ] **Step 4: Implementar a tela**

Criar `mobile/lib/features/auth/register_student_screen.dart` com o mesmo corpo da Task 13 e estas trocas:

- Classe `RegisterStudentScreen` / `_RegisterStudentScreenState`.
- `papel: Papel.aluno` no `RegisterController`.
- Campo `_escola` vira `_turma`.
- `GradientHeader(gradient: AppColors.greenHeaderGradient, child: ...)`.
- Título da `TopBar`: `'Cadastro Aluno'`. Emoji: `'🎮'`. Chamada: `'Entre para o universo da computação com diversão'`.
- Campo 2: label `'E-mail'`, hint `'joao@email.com'`.
- Campo 1: hint `'João Santos'`. Campo 3: hint `'joaosantos'`.
- Campo 4: label `'Turma'`, hint `'9 ano B'`, ícone `Icons.group`, `errorText: erros['turma']`.
- Na chamada de `cadastrar`, passar `turma: _turma.text` no lugar de `escola:`.
- Destino: `Rotas.homeStudent`.
- O botão "Criar Conta" usa `variant: AppButtonVariant.ghost`? Não — no protótipo ele é verde sólido. Como `AppButton` só conhece roxo, passar o botão verde exige uma variante. Acrescentar em `mobile/lib/core/widgets/app_button.dart`:

```dart
enum AppButtonVariant { primary, ghost, green }
```

e no `build`:

```dart
    final (background, foreground) = switch (widget.variant) {
      AppButtonVariant.primary => (AppColors.purple, Colors.white),
      AppButtonVariant.ghost => (AppColors.purpleLight, AppColors.purple),
      AppButtonVariant.green => (AppColors.green, Colors.white),
    };
```

removendo as duas linhas `final isPrimary = ...` / `final background = ...` / `final foreground = ...` que existiam antes. Na tela do aluno, usar `variant: AppButtonVariant.green`.

- A classe `_AvisoDeErro` da Task 13 é privada do arquivo do professor. Movê-la para `mobile/lib/core/widgets/aviso_de_erro.dart` como `class AvisoDeErro`, ajustando o import nas duas telas — repetir a classe nos dois arquivos seria duplicação sem ganho.

- [ ] **Step 5: Registrar a rota**

Em `mobile/lib/core/routes.dart`:

```dart
import '../features/auth/register_student_screen.dart';
```

```dart
        registerStudent: (_) => const RegisterStudentScreen(),
```

- [ ] **Step 6: Rodar tudo e conferir que passa**

```bash
cd mobile && flutter analyze && flutter test
```
Esperado: `No issues found.` e a suíte inteira passando — inclusive os testes do professor, que dependem do `AvisoDeErro` movido.

- [ ] **Step 7: Commit**

```bash
git add mobile/lib mobile/test
git commit -m "feat: adiciona cadastro de aluno

Mesma estrutura do cadastro de professor, com turma no lugar de escola e o
cabecalho verde do prototipo. Entram a variante verde do AppButton, o
gradiente verde e o AvisoDeErro extraido para core/widgets, agora usado
pelas duas telas.

Cobre CT04 funcional e nao funcional."
```

---

### Task 15: Homes de professor e aluno

Casca com identidade real: saúda o usuário logado e navega para o perfil. Os itens dos ciclos 2 a 4 aparecem desabilitados, com aviso — botão que não faz nada sem explicação vira bug reportado.

**Files:**
- Create: `mobile/lib/core/widgets/bottom_nav.dart`
- Create: `mobile/lib/features/home/home_teacher_screen.dart`
- Create: `mobile/lib/features/home/home_student_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/home_screens_test.dart`

**Interfaces:**
- Consumes: `SessionScope`, `Rotas`, `AppColors`, `AppTheme`.
- Produces:
  - `class BottomNav extends StatelessWidget` com `const BottomNav({super.key, required this.itens, required this.ativo, required this.onSelecionar, this.cor = AppColors.purple})` e `class ItemDeNav` com `const ItemDeNav({required this.id, required this.icone, required this.rotulo, this.habilitado = true})`.
  - `class HomeTeacherScreen extends StatelessWidget`, `class HomeStudentScreen extends StatelessWidget`.

Referência visual: `App.tsx:173-189` (nav), `App.tsx:386-472` (home professor), `App.tsx:848-949` (home aluno).

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/home_screens_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/features/home/home_student_screen.dart';
import 'package:bncc_play_mobile/features/home/home_teacher_screen.dart';

AppUser usuarioDe(Papel papel) {
  final momento = DateTime.utc(2026, 7, 31, 12);
  return AppUser(
    id: 1,
    nome: papel == Papel.professor ? 'Maria Silva' : 'João Santos',
    email: papel == Papel.professor ? 'professor@escola.com' : 'joao@email.com',
    usuario: papel == Papel.professor ? 'mariasilva' : 'joaosantos',
    papel: papel,
    escola: papel == Papel.professor ? 'E.E. Monteiro Lobato' : null,
    turma: papel == Papel.aluno ? '9 ano B' : null,
    criadoEm: momento,
    atualizadoEm: momento,
  );
}

Future<void> pumpHome(
  WidgetTester tester, {
  required Papel papel,
  bool comSessao = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final sessao = SessionScope();
  if (comSessao) sessao.abrir(usuarioDe(papel));

  await tester.pumpWidget(
    ChangeNotifierProvider<SessionScope>.value(
      value: sessao,
      child: MaterialApp(
        theme: AppTheme.light,
        home: papel == Papel.professor
            ? const HomeTeacherScreen()
            : const HomeStudentScreen(),
        routes: {
          Rotas.profileTeacher: (_) =>
              const Scaffold(body: Text('perfil do professor')),
          Rotas.profileStudent: (_) =>
              const Scaffold(body: Text('perfil do aluno')),
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomeTeacherScreen', () {
    testWidgets('saúda o professor logado pelo primeiro nome', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      expect(find.text('Olá, Maria!'), findsOneWidget);
    });

    testWidgets('mostra a escola do professor', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      expect(find.text('E.E. Monteiro Lobato'), findsOneWidget);
    });

    testWidgets('mostra os itens de navegacao do professor', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Questões'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('Perfil leva ao perfil do professor', (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('perfil do professor'), findsOneWidget);
    });

    testWidgets('item de ciclo futuro avisa em vez de ficar mudo',
        (tester) async {
      await pumpHome(tester, papel: Papel.professor);

      await tester.tap(find.text('Questões'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Disponível na próxima entrega.'),
        findsOneWidget,
      );
    });

    testWidgets('sem sessao valida manda para o login', (tester) async {
      await pumpHome(tester, papel: Papel.professor, comSessao: false);

      expect(find.text('tela de login'), findsOneWidget);
    });
  });

  group('HomeStudentScreen', () {
    testWidgets('saúda o aluno e mostra a turma', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      expect(find.text('Olá, João!'), findsOneWidget);
      expect(find.text('9 ano B'), findsOneWidget);
    });

    testWidgets('mostra os itens de navegacao do aluno', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Jogar'), findsOneWidget);
      expect(find.text('Ranking'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('Perfil leva ao perfil do aluno', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('perfil do aluno'), findsOneWidget);
    });

    testWidgets('Jogar avisa que chega na proxima entrega', (tester) async {
      await pumpHome(tester, papel: Papel.aluno);

      await tester.tap(find.text('Jogar'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Disponível na próxima entrega.'),
        findsOneWidget,
      );
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/home_screens_test.dart
```
Esperado: falha de compilação — as duas telas de home não existem.

- [ ] **Step 3: Implementar a navegação inferior**

Criar `mobile/lib/core/widgets/bottom_nav.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ItemDeNav {
  const ItemDeNav({
    required this.id,
    required this.icone,
    required this.rotulo,
    this.habilitado = true,
  });

  final String id;
  final IconData icone;
  final String rotulo;

  /// Item de ciclo futuro fica visivel e apagado, mas continua clicavel: o
  /// toque explica que a tela ainda nao chegou.
  final bool habilitado;
}

/// Barra inferior do prototipo: icone acima, rotulo abaixo, ativo colorido.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.itens,
    required this.ativo,
    required this.onSelecionar,
    this.cor = AppColors.purple,
  });

  final List<ItemDeNav> itens;
  final String ativo;
  final ValueChanged<String> onSelecionar;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in itens)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelecionar(item.id),
                    child: Opacity(
                      opacity: item.habilitado ? 1 : 0.4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icone,
                            size: 22,
                            color: item.id == ativo ? cor : AppColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.rotulo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.inter,
                              fontSize: 11,
                              fontWeight: item.id == ativo
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  item.id == ativo ? cor : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implementar a home do professor**

Criar `mobile/lib/features/home/home_teacher_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gradient_header.dart';

/// Home do professor. Casca: saúda o usuario logado e leva ao perfil. Os
/// destinos dos ciclos 2 a 4 avisam em vez de ficar mudos.
class HomeTeacherScreen extends StatelessWidget {
  const HomeTeacherScreen({super.key});

  static const _itens = [
    ItemDeNav(id: 'home', icone: Icons.home, rotulo: 'Início'),
    ItemDeNav(
      id: 'questoes',
      icone: Icons.quiz,
      rotulo: 'Questões',
      habilitado: false,
    ),
    ItemDeNav(
      id: 'dashboard',
      icone: Icons.bar_chart,
      rotulo: 'Dashboard',
      habilitado: false,
    ),
    ItemDeNav(id: 'perfil', icone: Icons.account_circle, rotulo: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessionScope>();
    final usuario = sessao.usuario;

    if (usuario == null) {
      // Sessao expirada ou inexistente: sai da tela na proxima passada do
      // frame, para nao navegar durante o build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final primeiroNome = usuario.nome.split(' ').first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $primeiroNome!',
                      style: AppTheme.headerTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario.escola ?? '',
                      style: AppTheme.headerSubtitle,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: _AvisoDeCiclo(
                  texto:
                      'Cadastro de questões, dashboard e relatórios chegam nas próximas entregas.',
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNav(
          itens: _itens,
          ativo: 'home',
          onSelecionar: (id) => _selecionar(context, id),
        ),
      ),
    );
  }

  void _selecionar(BuildContext context, String id) {
    if (id == 'perfil') {
      Navigator.pushNamed(context, Rotas.profileTeacher);
      return;
    }
    if (id == 'home') return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Disponível na próxima entrega.')),
      );
  }
}

class _AvisoDeCiclo extends StatelessWidget {
  const _AvisoDeCiclo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.construction, color: AppColors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 13,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Implementar a home do aluno**

Criar `mobile/lib/features/home/home_student_screen.dart` com a mesma estrutura, trocando:

- Classe `HomeStudentScreen`.
- Itens: `home` (Início), `jogar` (`Icons.sports_esports`, 'Jogar', desabilitado), `ranking` (`Icons.leaderboard`, 'Ranking', desabilitado), `perfil` (Perfil).
- `GradientHeader(gradient: AppColors.greenHeaderGradient, ...)`.
- Subtítulo do cabeçalho: `usuario.turma ?? ''`.
- `BottomNav(cor: AppColors.green, ...)`.
- Destino do perfil: `Rotas.profileStudent`.
- Texto do aviso: `'O jogo, a pontuação e o ranking chegam na próxima entrega.'`
- Ícone do aviso na cor `AppColors.green`.

O `_AvisoDeCiclo` é privado do arquivo do professor. Como as duas telas o usam, movê-lo para `mobile/lib/core/widgets/aviso_de_ciclo.dart` como `class AvisoDeCiclo`, com um parâmetro `Color cor`, e importar nas duas.

- [ ] **Step 6: Registrar as rotas**

Em `mobile/lib/core/routes.dart`:

```dart
import '../features/home/home_student_screen.dart';
import '../features/home/home_teacher_screen.dart';
```

```dart
        homeTeacher: (_) => const HomeTeacherScreen(),
        homeStudent: (_) => const HomeStudentScreen(),
```

- [ ] **Step 7: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/home_screens_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 8: Commit**

```bash
git add mobile/lib mobile/test/features/home_screens_test.dart
git commit -m "feat: adiciona as homes de professor e aluno

Casca com identidade real: saudacao pelo nome do usuario logado, escola ou
turma no cabecalho e navegacao para o perfil. Os destinos dos ciclos
seguintes ficam apagados e avisam ao toque, em vez de ficarem mudos.

Sem sessao valida a tela manda para o login, o que sustenta o teste nao
funcional de CT12."
```

---

### Task 16: Perfis de professor e aluno

**Files:**
- Create: `mobile/lib/core/widgets/app_badge.dart`
- Create: `mobile/lib/features/profile/profile_teacher_screen.dart`
- Create: `mobile/lib/features/profile/profile_student_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/profile_screens_test.dart`

**Interfaces:**
- Consumes: `SessionScope`, `Rotas`, `AppColors`, `AppTheme`.
- Produces: `class AppBadge extends StatelessWidget` com `const AppBadge({super.key, required this.rotulo, this.cor = AppColors.purple})`; `class ProfileTeacherScreen`, `class ProfileStudentScreen`.

Referência visual: `App.tsx:795-847` (professor) e `App.tsx:950-1017` (aluno). As estatísticas ficam em zero — no ciclo 1 não há questões nem partidas. Número fixo inventado passaria por bug nos ciclos seguintes.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/profile_screens_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/features/profile/profile_student_screen.dart';
import 'package:bncc_play_mobile/features/profile/profile_teacher_screen.dart';

AppUser usuarioDe(Papel papel) {
  final momento = DateTime.utc(2026, 7, 31, 12);
  return AppUser(
    id: 1,
    nome: papel == Papel.professor ? 'Maria Silva' : 'João Santos',
    email: papel == Papel.professor ? 'professor@escola.com' : 'joao@email.com',
    usuario: papel == Papel.professor ? 'mariasilva' : 'joaosantos',
    papel: papel,
    escola: papel == Papel.professor ? 'E.E. Monteiro Lobato' : null,
    turma: papel == Papel.aluno ? '9 ano B' : null,
    criadoEm: momento,
    atualizadoEm: momento,
  );
}

late SessionScope sessao;

Future<void> pumpPerfil(WidgetTester tester, {required Papel papel}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  sessao = SessionScope()..abrir(usuarioDe(papel));

  await tester.pumpWidget(
    ChangeNotifierProvider<SessionScope>.value(
      value: sessao,
      child: MaterialApp(
        theme: AppTheme.light,
        home: papel == Papel.professor
            ? const ProfileTeacherScreen()
            : const ProfileStudentScreen(),
        routes: {
          Rotas.editProfile: (_) => const Scaffold(body: Text('editar perfil')),
          Rotas.splash: (_) => const Scaffold(body: Text('tela inicial')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ProfileTeacherScreen', () {
    testWidgets('mostra nome, e-mail e papel do professor', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('professor@escola.com'), findsOneWidget);
      expect(find.text('Professor(a)'), findsOneWidget);
    });

    testWidgets('mostra a escola no item Minha Escola', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      expect(find.text('Minha Escola'), findsOneWidget);
      expect(find.text('E.E. Monteiro Lobato'), findsOneWidget);
    });

    testWidgets('estatisticas comecam zeradas no ciclo 1', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      expect(find.text('Questões'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Editar Perfil leva a edicao', (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('editar perfil'), findsOneWidget);
    });

    testWidgets('Sair da Conta encerra a sessao e volta ao inicio',
        (tester) async {
      await pumpPerfil(tester, papel: Papel.professor);

      await tester.tap(find.text('Sair da Conta'));
      await tester.pumpAndSettle();

      expect(sessao.autenticado, isFalse);
      expect(find.text('tela inicial'), findsOneWidget);
    });
  });

  group('ProfileStudentScreen', () {
    testWidgets('mostra nome, arroba e papel do aluno', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      expect(find.text('João Santos'), findsOneWidget);
      expect(find.text('@joaosantos'), findsOneWidget);
      expect(find.text('Aluno(a)'), findsOneWidget);
    });

    testWidgets('mostra a turma', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      expect(find.text('9 ano B'), findsOneWidget);
    });

    testWidgets('nao mostra o e-mail de outros usuarios', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      expect(find.text('professor@escola.com'), findsNothing);
    });

    testWidgets('Editar Perfil leva a edicao', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('editar perfil'), findsOneWidget);
    });

    testWidgets('Sair da Conta encerra a sessao', (tester) async {
      await pumpPerfil(tester, papel: Papel.aluno);

      await tester.tap(find.text('Sair da Conta'));
      await tester.pumpAndSettle();

      expect(sessao.autenticado, isFalse);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/profile_screens_test.dart
```
Esperado: falha de compilação — as telas de perfil não existem.

- [ ] **Step 3: Implementar a etiqueta**

Criar `mobile/lib/core/widgets/app_badge.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Etiqueta arredondada do prototipo (`Badge`).
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.rotulo, this.cor = AppColors.purple});

  final String rotulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        rotulo,
        style: const TextStyle(
          fontFamily: AppTheme.inter,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implementar o perfil do professor**

Criar `mobile/lib/features/profile/profile_teacher_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import 'widgets/perfil_widgets.dart';

/// Perfil do professor, com os dados do usuario logado.
///
/// As estatisticas ficam em zero: no ciclo 1 nao ha questoes nem turmas.
/// Numero fixo inventado passaria por bug quando o dado real chegasse.
class ProfileTeacherScreen extends StatelessWidget {
  const ProfileTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessionScope>();
    final usuario = sessao.usuario;
    if (usuario == null) return const Scaffold(body: SizedBox.shrink());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                child: Column(
                  children: [
                    TopBar(
                      titulo: 'Meu Perfil',
                      onVoltar: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 8),
                    const AvatarDePerfil(emoji: '👩‍🏫'),
                    const SizedBox(height: 8),
                    Text(usuario.nome, style: AppTheme.headerTitle),
                    const SizedBox(height: 4),
                    Text(usuario.email, style: AppTheme.headerSubtitle),
                    const SizedBox(height: 8),
                    AppBadge(rotulo: usuario.papel.rotulo, cor: AppColors.green),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: CartaoDeEstatistica(
                            icone: Icons.quiz,
                            valor: '0',
                            rotulo: 'Questões',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CartaoDeEstatistica(
                            icone: Icons.group,
                            valor: '0',
                            rotulo: 'Alunos',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CartaoDeEstatistica(
                            icone: Icons.class_,
                            valor: '0',
                            rotulo: 'Turmas',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ItemDeMenu(
                      icone: Icons.person,
                      rotulo: 'Editar Perfil',
                      detalhe: 'Nome, e-mail e usuário',
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.editProfile),
                    ),
                    const SizedBox(height: 12),
                    ItemDeMenu(
                      icone: Icons.school,
                      rotulo: 'Minha Escola',
                      detalhe: usuario.escola ?? '',
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.editProfile),
                    ),
                    const SizedBox(height: 24),
                    BotaoSair(
                      onSair: () {
                        context.read<SessionScope>().encerrar();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Rotas.splash,
                          (_) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Implementar os widgets compartilhados dos perfis**

Criar `mobile/lib/features/profile/widgets/perfil_widgets.dart` com quatro widgets públicos, usados pelos dois perfis:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Circulo translucido com o emoji do papel, dentro do cabecalho.
class AvatarDePerfil extends StatelessWidget {
  const AvatarDePerfil({super.key, required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 44)),
    );
  }
}

class CartaoDeEstatistica extends StatelessWidget {
  const CartaoDeEstatistica({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    this.cor = AppColors.purple,
  });

  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icone, size: 20, color: cor),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontFamily: AppTheme.poppins,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemDeMenu extends StatelessWidget {
  const ItemDeMenu({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.detalhe,
    required this.onTap,
    this.cor = AppColors.purple,
    this.fundoDoIcone = AppColors.purpleLight,
  });

  final IconData icone;
  final String rotulo;
  final String detalhe;
  final VoidCallback onTap;
  final Color cor;
  final Color fundoDoIcone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fundoDoIcone,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, size: 20, color: cor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rotulo,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalhe,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotaoSair extends StatelessWidget {
  const BotaoSair({super.key, required this.onSair});

  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerLight,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSair,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Sair da Conta',
                style: TextStyle(
                  fontFamily: AppTheme.poppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Implementar o perfil do aluno**

Criar `mobile/lib/features/profile/profile_student_screen.dart` com a mesma estrutura, trocando:

- `GradientHeader(gradient: AppColors.greenHeaderGradient, ...)`, avatar `'🎮'`.
- Abaixo do nome, `'@${usuario.usuario}'` no lugar do e-mail — o protótipo do aluno não expõe e-mail na tela.
- `AppBadge(rotulo: usuario.papel.rotulo, cor: AppColors.purple)`.
- Estatísticas: `Icons.star` / `'0'` / `'XP Total'`; `Icons.leaderboard` / `'—'` / `'Ranking'`; `Icons.check_circle` / `'0%'` / `'Acertos'`, todas com `cor: AppColors.green`.
- Itens de menu: `Editar Perfil` (`detalhe: 'Nome, e-mail e usuário'`) e `Minha Turma` (`Icons.group`, `detalhe: usuario.turma ?? ''`), ambos com `cor: AppColors.green` e `fundoDoIcone: AppColors.greenLight`.
- Sem seção de conquistas: não há dado de jogo no ciclo 1.

- [ ] **Step 7: Registrar as rotas**

Em `mobile/lib/core/routes.dart`:

```dart
import '../features/profile/profile_student_screen.dart';
import '../features/profile/profile_teacher_screen.dart';
```

```dart
        profileTeacher: (_) => const ProfileTeacherScreen(),
        profileStudent: (_) => const ProfileStudentScreen(),
```

- [ ] **Step 8: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/profile_screens_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 9: Commit**

```bash
git add mobile/lib mobile/test/features/profile_screens_test.dart
git commit -m "feat: adiciona os perfis de professor e aluno

Dados vindos da sessao, com estatisticas zeradas: no ciclo 1 nao ha questao
nem partida, e numero fixo inventado passaria por bug quando o dado real
chegasse. Sair da conta encerra a sessao e limpa o historico de navegacao.

O perfil do aluno mostra a arroba em vez do e-mail, como no prototipo."
```

---

### Task 17: Editar perfil — CT11, CT12

Uma tela só para os dois papéis: o campo extra segue o papel do usuário logado.

**Files:**
- Create: `mobile/lib/features/profile/profile_controller.dart`
- Create: `mobile/lib/features/profile/edit_profile_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/edit_profile_screen_test.dart`

**Interfaces:**
- Consumes: `UserRepository`, `SessionScope`, `Validators`, `Papel`, exceções.
- Produces: `class ProfileController extends ChangeNotifier` com `ProfileController({required UserRepository usuarios, required SessionScope sessao})`, `Map<String, String?> get erros`, `bool carregando`, `String? erroGeral`, `bool salvo`, `Future<bool> salvar({required String nome, required String email, required String usuario, String? escola, String? turma})`.

`salvar` devolve `true` no sucesso e atualiza a sessão com o usuário novo — o perfil precisa refletir a mudança ao voltar.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/edit_profile_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/session/session_scope.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';
import 'package:bncc_play_mobile/data/repositories/user_repository.dart';
import 'package:bncc_play_mobile/features/profile/edit_profile_screen.dart';

import '../support/fakes.dart';

late AmbienteDeTeste ambiente;

/// Cadastra o usuario, abre a sessao com ele e monta a tela de edicao.
Future<AppUser> prepararTela(
  WidgetTester tester, {
  required Papel papel,
  bool abrirSessao = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final usuario = papel == Papel.professor
      ? await ambiente.usuarios.cadastrar(
          nome: 'Maria Silva',
          email: 'professor@escola.com',
          usuario: 'mariasilva',
          senha: 'Professor@123',
          papel: Papel.professor,
          escola: 'E.E. Monteiro Lobato',
        )
      : await ambiente.usuarios.cadastrar(
          nome: 'Joao Santos',
          email: 'joao@email.com',
          usuario: 'joaosantos',
          senha: 'Aluno@12345',
          papel: Papel.aluno,
          turma: '9 ano B',
        );

  if (abrirSessao) ambiente.sessao.abrir(usuario);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: ambiente.usuarios),
        ChangeNotifierProvider<SessionScope>.value(value: ambiente.sessao),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const EditProfileScreen(),
        routes: {
          Rotas.login: (_) => const Scaffold(body: Text('tela de login')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return usuario;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => ambiente = await ambienteDeTeste());
  tearDown(() async => ambiente.banco.fechar());

  group('CT11 - Alteracao de Cadastro do Aluno', () {
    testWidgets('funcional: novo e-mail e salvo', (tester) async {
      final aluno = await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(find.byType(TextField).at(1), 'joao.novo@email.com');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      final gravado = await ambiente.usuarios.porId(aluno.id!);
      expect(gravado!.email, 'joao.novo@email.com');
      expect(find.text('Dados atualizados'), findsOneWidget);
    });

    testWidgets('a sessao passa a refletir o dado novo', (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(find.byType(TextField).at(0), 'Joao Pedro Santos');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(ambiente.sessao.usuario!.nome, 'Joao Pedro Santos');
    });

    testWidgets('os campos vem preenchidos com o cadastro atual',
        (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      final campos = tester
          .widgetList<TextField>(find.byType(TextField))
          .map((c) => c.controller!.text)
          .toList();

      expect(campos, ['Joao Santos', 'joao@email.com', 'joaosantos', '9 ano B']);
    });

    testWidgets('o aluno edita turma, nao escola', (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      expect(find.text('Turma'), findsOneWidget);
      expect(find.text('Escola'), findsNothing);
    });

    testWidgets('nao funcional: sem sessao a tela manda para o login',
        (tester) async {
      await prepararTela(tester, papel: Papel.aluno, abrirSessao: false);

      expect(find.text('tela de login'), findsOneWidget);
    });

    testWidgets('recusa e-mail invalido', (tester) async {
      await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(find.byType(TextField).at(1), 'joao.email');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail invalido'), findsOneWidget);
    });

    testWidgets('recusa e-mail de outra conta', (tester) async {
      await ambiente.usuarios.cadastrar(
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        senha: 'Professor@123',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
      );
      await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(find.byType(TextField).at(1), 'professor@escola.com');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Este e-mail ja esta cadastrado'), findsOneWidget);
    });

    testWidgets('nao funcional: script no nome nao chega ao banco',
        (tester) async {
      final aluno = await prepararTela(tester, papel: Papel.aluno);

      await tester.enterText(
        find.byType(TextField).at(0),
        'Joao<script>alert(1)</script>Santos',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect((await ambiente.usuarios.porId(aluno.id!))!.nome, 'JoaoSantos');
    });
  });

  group('CT12 - Alteracao de Cadastro do Professor', () {
    testWidgets('funcional: nova instituicao e salva', (tester) async {
      final professor = await prepararTela(tester, papel: Papel.professor);

      await tester.enterText(find.byType(TextField).at(3), 'E.E. Santos Dumont');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      final gravado = await ambiente.usuarios.porId(professor.id!);
      expect(gravado!.escola, 'E.E. Santos Dumont');
    });

    testWidgets('o professor edita escola, nao turma', (tester) async {
      await prepararTela(tester, papel: Papel.professor);

      expect(find.text('Escola'), findsOneWidget);
      expect(find.text('Turma'), findsNothing);
    });

    testWidgets('nao funcional: sessao expirada bloqueia a alteracao',
        (tester) async {
      final professor = await prepararTela(tester, papel: Papel.professor);

      // Encerrar a sessao equivale, para a tela, a sessao expirada: nos dois
      // casos SessionScope.usuario vem nulo.
      ambiente.sessao.encerrar();
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
      expect(
        (await ambiente.usuarios.porId(professor.id!))!.escola,
        'E.E. Monteiro Lobato',
      );
    });

    testWidgets('nao mostra campo de senha', (tester) async {
      await prepararTela(tester, papel: Papel.professor);

      expect(find.text('Senha'), findsNothing);
      expect(find.byType(TextField), findsNWidgets(4));
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/edit_profile_screen_test.dart
```
Esperado: falha de compilação — `edit_profile_screen.dart` não existe.

- [ ] **Step 3: Implementar o controlador**

Criar `mobile/lib/features/profile/profile_controller.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../core/session/session_scope.dart';
import '../../core/validation/validators.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/erros.dart';
import '../../data/repositories/user_repository.dart';

/// Estado da edicao de perfil, para os dois papeis.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required UserRepository usuarios,
    required SessionScope sessao,
  })  : _usuarios = usuarios,
        _sessao = sessao;

  final UserRepository _usuarios;
  final SessionScope _sessao;

  final Map<String, String?> erros = <String, String?>{};
  bool carregando = false;
  String? erroGeral;
  bool salvo = false;

  Future<bool> salvar({
    required String nome,
    required String email,
    required String usuario,
    String? escola,
    String? turma,
  }) async {
    salvo = false;

    // A sessao e conferida antes de qualquer escrita: expirada, nada muda.
    final atual = _sessao.usuario;
    if (atual == null) {
      erroGeral = const SessaoExpiradaException().mensagem;
      notifyListeners();
      return false;
    }

    erros
      ..clear()
      ..addAll({
        'nome': Validators.nome(nome),
        'email': Validators.email(email),
        'usuario': Validators.usuario(usuario),
        if (atual.papel == Papel.professor) 'escola': Validators.escola(escola),
        if (atual.papel == Papel.aluno) 'turma': Validators.turma(turma),
      });
    erros.removeWhere((_, mensagem) => mensagem == null);
    erroGeral = null;

    if (erros.isNotEmpty) {
      notifyListeners();
      return false;
    }

    carregando = true;
    notifyListeners();

    try {
      final atualizado = await _usuarios.atualizar(
        atual.copiarCom(
          nome: nome,
          email: email,
          usuario: usuario,
          escola: escola,
          turma: turma,
        ),
      );
      _sessao.abrir(atualizado);
      salvo = true;
      return true;
    } on ErroDeDominio catch (e) {
      erroGeral = e.mensagem;
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
```

- [ ] **Step 4: Implementar a tela**

Criar `mobile/lib/features/profile/edit_profile_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/aviso_de_erro.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/papel.dart';
import '../../data/repositories/user_repository.dart';
import 'profile_controller.dart';

/// Edicao de cadastro, para professor e aluno.
///
/// O campo extra segue o papel do usuario logado: escola para professor,
/// turma para aluno. Senha nao se altera por aqui.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _usuario = TextEditingController();
  final _extra = TextEditingController();

  late final ProfileController _controller;
  bool _preenchido = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(
      usuarios: context.read<UserRepository>(),
      sessao: context.read<SessionScope>(),
    )..addListener(_aoMudar);
  }

  void _aoMudar() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_aoMudar);
    _controller.dispose();
    for (final campo in [_nome, _email, _usuario, _extra]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    final papel = context.read<SessionScope>().usuario?.papel;
    final ok = await _controller.salvar(
      nome: _nome.text,
      email: _email.text,
      usuario: _usuario.text,
      escola: papel == Papel.professor ? _extra.text : null,
      turma: papel == Papel.aluno ? _extra.text : null,
    );
    if (!ok || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Dados atualizados')));
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessionScope>();
    final usuario = sessao.usuario;

    if (usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (_) => false);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    // Preenche uma vez so: repetir a cada build apagaria o que o usuario
    // digitou.
    if (!_preenchido) {
      _nome.text = usuario.nome;
      _email.text = usuario.email;
      _usuario.text = usuario.usuario;
      _extra.text = usuario.escola ?? usuario.turma ?? '';
      _preenchido = true;
    }

    final ehProfessor = usuario.papel == Papel.professor;
    final erros = _controller.erros;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                gradient: ehProfessor
                    ? AppColors.headerGradient
                    : AppColors.greenHeaderGradient,
                child: TopBar(
                  titulo: 'Editar Perfil',
                  onVoltar: () => Navigator.maybePop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Nome completo',
                      controller: _nome,
                      icon: Icons.person,
                      errorText: erros['nome'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail',
                      controller: _email,
                      icon: Icons.email,
                      errorText: erros['email'],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nome de usuário',
                      controller: _usuario,
                      icon: Icons.alternate_email,
                      errorText: erros['usuario'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: ehProfessor ? 'Escola' : 'Turma',
                      controller: _extra,
                      icon: ehProfessor ? Icons.school : Icons.group,
                      errorText: erros[ehProfessor ? 'escola' : 'turma'],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _salvar(),
                    ),
                    const SizedBox(height: 24),
                    if (_controller.erroGeral != null) ...[
                      AvisoDeErro(mensagem: _controller.erroGeral!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: 'Salvar',
                      icon: Icons.save,
                      variant: ehProfessor
                          ? AppButtonVariant.primary
                          : AppButtonVariant.green,
                      onPressed: _salvar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Registrar a rota**

Em `mobile/lib/core/routes.dart`:

```dart
import '../features/profile/edit_profile_screen.dart';
```

```dart
        editProfile: (_) => const EditProfileScreen(),
```

- [ ] **Step 6: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/edit_profile_screen_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/features/profile mobile/lib/core/routes.dart mobile/test/features/edit_profile_screen_test.dart
git commit -m "feat: adiciona edicao de cadastro para professor e aluno

Uma tela para os dois papeis, com o campo extra seguindo o papel do usuario
logado. A sessao e conferida antes de qualquer escrita: expirada, nada muda
e a tela volta ao login. Senha nao se altera por aqui.

Cobre CT11 e CT12, funcionais e nao funcionais."
```

---

### Task 18: Recuperação de senha, casca navegável

Existe no protótipo, não tem caso de teste. Entra como casca honesta: diz que ainda não funciona, em vez de simular um envio que não acontece.

**Files:**
- Create: `mobile/lib/features/auth/forgot_password_screen.dart`
- Modify: `mobile/lib/core/routes.dart`
- Test: `mobile/test/features/forgot_password_screen_test.dart`

**Interfaces:**
- Consumes: `Rotas`, `AppTheme`, `GradientHeader`, `TopBar`, `AppButton`.
- Produces: `class ForgotPasswordScreen extends StatelessWidget`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `mobile/test/features/forgot_password_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/routes.dart';
import 'package:bncc_play_mobile/core/theme/app_theme.dart';
import 'package:bncc_play_mobile/features/auth/forgot_password_screen.dart';

Future<void> pumpTela(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const ForgotPasswordScreen(),
      routes: {Rotas.login: (_) => const Scaffold(body: Text('tela de login'))},
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('avisa que o recurso ainda nao esta disponivel',
        (tester) async {
      await pumpTela(tester);

      expect(find.text('Recuperar senha'), findsOneWidget);
      expect(
        find.text(
          'A recuperação de senha por e-mail depende de servidor e chega numa próxima entrega.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('nao pede e-mail, para nao simular envio que nao acontece',
        (tester) async {
      await pumpTela(tester);

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Voltar ao login leva ao login', (tester) async {
      await pumpTela(tester);

      await tester.tap(find.text('Voltar ao login'));
      await tester.pumpAndSettle();

      expect(find.text('tela de login'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e conferir que falha**

```bash
cd mobile && flutter test test/features/forgot_password_screen_test.dart
```
Esperado: falha de compilação — `forgot_password_screen.dart` não existe.

- [ ] **Step 3: Implementar**

Criar `mobile/lib/features/auth/forgot_password_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/top_bar.dart';

/// Casca da recuperacao de senha.
///
/// O prototipo tem um fluxo de quatro passos, mas nenhum caso de teste o
/// cobre e o envio de e-mail depende de servidor. Pedir o e-mail aqui
/// simularia um envio que nao acontece, entao a tela apenas explica.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                child: TopBar(
                  titulo: 'Recuperar senha',
                  onVoltar: () => Navigator.maybePop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 56,
                      color: AppColors.purple,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'A recuperação de senha por e-mail depende de servidor e chega numa próxima entrega.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Voltar ao login',
                      icon: Icons.arrow_back,
                      variant: AppButtonVariant.ghost,
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, Rotas.login),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Registrar a rota**

Em `mobile/lib/core/routes.dart`:

```dart
import '../features/auth/forgot_password_screen.dart';
```

```dart
        forgotPassword: (_) => const ForgotPasswordScreen(),
```

- [ ] **Step 5: Rodar e conferir que passa**

```bash
cd mobile && flutter test test/features/forgot_password_screen_test.dart && flutter analyze
```
Esperado: todos passando e `No issues found.`

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/features/auth/forgot_password_screen.dart mobile/lib/core/routes.dart mobile/test/features/forgot_password_screen_test.dart
git commit -m "feat: adiciona a casca da recuperacao de senha

Sem caso de teste no documento e sem servidor para enviar e-mail, a tela
explica em vez de pedir o e-mail e simular um envio que nao acontece."
```

---

### Task 19: Teste de integração ponta a ponta

Os testes de widget montam uma tela por vez. Este monta o app inteiro, com o `main.dart` de verdade, e percorre cadastro → sair → login → editar perfil.

**Files:**
- Create: `mobile/integration_test/fluxo_completo_test.dart`
- Test: ele mesmo

**Interfaces:**
- Consumes: `BnccPlayApp`, `AppDatabase`, `Rotas`.
- Produces: nada consumido por outra tarefa.

- [ ] **Step 1: Escrever o teste**

Criar `mobile/integration_test/fluxo_completo_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase banco;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    banco = await AppDatabase.abrir(caminho: inMemoryDatabasePath);
  });
  tearDown(() async => banco.fechar());

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(BnccPlayApp(banco: banco));
    await tester.pumpAndSettle();
  }

  testWidgets('cadastro, logout, login e alteracao de cadastro',
      (tester) async {
    await abrirApp(tester);

    // Splash -> escolha de perfil -> cadastro de professor
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sou Professor(a)'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'Maria Silva');
    await tester.enterText(campos.at(1), 'professor@escola.com');
    await tester.enterText(campos.at(2), 'mariasilva');
    await tester.enterText(campos.at(3), 'E.E. Monteiro Lobato');
    await tester.enterText(campos.at(4), 'Professor@123');
    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria!'), findsOneWidget);

    // Home -> perfil -> sair
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('professor@escola.com'), findsOneWidget);

    await tester.tap(find.text('Sair da Conta'));
    await tester.pumpAndSettle();
    expect(find.text('BNCC Play'), findsOneWidget);

    // Login com a conta recem-criada
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'professor@escola.com');
    await tester.enterText(find.byType(TextField).at(1), 'Professor@123');
    await tester.tap(find.widgetWithText(InkWell, 'Entrar').last);
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria!'), findsOneWidget);

    // Perfil -> editar -> salvar
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar Perfil'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(3), 'E.E. Santos Dumont');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Dados atualizados'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('E.E. Santos Dumont'), findsOneWidget);
  });

  testWidgets('cinco senhas erradas bloqueiam o login', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sou Aluno(a)'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'Joao Santos');
    await tester.enterText(campos.at(1), 'joao@email.com');
    await tester.enterText(campos.at(2), 'joaosantos');
    await tester.enterText(campos.at(3), '9 ano B');
    await tester.enterText(campos.at(4), 'Aluno@12345');
    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da Conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.enterText(find.byType(TextField).at(0), 'joao@email.com');
      await tester.enterText(find.byType(TextField).at(1), 'errada123');
      await tester.tap(find.widgetWithText(InkWell, 'Entrar').last);
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('Muitas tentativas'), findsOneWidget);
  });
}
```

O `find.widgetWithText(InkWell, 'Entrar').last` é necessário no login porque "Entrar" aparece também no rodapé de outras telas empilhadas; o botão é o último na árvore.

- [ ] **Step 2: Rodar**

```bash
cd mobile && flutter test integration_test/fluxo_completo_test.dart
```
Esperado: os dois testes passando. Se algum `tap` não achar o alvo, rodar com `-r expanded` e conferir em que tela o fluxo parou.

- [ ] **Step 3: Commit**

```bash
git add mobile/integration_test
git commit -m "test: adiciona o fluxo ponta a ponta do ciclo 1

Monta o app de verdade sobre banco em memoria e percorre cadastro, saida,
login e alteracao de cadastro. Cobre tambem o bloqueio apos cinco senhas
erradas atravessando as telas, e nao so o repositorio."
```

---

### Task 20: Documento de casos de teste

**Files:**
- Create: `docs/casos-de-teste-origem.md`
- Create: `docs/casos-de-teste.md`

**Interfaces:**
- Consumes: os nomes de grupo e arquivo de teste de todas as tarefas anteriores.
- Produces: nada consumido por código.

- [ ] **Step 1: Trazer o documento de origem para o repositório**

```bash
cp "/home/diogomnd/Downloads/Casos de Testes - ESA.md" docs/casos-de-teste-origem.md
```

Acrescentar no topo do arquivo copiado:

```markdown
> Documento original de casos de teste, como recebido. O acompanhamento da
> execução está em `casos-de-teste.md`.
```

- [ ] **Step 2: Levantar os nomes reais dos testes**

```bash
cd mobile && grep -rn "group('CT" test/ integration_test/
```
Esperado: os grupos CT01, CT02, CT03, CT04, CT11 e CT12 nos arquivos de repositório e de tela. Usar exatamente esses nomes na coluna Automação — a coluna só vale se `flutter test --plain-name 'CT01'` encontrar o que ela promete.

- [ ] **Step 3: Escrever o documento**

Criar `docs/casos-de-teste.md`:

````markdown
# Casos de teste — execução

Acompanhamento da execução dos casos de teste definidos em
`casos-de-teste-origem.md`. Uma linha por caso e por tipo.

O aplicativo desta fase roda **local, sem servidor** (ver
`superpowers/specs/2026-07-31-app-flutter-ciclo1-design.md`). Os casos que
dependem de rede ou de concorrência entre máquinas estão marcados como
**N/A (versão local)**, com a justificativa na própria linha — não foram
omitidos.

## Status

| Status | Significado |
|---|---|
| Automatizado | Existe teste automatizado que executa o caso |
| Manual | Executado a mão, sem automação |
| Pendente (ciclo N) | Depende de funcionalidade ainda não implementada |
| N/A (versão local) | Não exercitável sem servidor |

## Como executar

```bash
cd mobile
flutter test                                  # suíte inteira
flutter test --plain-name 'CT01'              # um caso específico
flutter test integration_test/                # fluxo ponta a ponta
```

## Ciclo 1 — autenticação, cadastro e perfis

| CT | Tipo | Pré-condição | Dados de entrada | Resultado esperado | Automação | Status |
|---|---|---|---|---|---|---|
| CT01 Login do professor | Funcional | Professor cadastrado | professor@escola.com / Professor@123 | Autentica e exibe a tela inicial | `test/data/auth_repository_test.dart::CT01 - Efetivacao de Login do Professor > funcional: credenciais validas autenticam o professor`; `test/features/login_screen_test.dart::CT01 ... > funcional: credenciais validas abrem a home do professor` | Automatizado |
| CT01 Login do professor | Não funcional (segurança) | Professor cadastrado | Cinco tentativas com senha incorreta | Bloqueia novas tentativas e informa o usuário | `test/data/auth_repository_test.dart::CT01 ... > nao funcional: cinco senhas erradas bloqueiam a conta`, `> nao funcional: o bloqueio informa quantos segundos faltam`, `> nao funcional: passados 60 segundos o login volta a funcionar`; `integration_test/fluxo_completo_test.dart::cinco senhas erradas bloqueiam o login` | Automatizado |
| CT02 Login do aluno | Funcional | Aluno cadastrado | E-mail e senha corretos | Exibe a tela inicial do aluno | `test/data/auth_repository_test.dart::CT02 - Efetivacao de Login do Aluno > funcional: o aluno entra com as proprias credenciais`; `test/features/login_screen_test.dart::CT02 ... > funcional: o aluno cai na home do aluno` | Automatizado |
| CT02 Login do aluno | Não funcional (comunicação segura) | — | Acesso sem conexão segura (HTTP) | Sistema força HTTPS | — | N/A (versão local): o app não faz tráfego de rede nesta fase. Entra no ciclo com servidor. |
| CT03 Cadastro de professor | Funcional | Nenhuma conta com o mesmo e-mail | Nome, e-mail, escola, senha | Professor cadastrado com sucesso | `test/data/user_repository_test.dart::CT03 - Cadastro de Professor > funcional: cadastra e devolve o professor com id`; `test/features/register_teacher_screen_test.dart::CT03 ... > funcional: cadastro valido grava e abre a home` | Automatizado |
| CT03 Cadastro de professor | Não funcional (minimização de dados) | — | Cadastro com campos extras | Solicita apenas os campos obrigatórios | `test/data/user_repository_test.dart::CT03 ... > nao funcional: minimizacao, a linha so tem os campos previstos`; `test/features/register_teacher_screen_test.dart::CT03 ... > nao funcional: minimizacao, so os cinco campos previstos` | Automatizado |
| CT04 Cadastro de aluno | Funcional | Nenhuma conta com o mesmo e-mail | Nome, e-mail, turma, senha | Conta criada com sucesso | `test/data/user_repository_test.dart::CT04 - Cadastro de Aluno > funcional: cadastra o aluno com turma`; `test/features/register_student_screen_test.dart::CT04 ... > funcional: conta criada com sucesso` | Automatizado |
| CT04 Cadastro de aluno | Não funcional (tratamento de dados) | — | Caracteres especiais e textos longos | Valida os campos e impede entradas inválidas | `test/unit/validators_test.dart` (grupos `Validators.*`); `test/unit/sanitizer_test.dart`; `test/features/register_student_screen_test.dart::CT04 ... > nao funcional: script no nome nao chega ao banco`, `> nao funcional: recusa texto longo demais na turma` | Automatizado |
| CT11 Alteração de cadastro do aluno | Funcional | Aluno autenticado | Novo e-mail | Dados alterados | `test/data/user_repository_test.dart::CT11 e CT12 - Alteracao de cadastro > funcional: altera o e-mail do aluno`; `test/features/edit_profile_screen_test.dart::CT11 ... > funcional: novo e-mail e salvo` | Automatizado |
| CT11 Alteração de cadastro do aluno | Não funcional (segurança) | — | Tentativa sem autenticação | Alteração bloqueada | `test/features/edit_profile_screen_test.dart::CT11 ... > nao funcional: sem sessao a tela manda para o login`; `test/unit/session_scope_test.dart::CT12 - expiracao de sessao > nao funcional: exigirUsuario lanca quando a sessao expirou` | Automatizado |
| CT12 Alteração de cadastro do professor | Funcional | Professor autenticado | Novo nome da instituição | Cadastro atualizado | `test/data/user_repository_test.dart::CT11 e CT12 ... > funcional: altera a escola do professor`; `test/features/edit_profile_screen_test.dart::CT12 ... > funcional: nova instituicao e salva` | Automatizado |
| CT12 Alteração de cadastro do professor | Não funcional (autenticação) | Professor autenticado | Sessão expirada | Solicita novo login | `test/unit/session_scope_test.dart::CT12 - expiracao de sessao` (todos); `test/features/edit_profile_screen_test.dart::CT12 ... > nao funcional: sessao expirada bloqueia a alteracao` | Automatizado |

## Ciclos seguintes

| CT | Tipo | Resultado esperado | Status |
|---|---|---|---|
| CT05 Seleção do eixo da BNCC | Funcional | Questões referentes ao eixo escolhido | Pendente (ciclo 2) |
| CT05 Seleção do eixo da BNCC | Não funcional | Troca de eixo em menos de 2 segundos | Pendente (ciclo 2) |
| CT06 Cadastro de questões | Funcional | Questão salva no banco | Pendente (ciclo 2) |
| CT06 Cadastro de questões | Não funcional (XSS) | Scripts são bloqueados | Pendente (ciclo 2) — o `Sanitizer` que atende este caso já existe e está coberto por `test/unit/sanitizer_test.dart` |
| CT07 Definição do nível de dificuldade | Funcional | Questão classificada corretamente | Pendente (ciclo 2) |
| CT07 Definição do nível de dificuldade | Não funcional | Sem degradação perceptível | Pendente (ciclo 2) |
| CT08 Lista de questões por eixo | Funcional | Somente questões do eixo | Pendente (ciclo 2) |
| CT08 Lista de questões por eixo | Não funcional | Resposta abaixo de 3 segundos | Pendente (ciclo 2) |
| CT09 Alteração de questão | Funcional | Questão atualizada | Pendente (ciclo 2) |
| CT09 Alteração de questão | Não funcional (concorrência) | Sistema evita conflito de versões | N/A (versão local): um dispositivo, um usuário por vez. Entra no ciclo com servidor. |
| CT10 Remoção de questão | Funcional | Questão deixa de aparecer na listagem | Pendente (ciclo 2) |
| CT10 Remoção de questão | Não funcional (permissões) | Aluno não consegue excluir | Pendente (ciclo 2) — a guarda `Permission.requireRole` já existe e está coberta por `test/unit/session_scope_test.dart::Permission.requireRole` |
| CT13 Sistema gamificado | Funcional | Resposta registrada e feedback apresentado | Pendente (ciclo 3) |
| CT13 Sistema gamificado | Não funcional | 100 alunos simultâneos sem travamento | N/A (versão local): depende de servidor. |
| CT14 Pontuação e recompensas | Funcional | Pontos adicionados | Pendente (ciclo 3) |
| CT14 Pontuação e recompensas | Não funcional (integridade) | Alteração manual rejeitada | Pendente (ciclo 3) |
| CT15 Ranking de jogadores | Funcional | Ranking ordenado corretamente | Pendente (ciclo 3) |
| CT15 Ranking de jogadores | Não funcional (anonimização) | Somente apelidos aparecem | Pendente (ciclo 3) |
| CT16 Multiplayer em sala | Funcional | Todos entram na mesma sessão | Pendente (ciclo 3) — a sala é tela navegável sem lógica nesta fase |
| CT16 Multiplayer em sala | Não funcional | 50 conexões simultâneas | N/A (versão local): depende de servidor. |
| CT17 Dashboard pedagógico | Funcional | Dashboard carregado corretamente | Pendente (ciclo 4) |
| CT17 Dashboard pedagógico | Não funcional (controle de acesso) | Aluno tem acesso negado | Pendente (ciclo 4) — a guarda de papel já existe |
| CT18 Relatórios de desempenho | Funcional | Relatório disponível | Pendente (ciclo 4) |
| CT18 Relatórios de desempenho | Não funcional (autorização) | Acesso impedido e tentativa registrada | Pendente (ciclo 4) |

## Resumo

| Situação | Casos |
|---|---|
| Automatizado | 12 |
| Pendente (ciclos 2 a 4) | 20 |
| N/A (versão local) | 4 |
| **Total** | **36** |
````

- [ ] **Step 4: Conferir que a coluna Automação não mente**

```bash
cd mobile && for ct in CT01 CT02 CT03 CT04 CT11 CT12; do echo "== $ct"; flutter test --plain-name "$ct" 2>&1 | tail -2; done
```
Esperado: cada CT roda ao menos um teste e todos passam. Se algum devolver "No tests match", o nome do grupo no documento diverge do código — corrigir o documento, não o teste.

- [ ] **Step 5: Rodar a suíte inteira uma última vez**

```bash
cd mobile && flutter analyze && flutter test && flutter test integration_test/
```
Esperado: `No issues found.` e tudo verde. Anotar o número total de testes no corpo do commit.

- [ ] **Step 6: Commit**

```bash
git add docs/casos-de-teste.md docs/casos-de-teste-origem.md
git commit -m "docs: adiciona o acompanhamento de execucao dos casos de teste

Uma linha por caso e por tipo, com a coluna de automacao apontando para o
grupo de teste que executa cada um. Os casos que dependem de servidor ficam
como N/A com a justificativa na propria linha, em vez de omitidos. Os
ciclos 2 a 4 ja entram como Pendente, para o documento nascer completo."
```

---

## Verificação final do ciclo

Depois da Task 20, antes de abrir o PR:

- [ ] `cd mobile && flutter analyze` → `No issues found.`
- [ ] `cd mobile && flutter test` → tudo verde
- [ ] `cd mobile && flutter test integration_test/` → tudo verde
- [ ] `cd mobile && flutter build apk --debug` → build conclui
- [ ] Abrir o app num emulador e percorrer: splash → criar conta professor → home → perfil → editar → salvar → sair → login. Conferir que o visual bate com o protótipo.
- [ ] `git log --oneline main..` → um commit por tarefa, todos em português
- [ ] Atualizar `backlog.md`: US02 e US03 agora pedem Escola e Turma, divergência registrada no spec

## Notas de auto-revisão

Três pontos que ficaram deliberadamente assim:

1. **`AppButton` ganha uma terceira variante na Task 14**, não na Task 2. Antecipar a variante verde sem tela que a use deixaria código morto entre as tarefas.
2. **`AvisoDeErro` e `AvisoDeCiclo` nascem privados e são extraídos** nas Tasks 14 e 15, quando aparece o segundo consumidor. Extrair antes seria adivinhação.
3. **A tela de login perde o botão "Entrar como Aluno"** na Task 11. É a única remoção de elemento do protótipo neste ciclo, e o motivo está no commit: com um formulário único que decide o destino pelo papel, o botão não tem função.
4. **As Tasks 14, 15 e 16 descrevem a segunda tela do par como uma lista de trocas sobre a primeira**, em vez de repetir o arquivo inteiro. As listas são exaustivas — cada string, ícone, cor e destino está escrito — mas elas pressupõem que a tarefa anterior do par já foi executada. **Executar 13 antes de 14, 15 antes de sua segunda tela, e 16 na ordem dada.** Fora dessa ordem, o executor não tem o arquivo de referência.

