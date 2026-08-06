import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/models/questao.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';

/// Seed de questoes iniciais para o banco de dados.
///
/// Executar `await popularBancoSeed(banco)` apos abrir o banco.
///
/// Tambem atualiza questoes seed existentes para refletir o texto atual
/// (util quando as questoes do seed sao corrigidas/atualizadas, e o
/// usuario ja tem o app instalado com a versao antiga do seed).
Future<void> popularBancoSeed(AppDatabase banco) async {
  final repository = QuestaoRepository(banco: banco);
  final totalQuestoes = await banco.db.rawQuery(
    'SELECT COUNT(*) AS total FROM questoes',
  );
  if ((totalQuestoes.single['total'] as int) > 0) {
    await _atualizarTextosSeed(banco);
    return;
  }

  final professorId = await _garantirProfessorSeed(banco);
  for (var i = 0; i < questoesSeed.length; i++) {
    await repository.cadastrar(
      enunciado: questoesSeed[i].enunciado,
      opcaoA: questoesSeed[i].opcaoA,
      opcaoB: questoesSeed[i].opcaoB,
      opcaoC: questoesSeed[i].opcaoC,
      opcaoD: questoesSeed[i].opcaoD,
      respostaCorreta: questoesSeed[i].respostaCorreta,
      eixo: questoesSeed[i].eixo,
      dificuldade: questoesSeed[i].dificuldade,
      categoria: _categoriaSeed(i),
      professorId: professorId,
    );
  }
}

Future<int> _garantirProfessorSeed(AppDatabase banco) async {
  final professores = await banco.db.query(
    'users',
    columns: ['id'],
    where: 'papel = ?',
    whereArgs: ['professor'],
    orderBy: 'id ASC',
    limit: 1,
  );
  if (professores.isNotEmpty) return professores.single['id'] as int;

  final agora = DateTime.now().toUtc().toIso8601String();
  return banco.db.insert('users', {
    'nome': 'Conteúdo BNCC Play',
    'email': 'conteudo@bncc.play',
    'usuario': 'conteudo_bncc',
    'senha_hash': 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    'salt': 'AAAAAAAAAAAAAAAAAAAAAA==',
    'papel': 'professor',
    'escola': 'BNCC Play',
    'criado_em': agora,
    'atualizado_em': agora,
  });
}

/// Corrige o seed gravado por versões anteriores do app.
Future<void> corrigirAcentuacaoSeed(AppDatabase banco) async {
  await _atualizarTextosSeed(banco);
}

/// Atualiza o texto das 30 primeiras questoes do professor seed para
/// refletir o conteudo atual do array.
///
Future<void> _atualizarTextosSeed(AppDatabase banco) async {
  final existentes = await banco.db.query(
    'questoes',
    orderBy: 'criado_em ASC',
    limit: questoesSeed.length,
  );

  if (existentes.length < questoesSeed.length) return;

  final marcadoresDoSeed = <int, Set<String>>{
    0: {'O que é um algoritmo?', 'O que e um algoritmo?'},
    10: {'O que é plágio na era digital?', 'O que é plagio na era digital?'},
    20: {'O que é inclusão digital?', 'O que é inclusao digital?'},
  };
  final correspondeAoSeed = marcadoresDoSeed.entries.every(
    (marcador) =>
        marcador.value.contains(existentes[marcador.key]['enunciado']),
  );
  if (!correspondeAoSeed) return;

  for (var i = 0; i < questoesSeed.length; i++) {
    final original = Questao.deLinha(existentes[i]);
    final atualizado = original.copiarCom(
      enunciado: questoesSeed[i].enunciado,
      opcaoA: questoesSeed[i].opcaoA,
      opcaoB: questoesSeed[i].opcaoB,
      opcaoC: questoesSeed[i].opcaoC,
      opcaoD: questoesSeed[i].opcaoD,
      respostaCorreta: questoesSeed[i].respostaCorreta,
      eixo: questoesSeed[i].eixo,
      dificuldade: questoesSeed[i].dificuldade,
      categoria: _categoriaSeed(i),
    );
    await banco.db.update(
      'questoes',
      atualizado.paraLinha(),
      where: 'id = ?',
      whereArgs: [original.id],
    );
  }
}

String _categoriaSeed(int indice) {
  if (indice < 10) {
    if ({4, 5}.contains(indice)) return 'Estruturas e algoritmos';
    if ({7, 9}.contains(indice)) return 'Dados e programação';
    return 'Fundamentos da computação';
  }
  if (indice < 20) {
    if ({10, 11, 18}.contains(indice)) return 'Ética e autoria';
    if ({12, 13, 17}.contains(indice)) return 'Segurança e cidadania';
    return 'Informação digital';
  }
  if ({23, 24}.contains(indice)) return 'Inteligência artificial';
  if ({22, 27, 28, 29}.contains(indice)) return 'Sustentabilidade';
  return 'Inclusão e sociedade';
}

