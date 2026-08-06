import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'seed_questoes.dart';

/// Banco local do app.
///
/// A versao sobe a cada ciclo; `onUpgrade` acrescentara tabela sem apagar o
/// que ja existe.
class AppDatabase {
  AppDatabase._(this._db);

  /// Ciclo 1: users, login_attempts.
  /// Ciclo 2: questoes.
  /// Ciclo 3: partidas, ranking, participacoes.
  /// Ciclo 4: categorias, respostas e vinculo aluno-professor.
  static const int versaoAtual = 4;
  static const String _arquivo = 'bncc_play.db';

  final Database _db;

  Database get db => _db;

  static Future<AppDatabase> abrir({String? caminho}) async {
    final destino = caminho ?? p.join(await getDatabasesPath(), _arquivo);

    final banco = await openDatabase(
      destino,
      version: versaoAtual,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await _criarVersao1(db);
        await _criarVersao2(db);
        await _criarVersao3(db);
        await _criarVersao4(db);
      },
      onUpgrade: (db, anterior, atual) async {
        if (anterior < 2) {
          await _criarVersao2(db);
        }
        if (anterior < 3) {
          await _criarVersao3(db);
        }
        if (anterior < 4) {
          await _criarVersao4(db);
        }
      },
    );

    // Popula com seed se não houver questões.
    final count = Sqflite.firstIntValue(
      await banco.rawQuery('SELECT COUNT(*) FROM questoes'),
    );
    if (count == 0) {
      await popularBancoSeed(AppDatabase._(banco));
    } else {
      await corrigirAcentuacaoSeed(AppDatabase._(banco));
    }

    return AppDatabase._(banco);
  }

  /// Cria banco de teste em memoria com todas as tabelas.
  ///
  /// Usado em `test/support/db_de_teste.dart`.
  static Future<AppDatabase> abrirTeste() async {
    final caminho =
        '${inMemoryDatabasePath}_${DateTime.now().microsecondsSinceEpoch}';
    final banco = await openDatabase(
      caminho,
      version: versaoAtual,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await _criarVersao1(db);
        await _criarVersao2(db);
        await _criarVersao3(db);
        await _criarVersao4(db);
      },
    );
    return AppDatabase._(banco);
  }

  // --- Ciclo 1 -----------------------------------------------------------

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

  // --- Ciclo 2 -----------------------------------------------------------

  static Future<void> _criarVersao2(Database db) async {
    await db.execute('''
      CREATE TABLE questoes (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        enunciado       TEXT    NOT NULL,
        opcao_a         TEXT    NOT NULL,
        opcao_b         TEXT    NOT NULL,
        opcao_c         TEXT    NOT NULL,
        opcao_d         TEXT    NOT NULL,
        resposta_correta TEXT   NOT NULL CHECK (resposta_correta IN ('A', 'B', 'C', 'D')),
        eixo            TEXT    NOT NULL CHECK (eixo IN ('tecnologia', 'cultura', 'impacto')),
        dificuldade     TEXT    NOT NULL CHECK (dificuldade IN ('facil', 'medio', 'dificil')),
        professor_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        criado_em       TEXT    NOT NULL,
        atualizado_em   TEXT    NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_questoes_eixo ON questoes(eixo)');
    await db.execute(
      'CREATE INDEX idx_questoes_dificuldade ON questoes(dificuldade)',
    );
    await db.execute(
      'CREATE INDEX idx_questoes_professor ON questoes(professor_id)',
    );
  }

  // --- Ciclo 3 -----------------------------------------------------------

  static Future<void> _criarVersao3(Database db) async {
    await db.execute('''
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
      )
    ''');

    await db.execute('CREATE INDEX idx_partidas_aluno ON partidas(aluno_id)');

    await db.execute('''
      CREATE TABLE ranking (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        aluno_id        INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
        apelido         TEXT    NOT NULL,
        pontuacao_total INTEGER NOT NULL DEFAULT 0,
        total_jogos     INTEGER NOT NULL DEFAULT 0,
        taxa_acerto     REAL    NOT NULL DEFAULT 0,
        atualizado_em   TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE participacoes (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        partida_id      INTEGER NOT NULL REFERENCES partidas(id) ON DELETE CASCADE,
        aluno_id        INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        apelido         TEXT    NOT NULL,
        pontuacao       INTEGER NOT NULL DEFAULT 0,
        entrou_em       TEXT    NOT NULL
      )
    ''');
  }

  // --- Ciclo 4 -----------------------------------------------------------

  static Future<void> _criarVersao4(Database db) async {
    await db.execute(
      "ALTER TABLE questoes ADD COLUMN categoria TEXT NOT NULL DEFAULT 'Geral'",
    );
    await db.execute('''
      ALTER TABLE users ADD COLUMN professor_id INTEGER
        REFERENCES users(id) ON DELETE SET NULL
    ''');
    await db.execute('''
      CREATE TABLE respostas (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        partida_id      INTEGER NOT NULL REFERENCES partidas(id) ON DELETE CASCADE,
        questao_id      INTEGER NOT NULL REFERENCES questoes(id) ON DELETE CASCADE,
        resposta_aluno  TEXT    NOT NULL,
        correta         INTEGER NOT NULL CHECK (correta IN (0, 1)),
        respondida_em   TEXT    NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_respostas_partida ON respostas(partida_id)',
    );
    await db.execute(
      'CREATE INDEX idx_respostas_questao ON respostas(questao_id)',
    );
    await db.execute('''
      UPDATE users
      SET professor_id = (
        SELECT id FROM users WHERE papel = 'professor' ORDER BY id LIMIT 1
      )
      WHERE papel = 'aluno' AND professor_id IS NULL
    ''');
  }

  Future<void> fechar() => _db.close();
}
