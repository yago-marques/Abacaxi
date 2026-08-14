# Regras de Swift

## Erros

Todo erro lançado (`throws`) é um `enum` conformando `Error`, nunca `struct`. Cada caso de falha vira um `case`, com dado associado quando fizer sentido (ex: código de status, nome da entidade).

Falhas que chegam à apresentação e exigem retorno ao usuário devem, por padrão, usar o toast de erro do Design System com mensagem localizada. O ViewModel emite um estado/caso de falha — nunca a descrição bruta de um `Error` — e a View mapeia esse caso para o `Localizable` antes de apresentar o toast. Exceções só são aceitas quando o erro é deliberadamente não-bloqueante; o `catch` deve documentar esse motivo, jamais ficar vazio.

```swift
public enum KeychainError: Error {
    case missingBundleIdentifier
    case unhandledStatus(OSStatus)
}
```

Motivo: várias formas de falhar dentro do mesmo domínio (Keychain, CoreData, rede) — um `enum` deixa isso exaustivo e faz o `switch` no chamador ser exaustivo também. `struct` força um tipo de erro por domínio inteiro, escondendo os casos possíveis.

## Quebra de linha

**Assinatura de método com muitos parâmetros**: um parâmetro por linha, parêntese de fechamento sozinho.

```swift
public init(
    container: NSPersistentContainer,
    entityName: String,
    idKeyPath: String,
    map: @escaping (Entity, ManagedObject) -> Void,
    toEntity: @escaping (ManagedObject) -> Entity
) {
```

**Chamada encadeada sobre retorno de função** (`data.join().find().use()`): cada chamada em linha própria, ponto alinhado.

```swift
let names = items
    .filter { $0.isActive }
    .map(\.name)
    .sorted()
```

Regra: se cabe legível numa linha só, fica numa linha só. Quebra quando a assinatura/cadeia passa de ~2-3 elementos ou estoura a largura legível — não é regra de contagem de caractere fixa, é legibilidade.

## Protocolos

Todo `protocol` termina em `Protocol`, sem exceção — `Coordinator` → `CoordinatorProtocol`, `HTTPClient` → `HTTPClientProtocol`, `KeyValueStoring` → `KeyValueStoringProtocol`. O tipo concreto que implementa NÃO leva o sufixo e mantém seu próprio nome descritivo (`HomeCoordinator`, `URLSessionHTTPClient`, `UserDefaultsStore` continuam iguais).

```swift
public protocol SecureStoringProtocol {
    func save(_ data: Data, forKey key: String) throws
}

public final class KeychainStore: SecureStoringProtocol { ... }
```

Motivo: deixa inequívoco na leitura da assinatura/import se algo é contrato (`Protocol`) ou implementação concreta — sem isso, nome do protocolo e nome do implementador ficam parecidos demais (`Coordinator` vs. `HomeCoordinator`) e confundem qual é qual.

## Controle de acesso entre módulos

Todo tipo e membro é `internal` por padrão. Use `public` somente quando ele for, de forma intencional, uma entrada ou contrato que outro módulo precisa consumir. Uma feature deve expor a menor superfície possível — por exemplo, uma única factory pública que retorna um protocolo — e manter ViewControllers, ViewModels, actions, estados e factories auxiliares internos ao módulo.

Os testes do próprio módulo usam `@testable import <Module>` e, por isso, podem acessar símbolos `internal`. Nunca transforme tipos em `public` apenas para testá-los.

## Swift Testing

Em novos fluxos SwiftUI, prefira Swift Testing para regras de ViewModel e estados de apresentação: `import Testing`, `@Test` e `#expect`. O teste permanece no bundle do módulo, usa `@testable import` para acessar tipos internos e valida comportamento observável, não a estrutura privada de uma View.
