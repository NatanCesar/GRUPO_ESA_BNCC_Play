# App Flutter BNCC Play — Ciclo 3 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Entregar o loop de jogo single-player (CT13), pontuacao com XP e streak (CT14), ranking (CT15) e a tela de sala multiplayer (CT16 como casca navegavel).

**Architecture:** Segue a mesma arquitetura do Ciclo 1-2: feature-first, repositorios injetados com `provider`. Persistencia em sqflite versionado (v3).

**Tech Stack:** Flutter (Dart SDK ^3.12.2), sqflite, provider. Sem alteracao no backend.

---

## Estrutura de arquivos

| Arquivo | Responsabilidade |
|---|---|
| `lib/data/models/partida.dart` | Modelo de sessao de jogo |
| `lib/data/models/participacao.dart` | Modelo de participacao em partida |
| `lib/data/models/ranking.dart` | Modelo de entrada no ranking |
| `lib/data/repositories/game_repository.dart` | Logica de jogo, pontuacao e ranking |
| `lib/data/repositories/ranking_repository.dart` | Persistencia do ranking |
| `lib/features/game/game_screen.dart` | Tela de jogar com loop de questao |
| `lib/features/game/resultado_screen.dart` | Tela de resultado final |
| `lib/features/ranking/ranking_screen.dart` | Tela de ranking |
| `lib/features/sala/sala_screen.dart` | Tela de sala multiplayer (casca) |

---

## Modelo de dados

### Partida (sessao de jogo)

Uma partida representa uma sessao de jogo do aluno:
- `id`: identificador unico
- `alunoId`: FK para users
- `eixo`: eixo BNCC filtrado (pode ser null = todos)
- `questoes`: lista de IDs de questoes selecionadas
- `pontuacao`: XP total gained
- `streak`: maior sequencia de acertos
- `respondidas`: numero de questoes respondidas
- `acertos`: numero de acertos
- `iniciadaEm`: timestamp de inicio
- `terminadaEm`: timestamp de fim (null se em andamento)

### Participacao

Quando um aluno entra em uma sala (mesmo que a sala nao esteja implementada):
- `id`: identificador unico
- `partidaId`: FK para partida
- `alunoId`: FK para users
- `apelido`: nickname shown in sala
- `pontuacao`: XP acumulado na sala
- `entrouEm`: timestamp

### Ranking

Tabela de ranking geral (single-player):
- `id`: identificador unico
- `alunoId`: FK para users
- `apelido`: nickname visivel no ranking
- `pontuacaoTotal`: XP total acumulado
- `totalJogos`: numero de partidas jogadas
- `taxaAcerto`: percentual de acerto historico
- `atualizadoEm`: timestamp da ultima atualizacao

---

## Tasks

### Task 1: Schema do banco v3 — partidas e ranking

**Files:**
- Modify: `mobile/lib/data/db/app_database.dart`
- Modify: `mobile/test/support/db_de_teste.dart`

- [ ] **Step 1: Atualizar AppDatabase para versao 3**

Adicionar metodo `_criarVersao3` com:
```sql
CREATE TABLE partidas (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  aluno_id        INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  eixo            TEXT,
  pontuacao       INTEGER NOT NULL DEFAULT 0,
  streak          INTEGER NOT NULL DEFAULT 0,
  respondidas     INTEGER NOT NULL DEFAULT 0,
  acertos         INTEGER NOT NULL DEFAULT 0,
  iniciada_em     TEXT    NOT NULL,
  terminada_em    TEXT
);

CREATE INDEX idx_partidas_aluno ON partidas(aluno_id);

CREATE TABLE ranking (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  aluno_id        INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  apelido         TEXT    NOT NULL,
  pontuacao_total INTEGER NOT NULL DEFAULT 0,
  total_jogos     INTEGER NOT NULL DEFAULT 0,
  taxa_acerto     REAL    NOT NULL DEFAULT 0,
  atualizado_em   TEXT    NOT NULL
);

CREATE TABLE participacoes (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  partida_id      INTEGER NOT NULL REFERENCES partidas(id) ON DELETE CASCADE,
  aluno_id        INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  apelido         TEXT    NOT NULL,
  pontuacao       INTEGER NOT NULL DEFAULT 0,
  entrou_em       TEXT    NOT NULL
);
```

