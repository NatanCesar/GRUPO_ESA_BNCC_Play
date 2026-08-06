# App Flutter BNCC Play — Ciclo 4 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Entregar o Dashboard pedagogico do professor (CT17) e Relatorios de desempenho (CT18).

**Architecture:** Segue a mesma arquitetura dos ciclos anteriores: feature-first, repositorios injetados com `provider`. Persistencia em sqflite versionado (v4).

**Tech Stack:** Flutter (Dart SDK ^3.12.2), sqflite, provider. Sem alteracao no backend.

---

## Estrutura de arquivos

| Arquivo | Responsabilidade |
|---|---|
| `lib/data/models/estatistica.dart` | Modelo de estatistica agregada |
| `lib/data/repositories/estatistica_repository.dart` | Logica de agregacao de stats |
| `lib/features/dashboard/dashboard_screen.dart` | Tela de dashboard do professor |
| `lib/features/dashboard/dashboard_controller.dart` | Controlador do dashboard |

---

## Modelo de dados

### Estatistica (aggregated view)

Estatisticas agregadas para o professor:
- `totalAlunos`: numero total de alunos
- `totalPartidas`: numero total de partidas
- `mediaPontuacao`: pontuacao media por partida
- `taxaAcertoMedia`: taxa de acerto media geral
- `questoesMaisErradas`: lista de IDs de questoes com menor taxa de acerto
- `alunosPorEixo`: mapa de eixo -> quantidade de alunos

---

## Tasks

### Task 1: Schema do banco v4 — estatisticas

**Files:**
- Modify: `mobile/lib/data/db/app_database.dart`

- [ ] **Step 1: Atualizar AppDatabase para versao 4**
  - Adicionar metodo `_criarVersao4` se necessario (nenhuma tabela nova por enquanto)

- [ ] **Step 2: Commit**

---

### Task 2: Modelo Estatistica

**Files:**
- Create: `mobile/lib/data/models/estatistica.dart`

- [ ] **Implementar modelo EstatisticaGeral** com:
  - Campos: totalAlunos, totalPartidas, mediaPontuacao, taxaAcertoMedia,totalRespostas, totalAcertos
  - Metodo `deLinha(Map<String, Object?>)`

- [ ] **Commit**

---

### Task 3: EstatisticaRepository

**Files:**
- Create: `mobile/lib/data/repositories/estatistica_repository.dart`

- [ ] **Implementar EstatisticaRepository** com:
  - `Future<EstatisticaGeral> gerarEstatisticasGerais(int professorId)` — agrega stats de todas as partidas dos alunos do professor
  - `Future<Map<String, int>> contarAlunosPorEixo(int professorId)` — contagem por eixo
  - `Future<List<({int questaoId, String enunciado, double taxaAcerto})>> questoesMaisDificeis(int professorId, {int limite = 5})` — questoes com menor taxa de acerto

**Logica:**
- Busca todos os alunos do professor
- Para cada aluno, busca suas partidas e calcula stats
- Agrega em medias ponderadas

- [ ] **Commit**

---

### Task 4: DashboardScreen (CT17)

**Files:**
- Create: `mobile/lib/features/dashboard/dashboard_screen.dart`
- Create: `mobile/lib/features/dashboard/dashboard_controller.dart`
- Modify: `mobile/lib/core/routes.dart`

- [ ] **Implementar DashboardScreen**:
  - Header com saudacao ao professor
  - Cards de estatisticas:
    - Total de alunos
    - Total de partidas jogadas
    - Media de pontuacao
    - Taxa de acerto media
  - Grafico simples de barras (questoes mais faceis/dificeis)
  - Lista de alunos com melhor desempenho

**Layout:**
```
+---------------------------+
| Dashboard do Professor    |
+---------------------------+
| [Cards de Stats]          |
| Alunos | Partidas | Media |
+---------------------------+
| Questoes mais faceis:     |
| [lista]                   |
+---------------------------+
| Questoes mais dificeis:  |
| [lista]                   |
+---------------------------+
```

- [ ] **Commit**

---

### Task 5: Integrar dashboard na home do professor

**Files:**
- Modify: `mobile/lib/features/home/home_teacher_screen.dart`

- [ ] **Habilitar navegacao** para o dashboard na home do professor
- [ ] **Cards de acesso rapido** ao dashboard

- [ ] **Commit**

---

### Task 6: Atualizar banco de questoes

- [ ] Adicionar mais questoes ao seed para teste
- [ ] Commit

---

## Verificacao final

```bash
cd mobile && flutter analyze && flutter test
```

Esperado: `No issues found.` e toda a suite passando.
