// Banco de questões do BNCC Play, organizado pelos 3 eixos da BNCC Computação:
// pensamento-computacional, mundo-digital e cultura-digital.
//
// ATENÇÃO: a posição das questões é contrato com o backend (backend/src/lib/sessionCode.js).
// Índices 0-9: fácil · 10-19: médio · 20-29: difícil.
// As dificuldades usam pools cumulativos: Fácil sorteia dos índices 0-9,
// Médio dos índices 0-19 e Difícil dos índices 0-29.
export const allQuestions = [
    // ---- FÁCIL (índices 0-9) ----
    { text: "Escrever o passo a passo de uma receita de bolo, em ordem, para outra pessoa seguir.", axis: "pensamento-computacional", difficulty: "facil", reason: "Descrever um passo a passo ordenado para resolver uma tarefa é criar um algoritmo, ideia central do Pensamento Computacional." },
    { text: "Montar a sequência de instruções para um robô sair de um labirinto.", axis: "pensamento-computacional", difficulty: "facil", reason: "Planejar instruções em sequência para atingir um objetivo é construir um algoritmo, habilidade do Pensamento Computacional." },
    { text: "Organizar os brinquedos em caixas separadas por tipo: carrinhos, bonecos e jogos.", axis: "pensamento-computacional", difficulty: "facil", reason: "Classificar e organizar objetos por características é reconhecer padrões e categorias, prática do Pensamento Computacional." },
    { text: "As fotos tiradas com o celular ficam guardadas na memória do aparelho.", axis: "mundo-digital", difficulty: "facil", reason: "Entender onde e como as informações são armazenadas nos dispositivos faz parte do eixo Mundo Digital." },
    { text: "O mouse, o teclado e a tela fazem parte do hardware do computador.", axis: "mundo-digital", difficulty: "facil", reason: "Conhecer os componentes físicos (hardware) dos dispositivos é conteúdo do eixo Mundo Digital." },
    { text: "Para assistir a um vídeo online, o celular precisa estar conectado à internet.", axis: "mundo-digital", difficulty: "facil", reason: "Compreender a conexão dos dispositivos em rede e o acesso à internet faz parte do eixo Mundo Digital." },
    { text: "Não compartilhar a senha dos seus aplicativos com colegas.", axis: "cultura-digital", difficulty: "facil", reason: "Proteger senhas e dados pessoais é prática de segurança digital, tema do eixo Cultura Digital." },
    { text: "Pedir permissão antes de postar a foto de um amigo na internet.", axis: "cultura-digital", difficulty: "facil", reason: "Respeitar a imagem e a privacidade das pessoas online é atitude de cidadania digital, do eixo Cultura Digital." },
    { text: "Avisar um adulto ao receber mensagem de um desconhecido na internet.", axis: "cultura-digital", difficulty: "facil", reason: "Adotar comportamentos seguros ao interagir na internet é tema de segurança do eixo Cultura Digital." },
    { text: "Guardar o tablet da escola com cuidado para não danificar o equipamento.", axis: "cultura-digital", difficulty: "facil", reason: "Usar os recursos tecnológicos com responsabilidade e cuidado é atitude do eixo Cultura Digital." },

    // ---- MÉDIO (índices 10-19) ----
    { text: "Dividir um trabalho escolar grande em partes menores e resolver uma de cada vez.", axis: "pensamento-computacional", difficulty: "medio", reason: "Quebrar um problema grande em partes menores é a decomposição, uma das bases do Pensamento Computacional." },
    { text: "Perceber que a tabuada do 5 sempre termina em 0 ou 5 e usar isso para calcular mais rápido.", axis: "pensamento-computacional", difficulty: "medio", reason: "Identificar regularidades e usá-las para resolver problemas é o reconhecimento de padrões, do Pensamento Computacional." },
    { text: "Repetir a mesma instrução 10 vezes usando um bloco de repetição no Scratch.", axis: "pensamento-computacional", difficulty: "medio", reason: "Usar estruturas de repetição (laços) para evitar instruções duplicadas é conceito de programação do Pensamento Computacional." },
    { text: "Testar um jogo feito no Scratch, encontrar um erro e corrigi-lo.", axis: "pensamento-computacional", difficulty: "medio", reason: "Encontrar e corrigir erros em um programa (depuração) é prática fundamental do Pensamento Computacional." },
    { text: "Diferenciar o aplicativo de câmera (software) da lente da câmera (hardware).", axis: "mundo-digital", difficulty: "medio", reason: "Distinguir software (programas) de hardware (parte física) é conhecimento do eixo Mundo Digital." },
    { text: "Salvar um trabalho na nuvem para acessá-lo depois em outro computador.", axis: "mundo-digital", difficulty: "medio", reason: "Compreender o armazenamento em nuvem e o acesso remoto às informações é tema do eixo Mundo Digital." },
    { text: "Entender que o Wi-Fi transmite dados sem fio entre o roteador e os dispositivos.", axis: "mundo-digital", difficulty: "medio", reason: "Conhecer como as redes conectam dispositivos e transmitem dados faz parte do eixo Mundo Digital." },
    { text: "Verificar se uma notícia é verdadeira antes de compartilhá-la no grupo da família.", axis: "cultura-digital", difficulty: "medio", reason: "Checar fontes e combater a desinformação é uso crítico da tecnologia, tema central do eixo Cultura Digital." },
    { text: "Reconhecer que ofender um colega em um grupo de mensagens é cyberbullying.", axis: "cultura-digital", difficulty: "medio", reason: "Identificar e combater o cyberbullying é parte da convivência ética online, do eixo Cultura Digital." },
    { text: "Equilibrar o tempo entre jogar no celular, estudar e brincar com os amigos.", axis: "cultura-digital", difficulty: "medio", reason: "Refletir sobre o uso equilibrado e saudável da tecnologia no dia a dia é tema do eixo Cultura Digital." },

    // ---- DIFÍCIL (índices 20-29) ----
    { text: "Explicar o caminho da escola citando só as ruas principais, sem detalhar cada esquina.", axis: "pensamento-computacional", difficulty: "dificil", reason: "Focar nas informações essenciais e ignorar detalhes irrelevantes é a abstração, pilar do Pensamento Computacional." },
    { text: "Criar um programa que decide: SE estiver chovendo, ENTÃO leve guarda-chuva, SENÃO leve boné.", axis: "pensamento-computacional", difficulty: "dificil", reason: "Usar estruturas condicionais (se/então/senão) para tomar decisões é conceito de programação do Pensamento Computacional." },
    { text: "Comparar duas formas de ordenar uma lista de nomes e escolher a que faz menos comparações.", axis: "pensamento-computacional", difficulty: "dificil", reason: "Analisar e comparar a eficiência de diferentes algoritmos é habilidade avançada do Pensamento Computacional." },
    { text: "Usar uma variável no jogo para guardar e atualizar a pontuação do jogador.", axis: "pensamento-computacional", difficulty: "dificil", reason: "Utilizar variáveis para armazenar e manipular valores em um programa é conceito do Pensamento Computacional." },
    { text: "Entender que toda informação no computador — textos, fotos e músicas — vira sequências de 0s e 1s.", axis: "mundo-digital", difficulty: "dificil", reason: "Compreender a representação binária da informação é conhecimento fundamental do eixo Mundo Digital." },
    { text: "Explicar que um site é hospedado em um servidor e acessado pelo navegador por meio de um endereço (URL).", axis: "mundo-digital", difficulty: "dificil", reason: "Entender o funcionamento da web, servidores e endereços faz parte do eixo Mundo Digital." },
    { text: "Perceber que um assistente de voz usa inteligência artificial para reconhecer o que você fala.", axis: "mundo-digital", difficulty: "dificil", reason: "Conhecer tecnologias como a inteligência artificial e seu funcionamento básico é tema do eixo Mundo Digital." },
    { text: "Notar que as redes sociais recomendam vídeos com base no que você já assistiu.", axis: "cultura-digital", difficulty: "dificil", reason: "Compreender criticamente como algoritmos de recomendação influenciam o que consumimos é tema do eixo Cultura Digital." },
    { text: "Ler os termos de uso de um aplicativo para saber quais dados pessoais ele coleta.", axis: "cultura-digital", difficulty: "dificil", reason: "Refletir sobre privacidade e coleta de dados pelas plataformas é uso crítico da tecnologia, do eixo Cultura Digital." },
    { text: "Citar o autor ao usar uma imagem da internet no seu trabalho escolar.", axis: "cultura-digital", difficulty: "dificil", reason: "Respeitar direitos autorais e dar crédito às produções de outras pessoas é ética digital, do eixo Cultura Digital." },
];
