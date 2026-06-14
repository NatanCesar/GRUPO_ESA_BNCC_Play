# Cenários BDD
Artefato organizado a partir da Atividade 4 de Concepção do Sistema.

Os cenários abaixo usam a estrutura **Dado / Quando / Então** e estão relacionados às estórias US01 a US20.

## CB 01 - Efetivação de Login no Sistema

### Cenário - Login realizado com sucesso

```gherkin
Dado que o usuário possui uma conta cadastrada
Quando informar e-mail e senha válidos
Então o sistema deve autenticar o usuário e permitir acesso à plataforma
```

### Cenário - Controle de acesso

```gherkin
Dado que um usuário não autenticado tenta acessar uma área restrita
Quando acessar uma funcionalidade exclusiva para usuários logados
Então o sistema deve negar o acesso e solicitar autenticação
```

## CB 02 - Cadastro de Professor

### Cenário - Cadastro realizado com sucesso

```gherkin
Dado que o professor ainda não possui cadastro
Quando preencher os dados obrigatórios e confirmar o cadastro
Então o sistema deve criar sua conta
```

### Cenário - Minimização de dados

```gherkin
Dado que o professor está realizando seu cadastro
Quando preencher as informações solicitadas
Então o sistema deve coletar apenas os dados necessários para identificação e acesso
```

## CB 03 - Cadastro de Aluno

### Cenário - Cadastro realizado com sucesso

```gherkin
Dado que o estudante ainda não possui cadastro
Quando informar os dados obrigatórios
Então o sistema deve criar sua conta
```

### Cenário - Proteção de dados pessoais

```gherkin
Dado que o cadastro do aluno foi concluído
Quando os dados forem armazenados
Então o sistema deve proteger as informações contra acesso não autorizado
```

## CB 04 - Seleção de Eixo da BNCC

### Cenário - Seleção de eixo

```gherkin
Dado que o professor está autenticado
Quando selecionar um eixo da BNCC Computação
Então o sistema deve exibir conteúdos relacionados ao eixo escolhido
```

### Cenário - Restrição de acesso

```gherkin
Dado que um estudante acessa a plataforma
Quando tentar alterar o eixo pedagógico definido pelo professor
Então o sistema deve impedir a alteração
```

## CB 05 - Cadastro de Questões

### Cenário - Cadastro de nova questão

```gherkin
Dado que o professor possui permissão para gerenciar conteúdos
Quando cadastrar uma nova questão
Então o sistema deve armazená-la no banco de questões
```

### Cenário - Controle de acesso

```gherkin
Dado que um aluno está autenticado
Quando tentar cadastrar uma questão
Então o sistema deve negar a operação
```

## CB 06 - Definição de Nível de Dificuldade

### Cenário - Definição de dificuldade

```gherkin
Dado que uma questão foi criada
Quando o professor definir seu nível de dificuldade
Então o sistema deve associar o nível à questão
```

### Cenário - Permissões

```gherkin
Dado que um usuário sem permissão tenta alterar a dificuldade
Quando realizar a ação
Então o sistema deve impedir a modificação
```

## CB 07 - Listagem de Questões por Eixo

### Cenário - Exibição das questões

```gherkin
Dado que existem questões cadastradas em determinado eixo
Quando o professor selecionar o eixo
Então o sistema deve listar apenas as questões correspondentes
```

### Cenário - Privacidade

```gherkin
Dado que as questões possuem autor identificado
Quando forem exibidas aos alunos
Então o sistema não deve mostrar dados pessoais do autor
```

## CB 08 - Alteração de Questão

### Cenário - Edição de conteúdo

```gherkin
Dado que existe uma questão cadastrada
Quando o usuário autorizado editar a questão
Então o sistema deve salvar as alterações
```

### Cenário - Auditoria

```gherkin
Dado que uma questão foi alterada
Quando a alteração for concluída
Então o sistema deve registrar quem realizou a modificação
```

## CB 09 - Remoção de Questão

### Cenário - Exclusão autorizada

```gherkin
Dado que existe uma questão cadastrada
Quando o administrador solicitar sua remoção
Então o sistema deve excluir a questão
```

### Cenário - Segurança

```gherkin
Dado que um aluno tenta excluir uma questão
Quando realizar a solicitação
Então o sistema deve bloquear a ação
```

## CB 10 - Organização de Questões por Categorias

### Cenário - Organização correta

```gherkin
Dado que existem questões cadastradas
Quando forem associadas a categorias
Então o sistema deve agrupá-las corretamente
```

### Cenário - Ocultação de informações

