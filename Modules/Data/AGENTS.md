# Data

Implementação concreta de contratos de `DataInterfaces`: `DeviceIDRepository` (implementa `DeviceIDRepositoryProtocol`, usando `SecureStoringProtocol` injetado). `DeviceIDRepositoryFactory` devolve o repositório pronto a partir do storage. Depende só de `DataInterfaces` e `PersistenceInterfaces` — nunca de `Domain` ou `Persistence` concretos.

Regra de nomenclatura: tipo concreto que implementa protocolo de `DataInterfaces` nunca leva o nome do backend de armazenamento (`DeviceIDRepository`, não `KeychainDeviceIDRepository`) — só a assinatura do `init` (que recebe `SecureStoringProtocol`) revela a implementação. Vazar o backend no nome quebraria DIP.

Testar: `cd Modules/Data && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
