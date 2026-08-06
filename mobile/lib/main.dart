import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'core/security/password_hasher.dart';
import 'core/session/session_scope.dart';
import 'core/theme/app_theme.dart';
import 'data/db/app_database.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/questao_repository.dart';

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
          create: (_) => UserRepository(
            banco: banco,
            hasher: const PasswordHasher(),
          ),
        ),
        ProxyProvider<UserRepository, AuthRepository>(
          update: (_, usuarios, __) => AuthRepository(
            banco: banco,
            usuarios: usuarios,
            hasher: const PasswordHasher(),
          ),
        ),
        Provider<QuestaoRepository>(
          create: (_) => QuestaoRepository(banco: banco),
        ),
        ChangeNotifierProvider<SessionScope>(create: (_) => SessionScope()),
      ],
      child: MaterialApp(
        title: 'BNCC Play',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: Rotas.splash,
        routes: Rotas.tabela(),
        onGenerateRoute: (settings) {
          if (settings.name == Rotas.jogar) {
            return Rotas.gerarRotaJogar(settings);
          }
          if (settings.name == Rotas.resultado) {
            return Rotas.gerarRotaResultado(settings);
          }
          return null;
        },
      ),
    );
  }
}
