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
