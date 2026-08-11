# Persistence

Implementação concreta de `PersistenceInterfaces`: `UserDefaultsStore`, `KeychainStore`, `CoreDataStore<Entity: PersistentEntity, ManagedObject: NSManagedObject>` (motor genérico). Depende só de `PersistenceInterfaces`.

Regra: NENHUMA entidade de produto (Transaction, Card, etc.) mora aqui — `DB.xcdatamodeld` (`Resources/`) fica vazio de propósito. Entidade real nasce no module `Data` quando ele for recriado; `Data` deve depender só de `PersistenceInterfaces` (não deste module direto) — implementação concreta é injetada no composition root (app target).

`CoreDataStore` é genérico: pra testar sem entidade de produto, monta um `NSManagedObjectModel` programático em memória (ver `Tests/PersistenceTests/Doubles/TestItem.swift`) — não usa o `DB.xcdatamodeld` real do módulo pra isso.

Testar: `cd Modules/Persistence && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
