# Abacaxi

App mobile de banking. Auth, contas, cartões, extrato, API própria com JWT.

## Quick Start

Único comando necessário:

```bash
make start
```

Isso instala o XcodeGen e o SwiftGen (se necessário), gera os fontes localizados tipados, gera o projeto Xcode a partir de `project.yml` e abre no Xcode.

Para regenerar apenas as strings tipadas de todos os módulos, use:

```bash
make generate-localizations
```

## Targets

| Target | Ambiente |
|---|---|
| `Abacaxi Stage` | Stage |
| `Abacaxi` | Production |

## Estrutura

```
project.yml            # definição do projeto (XcodeGen)
Makefile                # make start / generate / open / clean / bootstrap
Configs/
  Base.xcconfig          # comum a todos os targets
  App.xcconfig            # identidade do app (bundle id root, display name, API host)
  Environments/           # valores por ambiente (stage/production)
  Targets/                # combinação Base + App + Environment por target
Modules/
  NetworkInterfaces/       # contratos de rede (protocolos, tipos) — zero dependências
  Network/                 # cliente HTTP, JWT — implementa NetworkInterfaces
Abacaxi/                 # app-shell
```

O `.xcodeproj` gerado não é versionado — sempre rode `make start` (ou `make generate`) antes de abrir o projeto.

## Build isolado por módulo

Cada módulo em `Modules/` é um package SPM independente, buildável sozinho, sem tocar nos outros ou no app-shell.

Direto pelo package (sem Xcode):

```bash
cd Modules/Network && swift build
```

Dentro do projeto gerado, cada módulo também vira um scheme próprio (`Network`, `NetworkInterfaces`), além dos 2 schemes de app:

```bash
xcodebuild -project Abacaxi.xcodeproj -scheme Abacaxi -destination "generic/platform=iOS Simulator" build
```
