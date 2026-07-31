import 'package:flutter_test/flutter_test.dart';

import 'package:bncc_play_mobile/core/validation/validators.dart';

void main() {
  group('Validators.email', () {
    test('aceita e-mail bem formado', () {
      expect(Validators.email('maria@escola.edu.br'), isNull);
    });

    test('cobra o preenchimento quando vem vazio ou so com espaco', () {
      expect(Validators.email(''), 'Informe seu e-mail');
      expect(Validators.email('   '), 'Informe seu e-mail');
      expect(Validators.email(null), 'Informe seu e-mail');
    });

    test('recusa formato invalido', () {
      expect(Validators.email('maria'), 'E-mail invalido');
      expect(Validators.email('maria@'), 'E-mail invalido');
      expect(Validators.email('maria@escola'), 'E-mail invalido');
      expect(Validators.email('maria escola@x.com'), 'E-mail invalido');
    });

    test('recusa e-mail acima de 120 caracteres', () {
      final longo = '${'a' * 115}@x.com';
      expect(Validators.email(longo), 'E-mail muito longo');
    });
  });

  group('Validators.senha', () {
    test('aceita senha com oito caracteres ou mais', () {
      expect(Validators.senha('segredo1'), isNull);
      expect(Validators.senha('Professor@123'), isNull);
    });

    test('cobra o preenchimento quando vem vazia', () {
      expect(Validators.senha(''), 'Informe sua senha');
      expect(Validators.senha(null), 'Informe sua senha');
    });

    test('recusa senha com menos de oito caracteres', () {
      expect(Validators.senha('curta1'), 'A senha precisa de ao menos 8 caracteres');
    });

    test('nao apara espaco da senha', () {
      // Espaco e caractere valido de senha; aparar mudaria o segredo.
      expect(Validators.senha('  a  b  '), isNull);
    });
  });

  group('Validators.nome', () {
    test('aceita nome dentro do limite', () {
      expect(Validators.nome('Maria Silva'), isNull);
    });

    test('cobra o preenchimento quando vem so com espaco', () {
      expect(Validators.nome('   '), 'Informe seu nome');
    });

    test('recusa nome curto demais', () {
      expect(Validators.nome('Jo'), 'O nome precisa de 3 a 80 caracteres');
    });

    test('recusa nome longo demais', () {
      expect(Validators.nome('a' * 81), 'O nome precisa de 3 a 80 caracteres');
    });

    test('conta o nome ja sem os espacos das pontas', () {
      expect(Validators.nome('  Ana  '), isNull);
    });
  });

  group('Validators.usuario', () {
    test('aceita letras, numeros, ponto e sublinhado', () {
      expect(Validators.usuario('maria.silva_2'), isNull);
    });

    test('cobra o preenchimento', () {
      expect(Validators.usuario(''), 'Informe seu nome de usuario');
    });

    test('recusa fora do tamanho', () {
      expect(Validators.usuario('ab'), 'O nome de usuario precisa de 3 a 30 caracteres');
      expect(Validators.usuario('a' * 31), 'O nome de usuario precisa de 3 a 30 caracteres');
    });

    test('recusa caractere especial e espaco', () {
      const msg = 'Use apenas letras, numeros, ponto e sublinhado';
      expect(Validators.usuario('maria silva'), msg);
      expect(Validators.usuario('maria@silva'), msg);
      expect(Validators.usuario('<script>'), msg);
    });
  });

  group('Validators.escola e Validators.turma', () {
    test('aceitam texto dentro do limite', () {
      expect(Validators.escola('E.E. Monteiro Lobato'), isNull);
      expect(Validators.turma('9 ano B'), isNull);
    });

    test('cobram o preenchimento', () {
      expect(Validators.escola('  '), 'Informe sua escola');
      expect(Validators.turma(''), 'Informe sua turma');
    });

    test('recusam fora do tamanho', () {
      expect(Validators.escola('a'), 'A escola precisa de 2 a 80 caracteres');
      expect(Validators.turma('a' * 81), 'A turma precisa de 2 a 80 caracteres');
    });
  });
}
