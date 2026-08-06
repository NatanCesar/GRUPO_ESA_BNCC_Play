import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bncc_play_mobile/data/db/app_database.dart';

/// Abre um banco novo em memoria, com o mesmo schema do app.
///
/// `sqfliteFfiInit` e `databaseFactory` sao globais e idempotentes, entao
/// podem ser chamados a cada teste sem vazamento entre si.
Future<AppDatabase> abrirBancoDeTeste() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return AppDatabase.abrirTeste();
}
