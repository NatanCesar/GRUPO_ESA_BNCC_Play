import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/features/sala/multiplayer_gateway.dart';

void main() {
  test('US18: simula entrada, partida e ranking final da sala', () async {
    final gateway = FakeMultiplayerGateway(
      intervalo: const Duration(milliseconds: 2),
    );
    addTearDown(gateway.dispose);

    gateway.abrirSala('Aluno local');
    expect(gateway.estado, EstadoSala.aguardando);
    expect(gateway.jogadores.single.local, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(gateway.jogadores, hasLength(4));

    gateway.alternarPronto();
    gateway.iniciarPartida();
    expect(gateway.estado, EstadoSala.jogando);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(gateway.estado, EstadoSala.finalizada);
    expect(gateway.rodada, gateway.totalRodadas);
    expect(
      gateway.jogadores.map((jogador) => jogador.pontuacao).toList(),
      orderedEquals(
        gateway.jogadores.map((jogador) => jogador.pontuacao).toList()
          ..sort((a, b) => b.compareTo(a)),
      ),
    );
  });
}
