# App Flutter BNCC Play — Ciclo 1: fundação, autenticação e perfis

Data: 2026-07-31
Status: aprovado

## Contexto

O repositório já contém o backlog de produto (20 estórias em 3 entregas), os cenários BDD (CB01–CB20)
e um protótipo navegável gerado no Figma com 23 telas. O documento *Casos de Testes - ESA* define
CT01–CT18, cada um com um teste funcional e um teste não funcional.

Existe um esqueleto Flutter em `mobile/` — ainda fora do controle de versão — com tema, widgets base,
a tela de login e 14 testes de widget. Ele é a base deste ciclo, não é descartado.

O backend atual (`backend/`, Express + Socket.IO + Prisma) modela apenas `Session`, `Player` e `Answer`.
Não tem usuários, autenticação nem questões. Este ciclo **não** o altera.

## Objetivo

Entregar um aplicativo Flutter que roda 100% local, cujo escopo é ditado pelos casos de teste.
Este ciclo cobre CT01, CT02, CT03, CT04, CT11 e CT12 — autenticação, cadastro e alteração cadastral.

Entregáveis:

1. App Flutter navegável com autenticação e perfis reais, persistidos em banco local.
2. Suíte de testes automatizados rastreável aos CTs.
3. `docs/casos-de-teste.md` — documento de execução com o vínculo CT ↔ teste automatizado.

## Decisões que orientam o desenho

| Decisão | Escolha |
|---|---|
| Escopo | Ditado pelos casos de teste CT01–CT18, fatiado em 4 ciclos |
| Backend | Nenhum. App local-only |
| Persistência | sqflite, sobrevive ao fechamento do app |
| Testes não funcionais | Implementar equivalente no app e testar; o que for impossível sem rede vira N/A justificado |
| Multiplayer | Tela navegável sem lógica (ciclo 3) |
| Loop de jogo single-player | Lógica real (ciclo 3) |
| Arquitetura | Feature-first, repositórios injetados com `provider` |

## Fatiamento em ciclos

| Ciclo | CTs | Conteúdo |
|---|---|---|
| **1 (este)** | CT01, CT02, CT03, CT04, CT11, CT12 | Fundação (banco, sessão, DI) + autenticação + cadastros + perfis |
| 2 | CT05–CT10 | Seleção de eixo, CRUD de questões, dificuldade, filtros |
| 3 | CT13–CT16 | Jogo single-player, pontuação, ranking, sala multiplayer (casca) |
| 4 | CT17, CT18 | Dashboard pedagógico e relatórios de desempenho |

Cada ciclo tem seu próprio spec, plano e implementação.

## Arquitetura

Feature-first. Cada pasta em `features/` é uma fatia vertical: telas e o controlador de estado delas.
Tudo que atravessa features mora em `core/`. Acesso a dado mora em `data/`.

```
mobile/lib/
  main.dart
  core/
    theme/          app_colors.dart, app_theme.dart
    widgets/        app_button.dart, app_text_field.dart, gradient_header.dart,
                    top_bar.dart, app_badge.dart, bottom_nav.dart
    validation/     validators.dart, sanitizer.dart
    security/       password_hasher.dart, permission.dart
    session/        session_scope.dart
    routes.dart
  data/
    db/             app_database.dart
    models/         app_user.dart, papel.dart
    repositories/   user_repository.dart, auth_repository.dart
  features/
    auth/           splash_screen.dart, login_screen.dart, register_type_screen.dart,
                    register_teacher_screen.dart, register_student_screen.dart,
                    forgot_password_screen.dart, login_controller.dart, register_controller.dart
    home/           home_teacher_screen.dart, home_student_screen.dart
    profile/        profile_teacher_screen.dart, profile_student_screen.dart,
                    edit_profile_screen.dart, profile_controller.dart
```

`core/theme/` e `core/widgets/` recebem os arquivos que hoje estão em `lib/theme/` e `lib/widgets/`.
`lib/screens/login_screen.dart` vira `lib/features/auth/login_screen.dart`.

### Injeção de dependência

