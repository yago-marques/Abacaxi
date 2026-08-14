---
name: new-feature-module
description: Cria um módulo SPM local novo em Modules/ com package, test target no project.yml, scheme no AllTests, swiftgen (se tiver strings), e AGENTS.md local. Use ao adicionar uma feature nova (UIKit ou SwiftUI) ou uma nova camada de infraestrutura que merece fronteira de compilação própria.
---

# new-feature-module

Cria a fronteira de compilação completa de um módulo novo. Referências: `Modules/Recipe/`
(feature SwiftUI), `Modules/Home/` (feature UIKit), `Modules/NetworkInterfaces/` (interface pura).

## Passos

1. **Package**: `Modules/<Nome>/Package.swift` espelhando um existente — `swift-tools-version: 5.9`,
   `platforms: [.iOS(.v16)]`, produto library único, dependências SÓ de packages de interface
   (feature nunca importa Data/Network/Persistence concretos — a fronteira é verificada no build).
   Módulos de interface novos habilitam `swiftSettings` com
   `.enableExperimentalFeature("StrictConcurrency")` e `.enableUpcomingFeature("ExistentialAny")`.
2. **Estrutura**: `Sources/<Nome>/` + `Tests/<Nome>Tests/` (com pelo menos um teste real).
   Se tiver strings: `Sources/<Nome>/swiftgen.yml` (copie de `Modules/Recipe/Sources/Recipe/swiftgen.yml`),
   `Resources/Base.lproj/Localizable.strings` e `Resources/Generated/.gitkeep`
   (**o .gitkeep é obrigatório** — sem ele o SwiftGen falha em clone fresco).
3. **project.yml** (três lugares):
   - `packages:` — entrada com o path do módulo;
   - `targets:` — `<Nome>Tests` usando o template `ModuleUnitTests`, sources em
     `Modules/<Nome>/Tests`, dependência do package;
   - `schemes.AllTests` — adicionar `<Nome>Tests: [test]` no build E na lista de test targets.
   Depois: `make generate` (obrigatório — nada compila no Xcode até regenerar).
4. **AGENTS.md local** em `Modules/<Nome>/AGENTS.md`: responsabilidade, dependências permitidas,
   entradas públicas (a factory do módulo), regras de teste — espelhe o de um módulo similar.
5. **Composição**: `<Nome>ModuleFactory` público (`@MainActor` se cria UI/coordinator) expondo
   a menor superfície possível; registro de use cases no app-shell
   (`Abacaxi/Sources/AbacaxiApp/Modules/<Nome>/<Nome>Module.swift`); navegação cross-feature
   via router protocol (exemplo: `HomeExternalRouterProtocol`), nunca import feature→feature.

## Convenções que o build vai cobrar

- ViewModels `@MainActor`; coordinators conformam `CoordinatorProtocol` (que é `@MainActor`);
  factories que criam UI são `@MainActor`.
- Tipos `internal` por padrão; `public` só na porta de composição.
- Todo protocolo termina em `Protocol`; erros são `enum: Error` por domínio.
- Testes: `makeSUTAndDoubles`, doubles com defaults válidos, sem `fatalError` em stub.

## Validação

- `make generate && make lint-strict` limpos; scheme `<Nome>Tests` verde; `AllTests` inclui o
  módulo novo (confira no output que os testes dele executaram).
