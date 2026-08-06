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