`main.dart` monta a raiz com `MultiProvider`:

- `Provider<AppDatabase>` — instância única do banco.
- `Provider<UserRepository>` e `Provider<AuthRepository>` — construídos a partir do banco.
- `ChangeNotifierProvider<SessionScope>` — usuário logado, papel e último acesso.

Controladores de tela são `ChangeNotifier` e recebem os repositórios pelo construtor. Nenhuma tela
instancia repositório: ou lê do contexto, ou recebe pelo construtor. É isso que permite o teste
de widget rodar sem banco.

### Fronteiras

- **Tela** não conhece SQL. Só fala com o controlador.
- **Controlador** não conhece `sqflite`. Só fala com repositório e expõe estado de UI
  (carregando, erro, sucesso).
- **Repositório** é o único que traduz `Map<String, Object?>` em modelo e vice-versa. É também
  onde a checagem de permissão acontece.
- **Banco** só executa SQL e migração.

## Modelo de dados

`AppDatabase` abre um banco versionado. Ciclo 1 é a versão 1; ciclos seguintes acrescentam tabelas
por `onUpgrade`, sem apagar dados.

```sql
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
);

CREATE TABLE login_attempts (
  email          TEXT PRIMARY KEY,
  falhas         INTEGER NOT NULL DEFAULT 0,
  bloqueado_ate  TEXT
);
```

`escola` é obrigatória para `papel = 'professor'` e nula para aluno; `turma` é o inverso.
A regra é aplicada no repositório, não por constraint, para manter a mensagem de erro em português
e testável.

Datas gravadas como ISO-8601 UTC em `TEXT` — sqflite não tem tipo de data.

### Campos de cadastro

O backlog pede Nome, E-mail, Login e Senha. CT03 acrescenta **Escola** ao professor e CT04
acrescenta **Turma** ao aluno. O protótipo Figma não tem nenhum dos dois. Como este ciclo é orientado
pelos casos de teste, os CTs vencem:

- **Professor:** Nome completo, E-mail institucional, Nome de usuário, Escola, Senha.
- **Aluno:** Nome completo, E-mail, Nome de usuário, Turma, Senha.

Nenhum campo além desses. O teste não funcional de CT03 cobra minimização de dados, então
qualquer campo extra é uma falha, não uma melhoria.

## Autenticação e segurança

O ponto do ciclo: os testes não funcionais dos CTs viram comportamento real do app, não simulação.

### Senha

`PasswordHasher` usa PBKDF2-HMAC-SHA256, 100.000 iterações, salt de 16 bytes por usuário, via
pacote `crypto`. Grava `senha_hash` e `salt` em base64. Nunca existe senha em texto puro no banco
nem em log. A verificação usa comparação de tempo constante.

### Bloqueio por tentativas (CT01, não funcional)

`AuthRepository.login` consulta `login_attempts` antes de validar:

- Se `bloqueado_ate` está no futuro, devolve `LoginBloqueado(segundosRestantes)` sem sequer
  conferir a senha.
- Senha errada incrementa `falhas`. Ao chegar em 5, grava `bloqueado_ate = agora + 60s` e zera
  `falhas`.
- Login com sucesso apaga a linha do e-mail.

A tela mostra "Muitas tentativas. Tente novamente em Ns" com contagem regressiva, e mantém o botão
Entrar desabilitado enquanto durar.

### Sanitização (CT06, não funcional)

`Sanitizer.strip(String)` remove tags HTML e blocos `<script>`, normaliza espaços e corta o
resultado no `maxLength` do campo. Todo texto livre passa por ele antes de chegar ao repositório.
O uso pesado é no ciclo 2 (enunciados de questão), mas o utilitário e seus testes nascem aqui —
nome e escola também são texto livre.

### Validação (CT04, não funcional)

`Validators` concentra as regras, cada uma devolvendo `String?` (mensagem em português ou nulo):

