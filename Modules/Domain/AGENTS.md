# Domain

Implementação concreta de `DomainInterfaces`: `CreateDeviceIDUseCase` (sempre gera + salva um UUID novo, incondicional) e `GetDeviceIDUseCase` (só lê, nunca cria). `CreateDeviceIDUseCaseFactory` e `GetDeviceIDUseCaseFactory` montam os use cases a partir de `DeviceIDRepositoryProtocol` de `DataInterfaces`. Depende só de `DataInterfaces` e `DomainInterfaces`.

Regra: são dois use cases separados de propósito — nenhuma lógica "get-or-create" combinada aqui. Essa orquestração (checar, se `nil` então criar) vive em quem consome os dois (ex: `LauncherViewModel`), não dentro de um use case único.

Testar: `cd Modules/Domain && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
