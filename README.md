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

## Entrega final do aplicativo mobile

O aplicativo foi desenvolvido em **Flutter**, como alternativa ao Kodular. O
equivalente ao arquivo `.aia` é o código-fonte disponível na pasta
[`mobile/`](mobile/), acompanhado do `pubspec.yaml` e dos projetos nativos. O
APK é o artefato instalável para Android.

[**Baixar BNCC Play para Android (APK)**](https://github.com/NatanCesar/GRUPO_ESA_BNCC_Play/releases/latest/download/bncc-play.apk)

Escaneie o QR Code para abrir o download do APK no celular:

<a href="https://github.com/NatanCesar/GRUPO_ESA_BNCC_Play/releases/latest/download/bncc-play.apk">
  <img src="docs/qr-code-apk.png" alt="QR Code para baixar o APK do BNCC Play" width="240">
</a>

> No Android, pode ser necessário autorizar a instalação de aplicativos de
> fontes desconhecidas para o navegador ou gerenciador de arquivos utilizado.
> O código-fonte, instruções completas e a matriz do backlog estão no
> [README do aplicativo mobile](mobile/README.md).

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

* React 18
* Vite
* React Router DOM
* Socket.IO Client
* ESLint (com plugins `react`, `react-hooks`, `react-refresh`)

## Backend

* Node.js
* Express
* Socket.IO
* Prisma ORM (`@prisma/client`)
* CORS
* dotenv (variáveis de ambiente)

## Banco de Dados

* PostgreSQL (backend web)
* SQLite (mobile, via `sqflite`)

## Mobile

* Flutter (Dart SDK `^3.12.2`)
* sqflite (persistência local)
* path (manipulação de caminhos do banco)
* Provider (gerenciamento de estado)
* crypto (hash de senhas)
* flutter_lints (análise estática)
* sqflite_common_ffi (suporte a testes em desktop)



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
├── mobile/
│   ├── lib/
│   ├── assets/
│   ├── integration_test/
│   ├── test/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
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

* Multiplayer real entre dispositivos (substituindo o gateway local simulado)
* Integração com plataformas educacionais
* Exportação de relatórios
* Sistema de turmas
* Autenticação centralizada de professores e alunos (compartilhada entre web e mobile)

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
git clone https://github.com/NatanCesar/GRUPO_ESA_BNCC_Play.git

cd GRUPO_ESA_BNCC_Play
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

# Mobile (Flutter)

Aplicativo Flutter local voltado a professores e alunos, com banco SQLite local,
sistema de partidas, ranking, dashboard e relatórios. O multiplayer desta versão
é simulado por um gateway local substituível (`MultiplayerGateway`).

## Pré-requisitos

* Flutter 3.44.2 com Dart 3.12.2, versões usadas para validar esta entrega
* Android Studio (com Android SDK + emulador configurado) e/ou Xcode para iOS
* Chrome ou outro navegador, caso queira rodar na web
* Java 17 para o build Android
* Git

> O arquivo [mobile/mise.toml](mobile/mise.toml) declara as ferramentas nativas
> usadas no build (`cmake`, `ninja`, `clang`). Caso utilize `mise`, basta rodar
> `mise install` dentro de `mobile/`.

---

## Acessar pasta

```bash id="mobile-cd"
cd mobile
```

## Instalar dependências

```bash id="mobile-pub-get"
flutter pub get
```

## Verificar ambiente

Confirme se o Flutter detecta seus dispositivos:

```bash id="mobile-devices"
flutter doctor
flutter devices
```

---

## Executar aplicação

Use o comando genérico abaixo escolhendo o device alvo com `-d`:

```bash id="mobile-run"
flutter run
```

Ou de forma explícita:

```bash id="mobile-run-platform"
# Android (emulador ou dispositivo físico conectado)
flutter run -d android

# iOS (somente macOS com Xcode configurado)
flutter run -d ios

# Web (recomenda-se Chrome)
flutter run -d chrome
```

> No primeiro build Android/iOS o Flutter baixa dependências nativas e gera o
> projeto Gradle/Pod — pode demorar alguns minutos.

---

## Build de release

```bash id="mobile-build"
# Android (APK)
flutter build apk --release

# Android (App Bundle para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

O APK é gerado em
`mobile/build/app/outputs/flutter-apk/app-release.apk`. Os demais artefatos
ficam em `mobile/build/`.

---

## Verificação (análise e testes)

```bash id="mobile-check"
flutter analyze
flutter test
```

Para testes de integração:

```bash id="mobile-integration"
flutter test integration_test
```

---

# Scripts Disponíveis

## Backend

```bash id="n4m9j5"
npm run dev         # sobe o servidor com --watch (modo desenvolvimento)
npm start           # sobe o servidor em modo produção
npm run db:migrate  # aplica as migrations do Prisma
npm run db:generate # gera o cliente do Prisma
npm run db:studio   # abre o Prisma Studio
```

## Frontend

```bash id="frontend-scripts"
npm run dev      # inicia o Vite em modo desenvolvimento
npm run build    # gera o bundle de produção em dist/
npm run preview  # serve o build de produção localmente
npm run lint     # roda o ESLint
```

## Mobile

```bash id="mobile-scripts"
flutter pub get           # instala dependências do pubspec.yaml
flutter run               # executa no device/emulador padrão
flutter analyze           # análise estática (flutter_lints)
flutter test              # roda os testes unitários
flutter test integration_test  # roda os testes de integração
flutter build apk --release        # gera APK Android
flutter build appbundle --release  # gera AAB para Play Store
flutter build ios --release        # gera build iOS
flutter build web --release        # gera build Web
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
