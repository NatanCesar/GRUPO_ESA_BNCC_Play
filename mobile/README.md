# BNCC Play Mobile

Aplicativo Android desenvolvido em Flutter para professores e alunos
praticarem os eixos da BNCC Computação por meio de questões e partidas
gamificadas. Esta é a entrega final do aplicativo mobile da disciplina de
Engenharia de Software.

## Download para Android

[**Baixar o APK da versão mais recente**](https://github.com/NatanCesar/GRUPO_ESA_BNCC_Play/releases/latest/download/bncc-play.apk)

- Versão desta entrega: **1.0.0**
- SHA-256 do APK: `c37266de1460725b4ea0b3665197f78243ace5656a5ce5de3bf79098494a1ea3`

Escaneie o QR Code para abrir o download no celular:

<a href="https://github.com/NatanCesar/GRUPO_ESA_BNCC_Play/releases/latest/download/bncc-play.apk">
  <img src="../docs/qr-code-apk.png" alt="QR Code para baixar o APK do BNCC Play" width="240">
</a>

### Instalação do APK

1. Baixe o arquivo `bncc-play.apk` pelo link ou QR Code acima.
2. Abra o arquivo no dispositivo Android.
3. Se solicitado, autorize a instalação de aplicativos de fontes desconhecidas
   para o navegador ou gerenciador de arquivos usado no download.
4. Confirme a instalação e abra o **BNCC Play**.

O APK requer Android 7.0 (API 24) ou superior. Ele é destinado à avaliação e
distribuição direta; não é necessário instalar Flutter para utilizá-lo.

## Equivalência com o Kodular

O projeto não utiliza Kodular. Nesta entrega:

| Kodular | Flutter adotado no projeto |
|---|---|
| Projeto editável `.aia` | Pasta `mobile/`, `pubspec.yaml` e código-fonte Flutter |
| APK exportado | `bncc-play.apk` publicado em uma GitHub Release |
| Teste pelo Companion | `flutter run` em dispositivo ou emulador |
| QR Code do aplicativo | QR Code acima, apontando para o APK da Release |

## Escopo e funcionalidades

- autenticação, cadastro e perfis de professor e aluno;
- questões por eixo, dificuldade e categoria;
- base inicial com 30 questões revisadas e categorizadas;
- partidas com pontuação, sequência de acertos e histórico de respostas;
- ranking geral e por eixo;
- dashboard e relatórios de alunos isolados por professor;
- sala multiplayer simulada por um gateway local substituível;
- persistência local em SQLite, sem necessidade de servidor.

### Atendimento ao backlog

| ID | Funcionalidade | Situação no mobile |
|---:|---|---|
| 01 | Login do professor | Implementado |
| 02 | Login do aluno | Implementado |
| 03 | Cadastro de professor | Implementado |
| 04 | Cadastro de aluno | Implementado |
| 05 | Seleção de eixo da BNCC Computação | Implementado |
| 06 | Cadastro de questões | Implementado |
| 07 | Definição do nível de dificuldade | Implementado |
| 08 | Listagem de questões por eixo | Implementado |
| 09 | Alteração de questão | Implementado |
| 10 | Remoção de questão | Implementado |
| 11 | Alteração do cadastro do professor | Implementado |
| 12 | Alteração do cadastro do aluno | Implementado |
| 13 | Sistema gamificado de perguntas e respostas | Implementado no modo local |
| 14 | Pontuação e recompensas | Implementado |
| 15 | Ranking de jogadores | Implementado |
| 16 | Multiplayer em sala | MVP local simulado |
| 17 | Dashboard pedagógico | Implementado |
| 18 | Relatórios de desempenho | Implementado |

O backlog detalhado está em [`../backlog.md`](../backlog.md), e sua relação com
os testes está em [`../docs/casos-de-teste.md`](../docs/casos-de-teste.md).

## Limitações conhecidas

O multiplayer desta versão simula os outros participantes no próprio aparelho;
ele não conecta dispositivos reais. O contrato `MultiplayerGateway` permite
substituir a simulação por uma implementação remota sem reescrever a tela da
sala. Funcionalidades de rede, sincronização, carga e concorrência entre
dispositivos ficam fora do escopo deste MVP local.

## Pré-requisitos para desenvolvimento

- Flutter 3.44.2 stable, com Dart 3.12.2;
- Android Studio e Android SDK para executar ou compilar para Android;
- Java 17;
- dispositivo Android ou emulador configurado;
- Git.

Confira o ambiente:

```bash
flutter --version
flutter doctor
flutter devices
```

## Executar pelo código-fonte

Na raiz do repositório:

```bash
cd mobile
flutter pub get
flutter run
```

Para escolher um dispositivo específico, consulte `flutter devices` e use:

```bash
flutter run -d <ID_DO_DISPOSITIVO>
```

O banco SQLite e sua estrutura são criados automaticamente na primeira
execução. O aplicativo mobile funciona localmente e não exige que o backend ou
o frontend web estejam em execução.

## Gerar o APK

```bash
cd mobile
flutter pub get
flutter build apk --release
```

O arquivo será criado em:

```text
mobile/build/app/outputs/flutter-apk/app-release.apk
```

## Verificação

```bash
flutter analyze
flutter test --concurrency=1
```

Os testes de integração que exigem um dispositivo ou emulador podem ser
executados com:

```bash
flutter test integration_test/
```