- [ ] **Step 2: Atualizar versaoAtual para 3**

- [ ] **Step 3: Commit**

---

### Task 2: Modelo Partida e Participacao

**Files:**
- Create: `mobile/lib/data/models/partida.dart`
- Create: `mobile/lib/data/models/participacao.dart`
- Test: `mobile/test/unit/partida_model_test.dart`

- [ ] **Implementar modelo Partida** com:
  - Campos: id, alunoId, eixo (String?), pontuacao, streak, respondidas, acertos, iniciadaEm, terminadaEm
  - Metodo `deLinha(Map<String, Object?>)`
  - Metodo `paraLinha()`
  - Metodo `copiarCom(...)` para atualizar campos
  - Metodo `get acertoPercentual` (double 0-100)

- [ ] **Implementar modelo Participacao** com:
  - Campos: id, partidaId, alunoId, apelido, pontuacao, entrouEm
  - Metodo `deLinha(Map<String, Object?>)`
  - Metodo `paraLinha()`

- [ ] **Commit**

---

### Task 3: Modelo Ranking

**Files:**
- Create: `mobile/lib/data/models/ranking.dart`
- Test: `mobile/test/unit/ranking_model_test.dart`

- [ ] **Implementar modelo RankingEntry** com:
  - Campos: id, alunoId, apelido, pontuacaoTotal, totalJogos, taxaAcerto, atualizadoEm
  - Metodo `deLinha(Map<String, Object?>)`
  - Metodo `paraLinha()`
  - Metodo `copiarCom(...)`

- [ ] **Commit**

---

### Task 4: GameRepository — loop de jogo

**Files:**
- Create: `mobile/lib/data/repositories/game_repository.dart`
- Test: `mobile/test/data/game_repository_test.dart`

- [ ] **Implementar GameRepository** com:
  - `Future<Partida> iniciarPartida(int alunoId, {String? eixo})` — cria partida com 5 questoes aleatorias do eixo
  - `Future<Partida> registrarResposta(int partidaId, int questaoId, String respostaAluno, bool acertou)` — atualiza pontuacao e streak
  - `Future<Partida> encerrarPartida(int partidaId)` — marca terminadaEm e calcula stats
  - `Future<Partida?> partidaEmAndamento(int alunoId)` — retorna partida ativa se existir
  - `Future<Partida?> porId(int id)`

**Logica de pontuacao:**
- Acerto = +100 XP
- Acerto com streak >= 3 = +100 + (streak * 10) XP bonus
- Erro = streak reseta para 0

- [ ] **Commit**

---

### Task 5: RankingRepository

**Files:**
- Create: `mobile/lib/data/repositories/ranking_repository.dart`
- Test: `mobile/test/data/ranking_repository_test.dart`

- [ ] **Implementar RankingRepository** com:
  - `Future<void> atualizarRanking(int alunoId, String apelido, int xpAdicional, int acertos, int total)` — atualiza ou insere entrada
  - `Future<List<RankingEntry>> listarGeral({int limite = 50})` — ranking top N
  - `Future<List<RankingEntry>> listarPorEixo(String eixo, {int limite = 50})` — ranking por eixo
  - `Future<RankingEntry?> posicao(int alunoId)` — posicao do aluno no ranking
  - `Future<int> posicaoOrdinal(int alunoId)` — 1o, 2o, 3o, etc.

- [ ] **Commit**

---

### Task 6: GameScreen — loop de questao (CT13)