```gherkin
Dado que um aluno acessa as categorias
Quando visualizar as questões
Então o sistema não deve exibir dados administrativos internos
```

## CB 11 - Filtragem de Conteúdos por Eixo

### Cenário - Filtragem aplicada

```gherkin
Dado que existem conteúdos de diferentes eixos
Quando o professor aplicar um filtro
Então o sistema deve exibir apenas os conteúdos correspondentes
```

### Cenário - Privacidade por padrão

```gherkin
Dado que o filtro foi aplicado
Quando os resultados forem exibidos
Então o sistema deve apresentar apenas as informações necessárias para navegação
```

## CB 12 - Listagem de Questões por Nível de Dificuldade

### Cenário - Filtragem por dificuldade

```gherkin
Dado que existem questões cadastradas
Quando o professor selecionar um nível de dificuldade
Então o sistema deve exibir apenas as questões daquele nível
```

### Cenário - Controle de acesso

```gherkin
Dado que existem configurações administrativas relacionadas às questões
Quando um estudante visualizar a listagem
Então o sistema não deve exibir informações administrativas
```

## CB 13 - Alteração de Cadastro do Professor

### Cenário - Atualização cadastral

```gherkin
Dado que o professor está autenticado
Quando alterar seus dados pessoais
Então o sistema deve salvar as informações atualizadas
```

### Cenário - Proteção de conta

```gherkin
Dado que outro usuário tenta alterar os dados do professor
Quando não possuir autenticação válida
Então o sistema deve impedir a alteração
```

## CB 14 - Alteração de Cadastro do Aluno

### Cenário - Atualização cadastral

```gherkin
Dado que o aluno está autenticado
Quando alterar seus dados
Então o sistema deve atualizar seu cadastro
```

### Cenário - Restrição de acesso

```gherkin
Dado que outro usuário tenta acessar os dados do aluno
Quando não possuir autorização
Então o sistema deve negar o acesso
```

## CB 15 - Sistema Gamificado de Perguntas e Respostas

### Cenário - Resposta correta

```gherkin
Dado que o estudante iniciou uma atividade
Quando responder corretamente uma questão
Então o sistema deve registrar o acerto
```

### Cenário - Privacidade do desempenho

```gherkin
Dado que os resultados foram registrados
Quando outro estudante acessar a plataforma
Então ele não deve visualizar o histórico individual de terceiros
```

## CB 16 - Pontuação e Recompensas

### Cenário - Geração de pontuação

```gherkin
Dado que o aluno concluiu uma atividade
Quando obtiver respostas corretas
Então o sistema deve atribuir a pontuação correspondente
```

### Cenário - Segurança dos resultados

```gherkin
Dado que a pontuação foi registrada
Quando for armazenada
Então o sistema deve impedir alterações não autorizadas
```

## CB 17 - Ranking de Jogadores

### Cenário - Exibição do ranking

```gherkin
Dado que existem pontuações registradas
Quando o ranking for consultado
Então o sistema deve ordenar os participantes por pontuação
```

### Cenário - Anonimização

```gherkin
Dado que o ranking está disponível
Quando for exibido aos participantes
Então o sistema deve utilizar apelidos ou identificadores públicos em vez de dados pessoais completos
```

## CB 18 - Multiplayer em Sala

### Cenário - Criação de partida

```gherkin
Dado que o professor iniciou uma atividade multiplayer
Quando os alunos ingressarem na sessão
Então o sistema deve permitir a participação simultânea
```

### Cenário - Compartilhamento seguro

```gherkin
Dado que a partida está em andamento
Quando os resultados forem exibidos
Então o sistema deve compartilhar apenas informações necessárias para a dinâmica da atividade
```

## CB 19 - Dashboard Pedagógico

### Cenário - Visualização de indicadores

```gherkin
Dado que existem atividades realizadas
Quando o professor acessar o dashboard
Então o sistema deve apresentar métricas de desempenho da turma
```

### Cenário - Controle de acesso

```gherkin
Dado que um estudante tenta acessar o dashboard pedagógico
Quando solicitar a visualização
Então o sistema deve negar o acesso por falta de permissão
```

## CB 20 - Relatórios de Desempenho

### Cenário - Geração de relatório

```gherkin
Dado que existem dados de desempenho registrados
Quando o professor solicitar um relatório
Então o sistema deve gerar o documento com as informações da turma
```

### Cenário - Proteção contra exposição indevida

```gherkin
Dado que o relatório contém dados dos estudantes
Quando for disponibilizado para consulta
Então o sistema deve permitir acesso apenas a usuários autorizados, como professores e coordenadores pedagógicos
```

