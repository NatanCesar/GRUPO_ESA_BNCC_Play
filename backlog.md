# Backlog de Produto — BNCC Play

Este documento apresenta o backlog de produto do **BNCC Play**, organizado de acordo com as entregas previstas para o desenvolvimento do sistema.

## 1ª Entrega

| ID | Funcionalidade                                 | Descrição                                                                                             | Usuário   | Prioridade | Dados pessoais              |
| -: | ---------------------------------------------- | ----------------------------------------------------------------------------------------------------- | --------- | ---------- | --------------------------- |
| 01 | Login do professor                             | Permite que o professor se autentique na plataforma utilizando login e senha.                         | Professor | Alta       | Login e senha               |
| 02 | Login do aluno                                 | Permite que o aluno se autentique na plataforma utilizando login e senha.                             | Aluno     | Alta       | Login e senha               |
| 03 | Cadastro de professor                          | Permite o registro de um novo professor na plataforma.                                                | Professor | Alta       | Nome, e-mail, login e senha |
| 04 | Cadastro de aluno                              | Permite o registro de um novo aluno na plataforma.                                                    | Aluno     | Alta       | Nome, e-mail, login e senha |
| 05 | Seleção de eixo da BNCC Computação             | Permite que o professor selecione o eixo temático da BNCC Computação antes do início das atividades.  | Professor | Alta       | Não aplicável               |
| 06 | Cadastro de questões                           | Permite que o professor cadastre perguntas associadas a um eixo temático e a um nível de dificuldade. | Professor | Alta       | Não aplicável               |
| 07 | Definição do nível de dificuldade das questões | Permite que cada questão seja categorizada como fácil, média ou difícil durante seu cadastro.         | Professor | Alta       | Não aplicável               |

---

## 2ª Entrega

| ID | Funcionalidade                     | Descrição                                                                                     | Usuário   | Prioridade | Dados pessoais |
| -: | ---------------------------------- | --------------------------------------------------------------------------------------------- | --------- | ---------- | -------------- |
| 08 | Listagem de questões por eixo      | Exibe as questões cadastradas, permitindo que sejam filtradas pelo eixo temático selecionado. | Professor | Média      | Não aplicável  |
| 09 | Alteração de questão               | Permite que o professor edite o conteúdo ou os metadados de uma questão já cadastrada.        | Professor | Média      | Não aplicável  |
| 10 | Remoção de questão                 | Permite que o professor exclua uma questão cadastrada no sistema.                             | Professor | Média      | Não aplicável  |
| 11 | Alteração do cadastro do professor | Permite que o professor edite as informações de seu perfil.                                   | Professor | Média      | Nome e e-mail  |
| 12 | Alteração do cadastro do aluno     | Permite que o aluno edite as informações de seu perfil.                                       | Aluno     | Média      | Nome e e-mail  |

---

## 3ª Entrega

| ID | Funcionalidade                              | Descrição                                                                             | Usuário           | Prioridade | Dados pessoais |
| -: | ------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------- | ---------- | -------------- |
| 13 | Sistema gamificado de perguntas e respostas | Executa sessões gamificadas com perguntas e respostas em tempo real.                  | Professor e aluno | Alta       | Não aplicável  |
| 14 | Pontuação e recompensas                     | Calcula e exibe a pontuação dos alunos com base nas respostas corretas.               | Aluno             | Alta       | Não aplicável  |
| 15 | Ranking de jogadores                        | Exibe a classificação dos alunos ao final de uma sessão de jogo.                      | Professor e aluno | Média      | Nome do aluno  |
| 16 | Multiplayer em sala                         | Permite que múltiplos alunos participem simultaneamente de uma mesma sessão.          | Aluno             | Alta       | Não aplicável  |
| 17 | Dashboard pedagógico                        | Disponibiliza um painel para que o professor visualize o desempenho geral da turma.   | Professor         | Média      | Nome do aluno  |
| 18 | Relatórios de desempenho                    | Gera relatórios com o histórico de respostas e a pontuação dos alunos em cada sessão. | Professor         | Baixa      | Nome do aluno  |

## Status no MVP mobile local

As 18 funcionalidades estão contempladas no aplicativo mobile. O escopo desta
versão é local: os dados ficam em SQLite no dispositivo e a sala multiplayer é
uma simulação determinística por meio de um gateway substituível.

| Itens | Status | Observação |
|---|---|---|
| 01–07 | Implementado | Autenticação, cadastros, seleção de eixo e questões por dificuldade. |
| 08–12 | Implementado | Listagem, filtros, edição e remoção de questões e edição dos perfis. |
| 13–15 | Implementado | Quiz, respostas persistidas, pontuação e ranking geral/por eixo. |
| 16 | MVP simulado | Sala local com entrada de jogadores simulados, estado de pronto, rodadas e ranking final. |
| 17–18 | Implementado | Dashboard isolado por professor e relatório com histórico de partidas e respostas por questão. |

O multiplayer real ainda exige a implementação de um gateway remoto, servidor,
identidade de sala compartilhada e sincronização entre dispositivos. Testes de
carga, concorrência e comunicação segura também não são atendidos pela versão
local.
