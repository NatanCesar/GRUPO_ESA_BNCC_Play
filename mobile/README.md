# BNCC Play Mobile

Aplicativo Flutter local para professores e alunos praticarem os eixos da
BNCC Computação por meio de questões e partidas gamificadas.

## Funcionalidades

- autenticação e perfis de professor e aluno;
- questões por eixo, dificuldade e categoria;
- seed inicial com 30 questões revisadas e categorizadas;
- partidas com pontuação, sequência de acertos e histórico de respostas;
- ranking geral e por eixo;
- dashboard e relatório de alunos isolados por professor;
- sala multiplayer simulada por um gateway local substituível.

O multiplayer desta versão não conecta dispositivos reais. O contrato
`MultiplayerGateway` permite trocar a simulação por uma implementação remota
sem reescrever a tela da sala.

## Execução

```bash
flutter pub get
flutter run
```

## Verificação

```bash
flutter analyze
flutter test
```
