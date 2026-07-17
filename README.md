# BNCC Play

Plataforma educacional gamificada voltada ao apoio do ensino de Computação na Educação Básica, alinhada às diretrizes da BNCC Computação.

---

# Sobre o Projeto

O **BNCC Play** é uma plataforma desenvolvida para auxiliar professores e estudantes no processo de aprendizagem de conteúdos relacionados à Computação de forma dinâmica, acessível e gamificada.

O sistema organiza atividades, perguntas, desafios e conteúdos pedagógicos com base nos eixos da BNCC Computação, permitindo que o professor selecione previamente o eixo desejado antes do início das atividades.

A proposta busca fortalecer competências como:

* Pensamento computacional
* Resolução de problemas
* Raciocínio lógico
* Aprendizagem ativa
* Gamificação educacional

Além disso, o projeto considera princípios de UX/UI para oferecer uma experiência simples, intuitiva e acessível em ambiente escolar.

---

# Objetivos

* Apoiar o ensino de Computação na Educação Básica
* Tornar as aulas mais interativas e gamificadas
* Facilitar a organização pedagógica dos conteúdos
* Incentivar a participação ativa dos estudantes
* Permitir expansão modular baseada na BNCC Computação

---

# Principais Funcionalidades

* Seleção de eixo da BNCC Computação
* Organização de conteúdos por eixo temático
* Sistema gamificado de perguntas e respostas
* Cadastro dinâmico de questões
* Organização de questões por categorias
* Níveis de dificuldade
* Filtragem de conteúdos conforme o eixo escolhido
* Interface voltada para professores e estudantes
* Estrutura modular e escalável
* Plataforma de apoio pedagógico

---

# Tecnologias Utilizadas

## Frontend

* React
* Vite
* React Router DOM
* Socket.IO Client

## Backend

* Node.js
* Express
* Socket.IO
* Prisma ORM

## Banco de Dados

* PostgreSQL

---

# Estrutura do Projeto

```text id="0zy6t4"
BNCC-Play/
├── frontend/
│   ├── src/
│   ├── public/
│   └── package.json
│
├── backend/
│   ├── prisma/
│   ├── src/
│   │   ├── controllers/
│   │   ├── lib/
│   │   ├── routes/
│   │   ├── socket/
│   │   └── server.js
│   └── package.json
│
└── README.md
```

---

# UX/UI

O projeto considera princípios de UX/UI para garantir:

* Facilidade de uso
* Navegação intuitiva
* Organização visual clara
* Boa experiência em ambiente escolar
* Interface acessível para alunos e professores

---

# Futuras Melhorias

* Ranking de jogadores/alunos
* Sistema de pontuação e recompensas
* Dashboard pedagógico
* Relatórios de desempenho
* Multiplayer em sala
* Integração com plataformas educacionais
* Exportação de relatórios
* Sistema de turmas
* Autenticação de professores e alunos

---

# Protótipo navegável

[Figma](https://www.figma.com/proto/hhFOiR5NpPadzcjIk1ZBzy/BNCC-Play?node-id=35-3&p=f&m=draw&scaling=scale-down&content-scaling=fixed&page-id=0%3A1&starting-point-node-id=35%3A3&show-proto-sidebar=1&t=0LGuvAwcEHhD9MhU-1)

---

# Como Executar o Projeto

## Pré-requisitos

* Node.js 18+
* PostgreSQL
* npm ou yarn

---

# Clonar o Repositório

```bash id="jlwmif"
git clone https://github.com/NatanCesar/BNCC-Play.git

cd BNCC-Play
```

---

# Backend

## Acessar pasta

```bash id="fkgqyf"
cd backend
```

## Instalar dependências

```bash id="5v2m87"
npm install
```

## Configurar variáveis de ambiente

Crie um arquivo `.env` na pasta `backend`:

```env id="psuz7z"
DATABASE_URL="postgresql://user:password@localhost:5432/bncc_play"

PORT=3001

FRONTEND_ORIGIN=http://localhost:5173
```

---

## Gerar cliente Prisma

```bash id="t67g2m"
npm run db:generate
```

---

## Executar migrations

```bash id="vukn10"
npm run db:migrate
```

---

## Iniciar backend

```bash id="3of6p6"
npm run dev
```

Servidor disponível em:

```text id="4y5ccm"
http://localhost:3001
```

---

# Frontend

## Acessar pasta

```bash id="h0hhq4"
cd frontend
```

## Instalar dependências

```bash id="q4qaqn"
npm install
```

## Executar aplicação

```bash id="4mrmkk"
npm run dev
```

Frontend disponível em:

```text id="65q3xr"
http://localhost:5173/BNCC-Play/
```

---

# Scripts Disponíveis

## Backend

```bash id="n4m9j5"
npm run dev
npm start
npm run db:migrate
npm run db:generate
npm run db:studio
```

---

# Contribuição

Contribuições são bem-vindas.

## Passos

1. Faça um fork do projeto

2. Crie uma branch:

```bash id="1jdr6k"
git checkout -b feature/minha-feature
```

3. Commit suas alterações:

```bash id="k9b4h9"
git commit -m "feat: minha nova feature"
```

4. Envie para sua branch:

```bash id="1olr6n"
git push origin feature/minha-feature
```

5. Abra um Pull Request

---

# Licença

Este projeto está sob a licença MIT.

---

# Autor

Desenvolvido por Nataniel Cesar, Diogo Mendonça de Almeida Oliveira, Fernanda Rodrigues da Silva, Gustavo Coutinho Soares, Luiz Gustavo dos Santos Silva e Marcos Antonio Jose da Silva.