**Files:**
- Create: `mobile/lib/features/game/game_screen.dart`
- Create: `mobile/lib/features/game/game_controller.dart`
- Create: `mobile/lib/core/widgets/alternativa_button.dart`
- Create: `mobile/lib/core/widgets/progresso_quiz.dart`

- [ ] **Implementar GameScreen**:
  - Recebe `eixo` como argumento (pode ser null = modo livre)
  - Busca 5 questoes aleatorias do eixo/dificuldade
  - Mostra enunciado e 4 alternativas como botoes
  - Ao selecionar, mostra feedback imediato (verde = acerto, vermelho = erro) por 1.5s
  - Atualiza pontuacao e streak em tempo real
  - Ao final das 5 questoes, navega para ResultadoScreen

**Feedback visual:**
- Alternativa correta: cor verde, icone check
- Alternativa incorreta selecionada: cor vermelha, icone X
- Barra de progresso: quanto falta (1/5, 2/5...)
- Contador de XP atual
- Contador de streak atual (🔥 se >= 3)

- [ ] **Commit**

---

### Task 7: ResultadoScreen (CT14)

**Files:**
- Create: `mobile/lib/features/game/resultado_screen.dart`
- Modify: `mobile/lib/core/routes.dart`

- [ ] **Implementar ResultadoScreen**:
  - Mostra XP ganado na partida
  - Mostra streak maximo
  - Mostra quantidade de acertos / total
  - Mostra posicao no ranking (se entrar no top 50)
  - Botao "Jogar Novamente" → volta para GameScreen
  - Botao "Ver Ranking" → navega para RankingScreen
  - Botao "Inicio" → volta para home do aluno

- [ ] **Commit**

---

### Task 8: RankingScreen (CT15)

**Files:**
- Create: `mobile/lib/features/ranking/ranking_screen.dart`
- Create: `mobile/lib/features/ranking/ranking_controller.dart`
- Modify: `mobile/lib/core/routes.dart`

- [ ] **Implementar RankingScreen**:
  - Tabs: "Geral" | "Tecnologia" | "Cultura Digital" | "Impacto"
  - Lista top 50 com: posicao, apelido, XP total, taxa de acerto
  - Destaque visual para o top 3 (trofeu 🥇🥈🥉)
  - Destaque para o usuario atual
  - Pull-to-refresh

- [ ] **Commit**

---

### Task 9: SalaScreen (CT16 — casca)

**Files:**
- Create: `mobile/lib/features/sala/sala_screen.dart`
- Create: `mobile/lib/core/widgets/jogador_card.dart`
- Modify: `mobile/lib/core/routes.dart`

- [ ] **Implementar SalaScreen** (casca navegavel sem logica real):
  - Header com: nome da sala, codigo de convite
  - Lista de jogadores esperados (placeholder com 3 nomes)
  - Botao "Entrar na Partida" (leva ao GameScreen em modo multiplayer — logica fica para servidor)
  - Aviso: "Modo multiplayer em desenvolvimento"

- [ ] **Commit**

---

### Task 10: Integrar botao "Jogar" na home do aluno

**Files:**
- Modify: `mobile/lib/features/home/home_student_screen.dart`
- Modify: `mobile/lib/core/routes.dart`

- [ ] **Habilitar botao "Jogar"** na navegacao inferior do aluno
- [ ] **Navegacao** de "Jogar" leva a tela de escolha de eixo (ou langsung ke GameScreen com eixo null)
- [ ] **Habilitar botao "Ranking"** na navegacao inferior
- [ ] **Remover aviso de disabled** dos itens da navegacao

- [ ] **Commit**

---

### Task 11: Atualizar banco de questoes com mais dados

- [ ] Adicionar mais questoes ao seed inicial para o jogo ter conteudo
- [ ] Commit

---

## Verificacao final

Depois da Task 11, antes de abrir o PR:

```bash
cd mobile && flutter analyze && flutter test
```

Esperado: `No issues found.` e toda a suite passando.