- `email` — formato válido, até 120 caracteres.
- `senha` — mínimo 8 caracteres.
- `nome` — 3 a 80 caracteres depois de sanitizado; rejeita entrada só com espaços.
- `usuario` — 3 a 30 caracteres, apenas letras, números, ponto e sublinhado.
- `escola` / `turma` — 2 a 80 caracteres.

Entrada com caracteres especiais e texto muito longo é rejeitada com mensagem, não truncada em
silêncio.

### Controle de acesso (CT10, CT17 — preparado aqui, exercido nos ciclos 2 e 4)

`SessionScope` guarda o usuário logado e seu papel. `Permission.requireRole(SessionScope, Papel)`
lança `PermissionDeniedException` quando o papel não confere.

A checagem fica **no repositório**, não só na UI. Esconder um botão não é controle de acesso: o teste
precisa conseguir chamar o método diretamente e receber a exceção.

### Expiração de sessão (CT12, não funcional)

`SessionScope` registra `ultimoAcesso`. Toda ação que passa por um repositório atualiza o carimbo.
Passados 30 minutos de inatividade, a sessão é invalidada e a próxima navegação leva ao login com a
mensagem "Sua sessão expirou. Entre novamente".

### Fora de alcance nesta versão

| CT | Item | Motivo |
|---|---|---|
| CT02 não-func | Forçar HTTPS | Não há tráfego de rede na versão local |
| CT16 não-func | 50 conexões simultâneas | Depende de servidor |
| CT13 não-func | 100 alunos simultâneos | Depende de servidor |
| CT09 não-func | Concorrência entre dois professores | Um único dispositivo, um único usuário por vez |

Cada um entra em `docs/casos-de-teste.md` com status **N/A (versão local)** e a justificativa.
Não são omitidos.

## Telas

Todas seguem o protótipo Figma — cores, tipografia (Poppins em títulos e botões, Inter no corpo),
cabeçalho com gradiente, cantos arredondados de 24px, viewport de referência 390×844.

| Tela | Origem no Figma | Estado neste ciclo |
|---|---|---|
| Splash | `SplashScreen` | Nova. Leva a login ou register-type |
| Login | `LoginScreen` | Já existe. Ganha autenticação real e navegação |
| Erro de login | `LoginErrorScreen` | Estado da própria tela de login, não rota separada |
| Escolha de perfil | `RegisterTypeScreen` | Nova |
| Cadastro professor | `RegisterTeacherScreen` | Nova, com campo Escola |
| Cadastro aluno | `RegisterStudentScreen` | Nova, com campo Turma |
| Home professor | `HomeTeacherScreen` | Casca com bottom nav; itens do ciclo 2 em diante ficam inertes |
| Home aluno | `HomeStudentScreen` | Casca com bottom nav |
| Perfil professor | `ProfileTeacherScreen` | Nova, com dados reais do usuário logado |
| Perfil aluno | `ProfileStudentScreen` | Nova, com dados reais do usuário logado |
| Editar perfil | Item "Editar Perfil" do perfil | Nova. Cobre CT11 e CT12 |
| Esqueci minha senha | `ForgotPasswordScreen` | Casca navegável — não há CT para o fluxo |

Estatísticas dos perfis (questões, alunos, turmas, XP, ranking, acertos) e as conquistas do aluno
não têm origem de dado no ciclo 1. Ficam com valor zero e rótulo real, e ganham dado nos ciclos 3 e 4.
Não usar número inventado: um "48 questões" fixo passaria por bug nos ciclos seguintes.

### Navegação

Rotas nomeadas em `core/routes.dart`, navegação por `Navigator.pushNamed`. A raiz decide entre
splash e home conforme houver sessão válida.

```
splash ─┬─> login ─────────────> home-teacher | home-student
        │      └─> forgot-password (casca)
        └─> register-type ─┬─> register-teacher ─> home-teacher
                           └─> register-student ─> home-student

home-teacher ─> profile-teacher ─> edit-profile
home-student ─> profile-student ─> edit-profile
```

Sair da conta limpa `SessionScope` e volta para splash, sem histórico.

## Testes

### Organização

