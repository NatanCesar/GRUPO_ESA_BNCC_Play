# Privacidade e dados pessoais
Artefato consolidado a partir da Atividade 4 de Concepção do Sistema.

Na Atividade 4, cada estória de usuário apresenta um bloco de informações de privacidade. Este documento consolida essas informações em um único artefato.

## Informações gerais de privacidade

- **Dados pessoais utilizados:** nome, e-mail, identificador do usuário e dados relacionados à funcionalidade.
- **Finalidade do uso dos dados:** permitir a execução da funcionalidade e a gestão da plataforma.
- **Risco de privacidade associado:** acesso não autorizado, exposição ou uso indevido dos dados.
- **Estratégias de minimização/proteção:** autenticação, controle de acesso, criptografia e coleta mínima de dados.

## Dados pessoais por item do backlog

| ID | Funcionalidade | Dados pessoais indicados no backlog | Observação |
|---|---|---|---|
| 01 | Efetivação de login no sistema | Login, Senha | Exige atenção a controle de acesso e minimização de dados. |
| 02 | Cadastro de professor | Nome, E-mail, Login, Senha | Exige atenção a controle de acesso e minimização de dados. |
| 03 | Cadastro de aluno | Nome, E-mail, Login, Senha | Exige atenção a controle de acesso e minimização de dados. |
| 04 | Seleção de eixo da BNCC Computação | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 05 | Cadastro de questões | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 06 | Definição de nível de dificuldade das questões | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 07 | Listagem de questões por eixo | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 08 | Alteração de questão | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 09 | Remoção de questão | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 10 | Organização de questões por categorias | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 11 | Filtragem de conteúdos por eixo | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 12 | Listagem de questões por nível de dificuldade | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 13 | Alteração de cadastro do professor | Nome, E-mail | Exige atenção a controle de acesso e minimização de dados. |
| 14 | Alteração de cadastro do aluno | Nome, E-mail | Exige atenção a controle de acesso e minimização de dados. |
| 15 | Sistema gamificado de perguntas e respostas | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 16 | Pontuação e recompensas | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 17 | Ranking de jogadores | Nome do aluno | Exige atenção a controle de acesso e minimização de dados. |
| 18 | Multiplayer em sala | Não aplicável | Não há dado pessoal específico indicado no backlog. |
| 19 | Dashboard pedagógico | Nome do aluno | Exige atenção a controle de acesso e minimização de dados. |
| 20 | Relatórios de desempenho | Nome do aluno | Exige atenção a controle de acesso e minimização de dados. |

## Recomendações de proteção associadas aos cenários BDD

| Estratégia | Aplicação no sistema |
|---|---|
| Autenticação e controle de acesso | Aplicar login e permissões para áreas restritas, cadastro, edição, dashboard e relatórios. |
| Coleta mínima de dados | Solicitar apenas os dados necessários para identificação, autenticação e execução das funcionalidades. |
| Criptografia | Proteger credenciais e dados sensíveis armazenados ou trafegados pela plataforma. |
| Anonimização ou uso de identificadores públicos | No ranking, evitar exibir dados pessoais completos, utilizando apelidos ou identificadores públicos. |
| Restrição de visualização de desempenho | Impedir que estudantes visualizem histórico individual de terceiros. |
| Auditoria | Registrar alterações relevantes, como edição de questões e mudanças em dados cadastrais. |
| Acesso restrito a relatórios | Permitir consulta a relatórios apenas por usuários autorizados, como professores e coordenadores pedagógicos. |
