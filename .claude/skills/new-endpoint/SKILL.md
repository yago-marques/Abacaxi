---
name: new-endpoint
description: Adiciona a fatia Data de um endpoint HTTP novo (Endpoint privado, remote models, mapeamento exaustivo de NetworkError, testes de contrato na wire) num repository existente ou novo. Use quando o contrato de domínio já existe e falta só a integração remota. Para a cadeia completa com use case novo, use new-usecase-flow.
---

# new-endpoint

Implementa a integração remota seguindo o contrato Swagger/OpenAPI do servidor e o padrão
do repositório. Referências canônicas: `Modules/Data/Sources/Data/Recipe/RecipeRepository.swift`
(POST com body) e `Modules/Data/Sources/Data/Attempts/AttemptsRepository.swift` (GET simples).

## Estrutura obrigatória

1. **Endpoint privado** (`private extension <Repo> { struct Endpoint: HTTPEndpointProtocol }`):
   - `path`, `method`, `headers` (sempre `X-Device-ID` e `X-API-Key` quando autenticado);
   - body pré-codificado: `let body: Data?` atribuído em `init(...) throws` com
     `try JSONEncoder().encode(...)` — **nunca `try?` em body** (falha local deve ser explícita).
2. **Remote models privados** ao arquivo: request `Encodable`, response `Decodable`, com
   `CodingKeys` para snake_case. Detalhes de transporte não vazam do arquivo — a conversão
   para BusinessModel acontece em `private extension <BusinessModel> { init(response:) }`.
3. **Mapeamento exaustivo de erro** — o método público faz:
   ```swift
   } catch let error as NetworkError {
       throw map(error)
   } catch {
       throw <Repo>Error.invalidResponse
   }
   ```
   com `map`: `.statusCode(_, data) → mapError(data:)`, `.transport → .network`,
   `.cancelled → .cancelled`, demais → `.invalidResponse`. Códigos do backend via
   `BackendErrorRemoteModel.code(from:)` — casos novos entram no `BackendErrorCode`
   (`Modules/Data/Sources/Data/Recipe/BackendErrorRemoteModel.swift`).
4. **Amounts e valores compartilhados**: use os helpers existentes
   (ex.: `RecipeIngredientBusinessModel.Amount.remoteValue`) — não duplique switches.

## Testes (espelhe RecipeQuestionsRepositoryTests / RecipeRepositoryTests)

- Request na wire: assert de path, method, headers e body decodificado com `JSONSerialization`.
- Decode do payload de sucesso completo, incluindo opcionais nulos.
- Mapeamento parametrizado: loop `[(código do backend, erro esperado)]` + body indecifrável
  → `.invalidResponse` + `NetworkError.transport(URLError(.notConnectedToInternet))` → `.network`
  + `.cancelled → .cancelled`.
- Strings→Data nos testes: `Data("...".utf8)`, nunca `.data(using:)`.

## Validação

- Hook roda lint + DataTests a cada arquivo salvo; não avance com FAILED.
- Teste novo exige `make generate` para entrar no build (XcodeGen) — confirme que o teste
  novo aparece executado no output antes de confiar no verde.