```
mobile/test/
  unit/           validators_test.dart, sanitizer_test.dart,
                  password_hasher_test.dart, lockout_test.dart
  data/           user_repository_test.dart, auth_repository_test.dart
  features/       login_screen_test.dart, register_teacher_screen_test.dart,
                  register_student_screen_test.dart, profile_screen_test.dart,
                  edit_profile_screen_test.dart
  goldens/        login_screen.png (já existe)
mobile/integration_test/
  cadastro_login_perfil_test.dart
```

Os 14 testes de widget que já existem para o login continuam válidos e são movidos para
`test/features/`. Os que dependiam do SnackBar "em desenvolvimento" são reescritos para a navegação
real — a mudança é esperada, não é regressão.

### Banco nos testes

Testes de repositório usam `sqflite_common_ffi` com `inMemoryDatabasePath`, inicializado em
`setUpAll` com `sqfliteFfiInit()`. Cada teste começa com banco limpo.

Testes de widget não tocam o banco: recebem repositório falso pelo construtor do controlador.

### Rastreabilidade

Cada grupo de teste é nomeado pelo caso de teste que cobre:

```dart
group('CT01 - Efetivação de Login do Professor', () {
  test('funcional: credenciais válidas autenticam e abrem a home', ...);
  test('não funcional: cinco senhas erradas bloqueiam por 60 segundos', ...);
});
```

Assim `flutter test --plain-name 'CT01'` roda exatamente o que o documento descreve.

### Documento de casos de teste

`docs/casos-de-teste.md`, uma linha por CT e por tipo:

| Campo | Conteúdo |
|---|---|
| CT | Identificador e título |
| Tipo | Funcional ou não funcional |
| Pré-condição | Estado necessário antes de executar |
| Dados de entrada | Copiados do documento original |
| Passos | Roteiro de execução manual |
| Resultado esperado | Copiado do documento original |
| Automação | `arquivo::nome do teste`, ou vazio |
| Status | Automatizado, Manual, Pendente (ciclo N) ou N/A (versão local) |

Os CTs dos ciclos 2 a 4 já entram no documento com status **Pendente**, para o documento nascer
completo e ir sendo preenchido.

## Dependências novas

| Pacote | Uso |
|---|---|
| `sqflite` | Banco local |
| `path` | Caminho do arquivo do banco |
| `provider` | Injeção de repositórios e estado de sessão |
| `crypto` | PBKDF2-HMAC-SHA256 |
| `sqflite_common_ffi` (dev) | Banco em memória nos testes |
| `integration_test` (dev) | Testes ponta a ponta |

## Tratamento de erro

Repositórios lançam exceções tipadas — `EmailJaCadastradoException`, `UsuarioJaCadastradoException`,
`CredenciaisInvalidasException`, `LoginBloqueadoException`, `PermissionDeniedException`,
`SessaoExpiradaException`. O controlador traduz cada uma numa mensagem em português; a tela só
exibe. Nenhuma exceção de banco vaza para a UI: `AppDatabase` embrulha falha de SQL em
`FalhaDePersistenciaException`.

Erro de campo aparece abaixo do campo, no padrão que a tela de login já usa. Erro de operação
aparece em `SnackBar`.

## Fora de escopo

- `backend/` e `frontend/` permanecem intocados.
- Sincronização com servidor, recuperação de senha por e-mail real, upload de foto.
- Modo escuro: o protótipo define tokens `.dark`, mas nenhum CT o exige.
- iOS: o build alvo é Android, como o APK que já existe em `mobile/dist/`.

## Riscos

| Risco | Mitigação |
|---|---|
| `mobile/` está fora do git e pode se perder | Primeiro passo do plano é versionar a pasta |
| Mover `lib/theme` e `lib/widgets` quebra os testes existentes | Mover e rodar a suíte antes de qualquer feature nova |
| Golden test quebra com mudanças de layout do login | Regerar o golden no mesmo passo da mudança, revisando a imagem |
| Campos Escola/Turma divergem do backlog | Registrado neste spec; o backlog deve ser atualizado ou o desvio anotado no documento de casos de teste |
