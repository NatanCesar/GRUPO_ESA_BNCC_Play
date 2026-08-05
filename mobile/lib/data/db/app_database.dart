import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Banco local do app.
///
/// A versao sobe a cada ciclo; `onUpgrade` acrescentara tabela sem apagar o
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
