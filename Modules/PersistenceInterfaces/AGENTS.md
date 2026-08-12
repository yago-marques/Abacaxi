# PersistenceInterfaces

Protocolos de armazenamento local: `KeyValueStoringProtocol` (UserDefaults, sem `throws`), `SecureStoringProtocol` (Keychain, `throws`), `PersistentEntityProtocol`/`PersistentStoringProtocol` (CoreData, genérico, `throws`). Zero dependências locais.

Regra: 3 protocolos separados de propósito — nenhuma interface unificada escondendo se um dado é seguro ou não. Ver `throws`/sem `throws` como parte do contrato, não detalhe de implementação.

Testar: `cd Modules/PersistenceInterfaces && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
