import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/data/models/app_user.dart';
import 'package:bncc_play_mobile/data/models/papel.dart';

void main() {
  final agora = DateTime.utc(2026, 7, 31, 12, 30);

  AppUser professor() => AppUser(
        id: 1,
        nome: 'Maria Silva',
        email: 'professor@escola.com',
        usuario: 'mariasilva',
        papel: Papel.professor,
        escola: 'E.E. Monteiro Lobato',
        criadoEm: agora,
        atualizadoEm: agora,
      );

  group('Papel', () {
    test('converte para o valor gravado no banco', () {
      expect(Papel.professor.valor, 'professor');
      expect(Papel.aluno.valor, 'aluno');
    });

    test('le o valor vindo do banco', () {
      expect(Papel.dePersistencia('professor'), Papel.professor);
      expect(Papel.dePersistencia('aluno'), Papel.aluno);
    });

    test('recusa valor desconhecido', () {
      expect(() => Papel.dePersistencia('admin'), throwsArgumentError);
    });

    test('tem rotulo para a interface', () {
      expect(Papel.professor.rotulo, 'Professor(a)');
      expect(Papel.aluno.rotulo, 'Aluno(a)');
    });
  });

  group('AppUser.paraLinha', () {
    test('grava data em ISO-8601 UTC', () {
      final linha = professor().paraLinha(senhaHash: 'h', salt: 's');

      expect(linha['criado_em'], '2026-07-31T12:30:00.000Z');
      expect(linha['atualizado_em'], '2026-07-31T12:30:00.000Z');
    });

    test('grava o papel como texto e leva hash e salt', () {
      final linha = professor().paraLinha(senhaHash: 'h', salt: 's');

      expect(linha['papel'], 'professor');
      expect(linha['senha_hash'], 'h');
      expect(linha['salt'], 's');
    });

    test('nao inclui id nulo, para o banco gerar', () {
      final novo = AppUser(
        nome: 'Joao Santos',
        email: 'joao@email.com',
        usuario: 'joaosantos',
        papel: Papel.aluno,
        turma: '9 ano B',
        criadoEm: agora,
        atualizadoEm: agora,
      );

      expect(novo.paraLinha(senhaHash: 'h', salt: 's').containsKey('id'), isFalse);
    });
  });

  group('AppUser.deLinha', () {
    test('reconstroi o usuario a partir da linha', () {
      final linha = <String, Object?>{
        'id': 7,
        'nome': 'Joao Santos',
        'email': 'joao@email.com',
        'usuario': 'joaosantos',
        'papel': 'aluno',
        'escola': null,
        'turma': '9 ano B',
        'avatar': null,
        'criado_em': '2026-07-31T12:30:00.000Z',
        'atualizado_em': '2026-07-31T12:30:00.000Z',
      };

      final user = AppUser.deLinha(linha);

      expect(user.id, 7);
      expect(user.papel, Papel.aluno);
      expect(user.turma, '9 ano B');
      expect(user.escola, isNull);
      expect(user.criadoEm, agora);
    });

    test('ida e volta preserva os campos', () {
      final original = professor();
      final linha = original.paraLinha(senhaHash: 'h', salt: 's')
        ..putIfAbsent('id', () => original.id);

      final voltou = AppUser.deLinha(linha);

      expect(voltou.nome, original.nome);
      expect(voltou.email, original.email);
      expect(voltou.usuario, original.usuario);
      expect(voltou.papel, original.papel);
      expect(voltou.escola, original.escola);
    });
  });

  group('AppUser.copiarCom', () {
    test('troca so o que foi passado', () {
      final novo = professor().copiarCom(email: 'novo@escola.com');

      expect(novo.email, 'novo@escola.com');
      expect(novo.nome, 'Maria Silva');
      expect(novo.id, 1);
    });
  });
}
