import 'package:bncc_play_mobile/data/db/app_database.dart';
import 'package:bncc_play_mobile/data/models/eixo_bncc.dart';
import 'package:bncc_play_mobile/data/models/dificuldade.dart';
import 'package:bncc_play_mobile/data/repositories/questao_repository.dart';

/// Seed de questoes iniciais para o banco de dados.
///
/// Executar `await popularBancoSeed(banco)` apos abrir o banco pela primeira vez.
Future<void> popularBancoSeed(AppDatabase banco) async {
  final repository = QuestaoRepository(banco: banco);

  // Professor padrao para as questoes seed (criado primeiro).
  // Assumimos que ja existe um professor no banco ou criamos um placeholder.
  const professorId = 1;

  final questoesSeed = <_QuestaoSeed>[
    // ========== TECNOLOGIA E COMPUTACAO ==========
    _QuestaoSeed(
      enunciado: 'O que é um algoritmo?',
      opcaoA: 'Um tipo de linguagem de programacao',
      opcaoB: 'Uma sequencia logica de passos para resolver um problema',
      opcaoC: 'Um dispositivo eletronico',
      opcaoD: 'Um tipo de banco de dados',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'Qual e a principal funcao de um sistema operacional?',
      opcaoA: 'Editar textos',
      opcaoB: 'Gerenciar os recursos de hardware e software do computador',
      opcaoC: 'Navegar na internet',
      opcaoD: 'Criar planilhas',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que é a memoria RAM de um computador?',
      opcaoA: 'Um dispositivo de armazenamento permanente',
      opcaoB: 'Uma memoria volatil que armazena dados temporariamente',
      opcaoC: 'Um tipo de processador',
      opcaoD: 'Um programa antivrus',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'O que significa "debugar" um programa?',
      opcaoA: 'Apagar todo o codigo',
      opcaoB: 'Instalar o programa',
      opcaoC: 'Identificar e corrigir erros no codigo',
      opcaoD: 'Compilar o programa',
      respostaCorreta: 'C',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'Qual estrutura de dados funciona como uma fila de espera (FIFO)?',
      opcaoA: 'Pilha (Stack)',
      opcaoB: 'Fila (Queue)',
      opcaoC: 'Arvore Binaria',
      opcaoD: 'Grafo',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.dificil,
    ),
    _QuestaoSeed(
      enunciado: 'O que é a complexidade de tempo O(n) em um algoritmo?',
      opcaoA: 'O algoritmo executa em tempo constante',
      opcaoB: 'O tempo de execucao cresce linearmente com a entrada',
      opcaoC: 'O algoritmo nunca termina',
      opcaoD: 'O algoritmo executa em tempo quadratico',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.dificil,
    ),
    _QuestaoSeed(
      enunciado: 'Qual e a unidade basica de informacao em computacao?',
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
      opcaoA: 'Um programa de edicao de texto',
      opcaoB: 'Um sistema que organiza dados em tabelas com relacoes entre elas',
      opcaoC: 'Um tipo de linguagem de programacao',
      opcaoD: 'Um dispositivo de entrada de dados',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'Qual protocolo e usado para transferir paginas web?',
      opcaoA: 'FTP',
      opcaoB: 'HTTP/HTTPS',
      opcaoC: 'SMTP',
      opcaoD: 'SSH',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que é programacao orientada a objetos?',
      opcaoA: 'Um estilo de programacao que usa apenas variaveis globais',
      opcaoB: 'Um paradigma que usa objetos e classes para organizar codigo',
      opcaoC: 'Um tipo de hardware',
      opcaoD: 'Um protocolo de rede',
      respostaCorreta: 'B',
      eixo: EixoBNCC.tecnologia,
      dificuldade: Dificuldade.medio,
    ),

    // ========== CULTURA DIGITAL ==========
    _QuestaoSeed(
      enunciado: 'O que é plagio na era digital?',
      opcaoA: 'Copiar o conteudo de outro autor sem dar credito',
      opcaoB: 'Compartilhar links em redes sociais',
      opcaoC: 'Criar um blog pessoal',
      opcaoD: 'Fazer download de arquivos legais',
      respostaCorreta: 'A',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que significa licenca Creative Commons?',
      opcaoA: 'Um tipo de virus informatico',
      opcaoB: 'Uma licenca que permite uso controlado de conteudos criativos',
      opcaoC: 'Um programa antivrus',
      opcaoD: 'Um tipo de banco de dados',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'O que é cyberbullying?',
      opcaoA: 'Um tipo de jogo online',
      opcaoB: 'Bullying praticado через internet ou celular',
      opcaoC: 'Um programa de seguranca',
      opcaoD: 'Uma forma de belajar online',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'Qual e a importancia da privacidade digital?',
      opcaoA: 'Nao tem importancia',
      opcaoB: 'Proteger informacoes pessoais de acessos nao autorizados',
      opcaoC: 'Apenas empresas precisam se preocupar',
      opcaoD: 'So relevante para redes sociais',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que sao as "fake news"?',
      opcaoA: 'Noticias antigas',
      opcaoB: 'Noticias verdadeiras de jornal',
      opcaoC: 'Noticias falsas divulgadas como se fossem verdadeiras',
      opcaoD: 'Um tipo de rede social',
      respostaCorreta: 'C',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que significa o termo "pegada digital"?',
      opcaoA: 'A impressao digital no celular',
      opcaoB: 'Os rastros que deixamos ao usar a internet',
      opcaoC: 'Um tipo de senha',
      opcaoD: 'Um aplicativo de redes sociais',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'Qual e a diferenca entre dados e informacao?',
      opcaoA: 'Sao a mesma coisa',
      opcaoB: 'Dados sao fatos brutos; informacao e dado processado e organizado',
      opcaoC: 'Informacao e um tipo de dado',
      opcaoD: 'Dados sao mais importantes que informacao',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'O que é o direito ao esquecimento digital?',
      opcaoA: 'Apagar todos os arquivos do computador',
      opcaoB: 'O direito de ter informacoes removidas da internet em certas circunstacias',
      opcaoC: 'Um tipo de backup',
      opcaoD: 'Um programa de seguranca',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.dificil,
    ),
    _QuestaoSeed(
      enunciado: 'O que significa ser um cidadao digital responsavel?',
      opcaoA: 'Usar a internet sem limites',
      opcaoC: 'Usar a internet de forma etica, respeitosa e segura',
      opcaoB: 'So usar redes sociais',
      opcaoD: 'Evitar usar tecnologia',
      respostaCorreta: 'C',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que é huella de carbono digital?',
      opcaoA: 'A impressao carbonica em documentos',
      opcaoB: 'O impacto ambiental do uso de tecnologia e internet',
      opcaoC: 'Um tipo de servidor',
      opcaoD: 'Um programa de economia de energia',
      respostaCorreta: 'B',
      eixo: EixoBNCC.culturaDigital,
      dificuldade: Dificuldade.dificil,
    ),

    // ========== IMPACTO SOCIAL E ETICA ==========
    _QuestaoSeed(
      enunciado: 'O que é inclusao digital?',
      opcaoA: 'Excluir pessoas do uso de tecnologia',
      opcaoB: 'Garantir que todos tenham acesso e habilidades para usar tecnologia',
      opcaoC: 'Um tipo de curso de programacao',
      opcaoD: 'Criar redes sociais',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'Qual e um exemplo de impacto positivo da tecnologia na sociedade?',
      opcaoA: 'A dependencia tecnologica',
      opcaoB: 'O acesso a informacoes e educacao online',
      opcaoC: 'O aumento do cyberbullying',
      opcaoD: 'A reducao da privacidade',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que sao os Objetivos de Desenvolvimento Sustentavel (ODS)?',
      opcaoA: 'Metas globais da ONU para um futuro melhor ate 2030',
      opcaoB: 'Regras de programacao',
      opcaoC: 'Tipos de linguagens de programacao',
      opcaoD: 'Protocolos de internet',
      respostaCorreta: 'A',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'O que é a vida privacao algoritmica?',
      opcaoA: 'Algoritmos que respeitam a privacidade dos usuarios',
      opcaoB: 'O uso de algoritmos que podem perpetuar vieses e discriminacao',
      opcaoC: 'Um tipo de criptografia',
      opcaoD: 'Um programa de seguranca',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.dificil,
    ),
    _QuestaoSeed(
      enunciado: 'Por que e importante discutir etica em inteligencia artificial?',
      opcaoA: 'Nao tem importancia',
      opcaoB: 'IA pode perpetuar vieses e afetar vidas humanas',
      opcaoC: 'So empresas precisam se importar',
      opcaoD: 'Para tornar IA mais rapida',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.medio,
    ),
    _QuestaoSeed(
      enunciado: 'O que é a desigualdade digital?',
      opcaoA: 'Todos terem acesso igual a tecnologia',
      opcaoB: 'A diferenca no acesso e uso de tecnologia entre grupos sociais',
      opcaoC: 'Um tipo de programacao',
      opcaoD: 'Um tipo de rede social',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'Qual e o papel da tecnologia na democratizacao do conhecimento?',
      opcaoA: 'Restringir o acesso a informacao',
      opcaoB: 'Tornar informacao mais acessivel a todas as pessoas',
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
      enunciado: 'Como a tecnologia pode contribuir para a saude e bem-estar?',
      opcaoA: 'Aumentando a dependencia de telas',
      opcaoB: 'Atraves de telemedicina, aplicativos de saude e informacao',
      opcaoC: 'Criando mais estresse',
      opcaoD: 'Reduzindo o sono',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.facil,
    ),
    _QuestaoSeed(
      enunciado: 'O que sao os riscos da exposicao excessiva a telas para criancas?',
      opcaoA: 'Nao ha riscos',
      opcaoB: 'Impactos no desenvolvimento, saude ocular e sono',
      opcaoC: 'So beneficios',
      opcaoD: 'Melhora a memoria',
      respostaCorreta: 'B',
      eixo: EixoBNCC.impacto,
      dificuldade: Dificuldade.medio,
    ),
  ];

  // Insere cada questao.
  for (final q in questoesSeed) {
    try {
      await repository.cadastrar(
        enunciado: q.enunciado,
        opcaoA: q.opcaoA,
        opcaoB: q.opcaoB,
        opcaoC: q.opcaoC,
        opcaoD: q.opcaoD,
        respostaCorreta: q.respostaCorreta,
        eixo: q.eixo,
        dificuldade: q.dificuldade,
        professorId: professorId,
      );
    } catch (_) {
      // Ignora erros de duplicacao ou validacao.
    }
  }
}

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
