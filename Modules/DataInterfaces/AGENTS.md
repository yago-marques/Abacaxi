# DataInterfaces

Contratos de dados: `DeviceIDRepositoryProtocol` (`save(_:)`/`load()`, `throws`). `Data` implementa o contrato e `Domain` depende dele como abstração, sem importar o módulo concreto `Data`.

Testar: `cd Modules/DataInterfaces && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
