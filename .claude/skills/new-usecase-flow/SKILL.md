---
name: new-usecase-flow
description: Cria um Use Case novo de ponta a ponta (DomainInterfaces → Domain → DataInterfaces → Data → registro no app-shell → testes por camada) seguindo o golden path do repositório. Use quando adicionar capacidade de negócio nova, um fluxo que consome endpoint novo, ou qualquer feature que atravessa as camadas. Não use para mudanças só de UI ou só de Data (para endpoint isolado, use new-endpoint).
---

# new-usecase-flow

Cria a cadeia completa de um Use Case respeitando as fronteiras de compilação do repositório.
Antes de começar, leia `.claude/CODE_RULES/20-swift.md` e `30-architecture.md` (regras normativas)
e os arquivos de referência de cada passo — **espelhe o código canônico vivo, nunca invente
estrutura nova nem copie de memória**.

## Golden path (arquivos de referência)

O par `GetRecipeQuestions` é o exemplo canônico de cada camada:

| Camada | Referência |
| --- | --- |
| Contrato + erro (DomainInterfaces) | `Modules/DomainInterfaces/Sources/DomainInterfaces/Recipe/GetRecipeQuestionsError.swift` e o protocolo correspondente |
| Use case + factory (Domain) | `Modules/Domain/Sources/Domain/Recipe/GetRecipeQuestionsUseCase.swift` |
| Contrato de dados (DataInterfaces) | `Modules/DataInterfaces/Sources/DataInterfaces/Recipe/RecipeQuestionsRepositoryProtocol.swift` |
| Repository + remote models (Data) | `Modules/Data/Sources/Data/Recipe/RecipeQuestionsRepository.swift` |
| Registro no app-shell | `Abacaxi/Sources/AbacaxiApp/Modules/Recipe/RecipeModule.swift` |
| Testes de use case | `Modules/Domain/Tests/DomainTests/Recipe/GetRecipeQuestionsUseCaseTests.swift` |
| Testes de repository (wire) | `Modules/Data/Tests/DataTests/Recipe/RecipeQuestionsRepositoryTests.swift` |

## Ordem dos passos

1. **DomainInterfaces**: protocolo `<Nome>UseCaseProtocol` + enum de erro `<Nome>Error`
   (casos tipados; inclua `noConnection` e `cancelled` se o fluxo toca rede). BusinessModels
   novos são `Equatable, Sendable`. Este módulo compila com `StrictConcurrency` e
   `ExistentialAny` — protocolos usados como tipo exigem `any`.
2. **DataInterfaces**: protocolo `<Nome>RepositoryProtocol` + enum `<Nome>RepositoryError`
   (com `.network` e `.cancelled` se remoto). Mesmas features de compilador do passo 1.
3. **Domain**: `<Nome>UseCase` (público, `final class`) + `<Nome>UseCaseFactory` enum com
   `make(...)` retornando o protocolo. Validações de entrada ANTES de tocar o repository
   (use `IngredientLimits` como exemplo de regra compartilhada). Mapeie o erro do repository
   para o erro de domínio com `switch` exaustivo — sem `default`.
4. **Data**: repository com `Endpoint` privado (body pré-codificado em `init(...) throws`),
   remote models privados, `catch let error as NetworkError { throw map(error) }` exaustivo
   (`.transport → .network`, `.cancelled → .cancelled`, `.statusCode → mapError(data:)`,
   demais → `.invalidResponse`). Códigos de erro do backend passam por
   `BackendErrorRemoteModel.code(from:)` — adicione casos novos ao `BackendErrorCode`,
   nunca strings soltas.
5. **App-shell**: registre no `*Module.registerDependencies` correspondente
   (`container.register(<Protocolo>.self) { <Builder>.make() }`) e crie o builder em
   `Abacaxi/Sources/AbacaxiApp/Modules/` espelhando os existentes.
6. **Apresentação** (se houver): ViewModels são `@MainActor`; emitem estado/caso de falha
   tipado — a View mapeia para `L10n` (strings novas em `Localizable.strings` + entrada
   manual no `Resources/Generated/L10n.swift` até o próximo `make generate-localizations`).
   Trabalho async vive em `Task` guardada no VM com `cancelGeneration()`-like e `deinit` cancelando.

## Testes (obrigatório em cada camada)

- Siga `.claude/CODE_RULES/10-testing.md`: `makeSUTAndDoubles()` em extension privada,
  doubles com sufixo Stub/Spy e **defaults válidos** (nunca `fatalError` em stub), AAA,
  nomes `test_<método>_when<condição>_<resultado>` (XCTest) ou descritivos (Swift Testing).
- Use case: sucesso com verificação de argumentos no stub; validações de boundary SEM chamar
  o repository; um teste por braço do mapeamento de erro (pode ser loop parametrizado).
- Repository: request na wire via `JSONSerialization` (path, method, headers, body), decode do
  payload completo (incluindo campos opcionais nulos), mapeamento parametrizado dos códigos de
  erro incluindo transporte→`.network` e `.cancelled`.

## Validação e pegadinhas de build

- A cada arquivo `.swift` salvo em `Modules/`, o hook roda SwiftLint + os testes do módulo no
  simulador. **Não avance com `** TEST FAILED **`** — corrija antes.
- Arquivo de **teste** novo NÃO entra no build até rodar `make generate` (o XcodeGen lista
  testes explicitamente no pbxproj). Arquivos de **Sources** de packages o SPM descobre sozinho.
  Se o hook rodar "verde" sem executar seu teste novo, é esse o motivo — rode `make generate`.
- Antes de encerrar: `make lint-strict` limpo e o test target do módulo verde.
