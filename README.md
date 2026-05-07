# App Hipertrofia v2

Aplicativo móvel Flutter para acompanhamento de treinos e histórico de exercícios. Este repositório contém o cliente (app) que se integra com a API do projeto para autenticação, sincronização de treinos e persistência de dados.

## Visão geral

- Plataforma: Flutter (Android, iOS, Web, Windows, macOS, Linux)
- Linguagem: Dart
- Estrutura: código organizado em `lib/` com modelos, providers, serviços e telas

## Principais funcionalidades

- Login / Cadastro com integração à API
- Execução e acompanhamento de treinos
- Histórico de treinos com detalhes de sessões e sets
- Onboarding para configuração inicial

## Arquitetura

- `models/` — modelos de dados (ex.: `exercise.dart`, `user.dart`)
- `providers/` — lógica de estado (ex.: `auth_provider.dart`, `workout_provider.dart`)
- `services/` — comunicação com a API (`lib/services/api_service.dart`)
- `screens/` — telas da UI

## Configuração da API

O app consome uma API remota. Existem duas formas comuns de configurar a URL base da API:

1. Editando `lib/services/api_service.dart` e ajustando a constante `baseUrl` para o endpoint da sua API.
2. Usando `--dart-define` para sobrescrever em tempo de execução (recomendado para builds e CI):

```bash
flutter run -d <device> --dart-define=API_BASE_URL=https://api.exemplo.com
flutter build apk --dart-define=API_BASE_URL=https://api.exemplo.com
```

No código, verifique se `api_service.dart` lê `String.fromEnvironment('API_BASE_URL')` ou oferece um ponto fácil para alterar a URL base.

### Autenticação

O fluxo de autenticação é via API (provavelmente retornando um token). Após o login, o token é usado nas requisições subsequentes — verifique `auth_provider.dart` e `api_service.dart` para como o token é armazenado e anexado aos cabeçalhos.

---

<img width="514" height="957" alt="HomePage (1)" src="https://github.com/user-attachments/assets/a5ddac2a-2114-4880-8d09-74fc2b0cc946" />

---

<img width="600" height="1023" alt="FeedbackIA (1)" src="https://github.com/user-attachments/assets/13ad0ced-a2a3-4b3d-a8e0-1d0e10608f6b" />

---




## Instalação e execução (desenvolvimento)

Pré-requisitos:
- Flutter SDK instalado (versão compatível com o `pubspec.yaml`)

Passos:

```bash
# obter dependências
flutter pub get

# executar no emulador ou dispositivo
flutter run

# executar testes
flutter test
```

Para executar com uma API específica (usar `--dart-define` conforme acima):

```bash
flutter run --dart-define=API_BASE_URL=https://api.exemplo.com
```

## Build para release

Android (APK):

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.exemplo.com
```

iOS (device / App Store):

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://api.exemplo.com
```

## Estrutura de pastas relevante

- `lib/models/` — modelos de dados
- `lib/services/api_service.dart` — cliente HTTP / baseURL
- `lib/providers/` — lógica de estado e integração com serviços
- `lib/screens/` — telas do app

## Como contribuir

- Abra uma issue descrevendo a mudança desejada ou um bug.
- Crie uma branch com um nome descritivo: `feature/nova-funcionalidade` ou `fix/descricao-bug`.
- Abra um pull request com descrição clara das mudanças e como testar.

## Dicas de debugging

- Verifique logs do Flutter (`flutter run` mostra saída). 
- Teste endpoints da API com `curl` ou Postman para isolar problemas do backend.

## Contato

Se precisar de ajuda com a integração da API, disponibilidade de endpoints ou autenticação, entre em contato com o mantenedor do backend.

## Licença

Adicione um arquivo `LICENSE` no repositório com a licença desejada (ex.: MIT). Se não existir, converse com os mantenedores para escolher a licença.
# app_hipertrofia_v2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
