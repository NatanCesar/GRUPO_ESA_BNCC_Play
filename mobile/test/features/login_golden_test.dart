import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Registra as fontes do pubspec no ambiente de teste.
///
/// Sem isso o `flutter test` desenha tudo com a fonte-placeholder (blocos), e
/// o golden nao serve nem de conferencia visual nem de preview.
Future<void> _loadAppFonts() async {
  const families = {
    'Poppins': [
      'assets/fonts/Poppins-SemiBold.ttf',
      'assets/fonts/Poppins-ExtraBold.ttf',
    ],
    'Inter': [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ],
  };

  for (final family in families.entries) {
    final loader = FontLoader(family.key);
    for (final path in family.value) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await _loadMaterialIcons();
}

/// Material Icons vem do SDK, nao do projeto. Se o caminho nao existir nesta
/// maquina, o golden ainda roda: so desenha os icones como quadrado.
Future<void> _loadMaterialIcons() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;

  final file = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;

  final loader = FontLoader('MaterialIcons');
  final bytes = await file.readAsBytes();
  loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

/// Golden da tela de login no tamanho do frame do Figma (390x844).
///
/// Regenerar com: flutter test test/features/login_golden_test.dart --update-goldens
void main() {
  setUpAll(_loadAppFonts);
  setUpAll(() async => ambiente = await ambienteDeTeste());
  tearDownAll(() async => ambiente.banco.fechar());

  testWidgets('login bate com o golden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
            Rotas.homeTeacher: (_) => const SizedBox(),
            Rotas.homeStudent: (_) => const SizedBox(),
          },
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('../goldens/login_screen.png'),
    );
  });
}