const List<_QuestaoSeed> questoesSeed = [
  // ========== TECNOLOGIA E COMPUTACAO ==========
  _QuestaoSeed(
    enunciado: 'O que é um algoritmo?',
    opcaoA: 'Um tipo de linguagem de programação',
    opcaoB: 'Uma sequência lógica de passos para resolver um problema',
    opcaoC: 'Um dispositivo eletrônico',
    opcaoD: 'Um tipo de banco de dados',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'Qual é a principal função de um sistema operacional?',
    opcaoA: 'Editar textos',
    opcaoB: 'Gerenciar os recursos de hardware e software do computador',
    opcaoC: 'Navegar na internet',
    opcaoD: 'Criar planilhas',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que é a memória RAM de um computador?',
    opcaoA: 'Um dispositivo de armazenamento permanente',
    opcaoB: 'Uma memória volátil que armazena dados temporariamente',
    opcaoC: 'Um tipo de processador',
    opcaoD: 'Um programa antivírus',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'O que significa "debugar" um programa?',
    opcaoA: 'Apagar todo o código',
    opcaoB: 'Instalar o programa',
    opcaoC: 'Identificar e corrigir erros no código',
    opcaoD: 'Compilar o programa',
    respostaCorreta: 'C',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado:
        'Qual estrutura de dados funciona como uma fila de espera (FIFO)?',
    opcaoA: 'Pilha (Stack)',
    opcaoB: 'Fila (Queue)',
    opcaoC: 'Árvore Binária',
    opcaoD: 'Grafo',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.dificil,
  ),
  _QuestaoSeed(
    enunciado: 'O que é a complexidade de tempo O(n) em um algoritmo?',
    opcaoA: 'O algoritmo executa em tempo constante',
    opcaoB: 'O tempo de execução cresce linearmente com a entrada',
    opcaoC: 'O algoritmo nunca termina',
    opcaoD: 'O algoritmo executa em tempo quadrático',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.dificil,
  ),
  _QuestaoSeed(
    enunciado: 'Qual é a unidade básica de informação em computação?',
    opcaoA: 'Byte',
    opcaoB: 'Bit',
    opcaoC: 'Pixel',
    opcaoD: 'Hertz',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que é um banco de dados relacional?',
    opcaoA: 'Um programa de edição de texto',
    opcaoB: 'Um sistema que organiza dados em tabelas com relações entre elas',
    opcaoC: 'Um tipo de linguagem de programação',
    opcaoD: 'Um dispositivo de entrada de dados',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'Qual protocolo é usado para transferir páginas web?',
    opcaoA: 'FTP',
    opcaoB: 'HTTP/HTTPS',
    opcaoC: 'SMTP',
    opcaoD: 'SSH',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que é programação orientada a objetos?',
    opcaoA: 'Um estilo de programação que usa apenas variáveis globais',
    opcaoB: 'Um paradigma que usa objetos e classes para organizar código',
    opcaoC: 'Um tipo de hardware',
    opcaoD: 'Um protocolo de rede',
    respostaCorreta: 'B',
    eixo: EixoBNCC.tecnologia,
    dificuldade: Dificuldade.medio,
  ),

  // ========== CULTURA DIGITAL ==========
  _QuestaoSeed(
    enunciado: 'O que é plágio na era digital?',
    opcaoA: 'Copiar o conteúdo de outro autor sem dar crédito',
    opcaoB: 'Compartilhar links em redes sociais',
    opcaoC: 'Criar um blog pessoal',
    opcaoD: 'Fazer download de arquivos legais',
    respostaCorreta: 'A',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que significa licença Creative Commons?',
    opcaoA: 'Um tipo de vírus informático',
    opcaoB: 'Uma licença que permite uso controlado de conteúdos criativos',
    opcaoC: 'Um programa antivírus',
    opcaoD: 'Um tipo de banco de dados',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'O que é cyberbullying?',
    opcaoA: 'Um tipo de jogo online',
    opcaoB: 'Bullying praticado por meio da internet ou celular',
    opcaoC: 'Um programa de segurança',
    opcaoD: 'Uma forma de estudar online',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'Qual é a importância da privacidade digital?',
    opcaoA: 'Não tem importância',
    opcaoB: 'Proteger informações pessoais de acessos não autorizados',
    opcaoC: 'Apenas empresas precisam se preocupar',
    opcaoD: 'Só relevante para redes sociais',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que são as "fake news"?',
    opcaoA: 'Notícias antigas',
    opcaoB: 'Notícias verdadeiras de jornal',
    opcaoC: 'Notícias falsas divulgadas como se fossem verdadeiras',
    opcaoD: 'Um tipo de rede social',
    respostaCorreta: 'C',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que significa o termo "pegada digital"?',
    opcaoA: 'A impressão digital no celular',
    opcaoB: 'Os rastros que deixamos ao usar a internet',
    opcaoC: 'Um tipo de senha',
    opcaoD: 'Um aplicativo de redes sociais',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'Qual é a diferença entre dados e informação?',
    opcaoA: 'São a mesma coisa',
    opcaoB: 'Dados são fatos brutos; informação é dado processado e organizado',
    opcaoC: 'Informação é um tipo de dado',
    opcaoD: 'Dados são mais importantes que informação',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'O que é o direito ao esquecimento digital?',
    opcaoA: 'Apagar todos os arquivos do computador',
    opcaoB:
        'O direito de ter informações removidas da internet em certas circunstâncias',
    opcaoC: 'Um tipo de backup',
    opcaoD: 'Um programa de segurança',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.dificil,
  ),
  _QuestaoSeed(
    enunciado: 'O que significa ser um cidadão digital responsável?',
    opcaoA: 'Usar a internet sem limites',
    opcaoB: 'Só usar redes sociais',
    opcaoC: 'Usar a internet de forma ética, respeitosa e segura',
    opcaoD: 'Evitar usar tecnologia',
    respostaCorreta: 'C',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que é pegada de carbono digital?',
    opcaoA: 'A impressão carbônica em documentos',
    opcaoB: 'O impacto ambiental do uso de tecnologia e internet',
    opcaoC: 'Um tipo de servidor',
    opcaoD: 'Um programa de economia de energia',
    respostaCorreta: 'B',
    eixo: EixoBNCC.culturaDigital,
    dificuldade: Dificuldade.dificil,
  ),

  // ========== IMPACTO SOCIAL E ETICA ==========
  _QuestaoSeed(
    enunciado: 'O que é inclusão digital?',
    opcaoA: 'Excluir pessoas do uso de tecnologia',
    opcaoB:
        'Garantir que todos tenham acesso e habilidades para usar tecnologia',
    opcaoC: 'Um tipo de curso de programação',
    opcaoD: 'Criar redes sociais',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado:
        'Qual é um exemplo de impacto positivo da tecnologia na sociedade?',
    opcaoA: 'A dependência tecnológica',
    opcaoB: 'O acesso a informações e educação online',
    opcaoC: 'O aumento do cyberbullying',
    opcaoD: 'A redução da privacidade',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que são os Objetivos de Desenvolvimento Sustentável (ODS)?',
    opcaoA: 'Metas globais da ONU para um futuro melhor até 2030',
    opcaoB: 'Regras de programação',
    opcaoC: 'Tipos de linguagens de programação',
    opcaoD: 'Protocolos de internet',
    respostaCorreta: 'A',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'O que é o viés algorítmico?',
    opcaoA: 'Algoritmos que respeitam a privacidade dos usuários',
    opcaoB: 'O uso de algoritmos que podem perpetuar vieses e discriminação',
    opcaoC: 'Um tipo de criptografia',
    opcaoD: 'Um programa de segurança',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.dificil,
  ),
  _QuestaoSeed(
    enunciado:
        'Por que é importante discutir ética em inteligência artificial?',
    opcaoA: 'Não tem importância',
    opcaoB: 'IA pode perpetuar vieses e afetar vidas humanas',
    opcaoC: 'Só empresas precisam se importar',
    opcaoD: 'Para tornar IA mais rápida',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'O que é a desigualdade digital?',
    opcaoA: 'Todos terem acesso igual à tecnologia',
    opcaoB: 'A diferença no acesso e uso de tecnologia entre grupos sociais',
    opcaoC: 'Um tipo de programação',
    opcaoD: 'Um tipo de rede social',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado:
        'Qual é o papel da tecnologia na democratização do conhecimento?',
    opcaoA: 'Restringir o acesso à informação',
    opcaoB: 'Tornar informação mais acessível a todas as pessoas',
    opcaoC: 'Apenas beneficiar grandes empresas',
    opcaoD: 'Eliminar bibliotecas',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado: 'O que significa o termo "sustentabilidade digital"?',
    opcaoA: 'Usar apenas tecnologia de baixo custo',
    opcaoB: 'Considerar o impacto ambiental e social da tecnologia',
    opcaoC: 'Evitar usar qualquer tecnologia',
    opcaoD: 'Um tipo de software',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.medio,
  ),
  _QuestaoSeed(
    enunciado: 'Como a tecnologia pode contribuir para a saúde e bem-estar?',
    opcaoA: 'Aumentando a dependência de telas',
    opcaoB: 'Através de telemedicina, aplicativos de saúde e informação',
    opcaoC: 'Criando mais estresse',
    opcaoD: 'Reduzindo o sono',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.facil,
  ),
  _QuestaoSeed(
    enunciado:
        'Quais são os riscos da exposição excessiva a telas para crianças?',
    opcaoA: 'Não há riscos',
    opcaoB: 'Impactos no desenvolvimento, saúde ocular e sono',
    opcaoC: 'Só benefícios',
    opcaoD: 'Melhora a memória',
    respostaCorreta: 'B',
    eixo: EixoBNCC.impacto,
    dificuldade: Dificuldade.medio,
  ),
];

class _QuestaoSeed {
  const _QuestaoSeed({
    required this.enunciado,
    required this.opcaoA,
    required this.opcaoB,
    required this.opcaoC,
    required this.opcaoD,
    required this.respostaCorreta,
    required this.eixo,
    required this.dificuldade,
  });

  final String enunciado;
  final String opcaoA;
  final String opcaoB;
  final String opcaoC;
  final String opcaoD;
  final String respostaCorreta;
  final EixoBNCC eixo;
  final Dificuldade dificuldade;
}
