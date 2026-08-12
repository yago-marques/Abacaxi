# DomainInterfaces

Contratos de domínio: protocolos de use case para consumo cross-module — `CreateDeviceIDUseCaseProtocol`/`GetDeviceIDUseCaseProtocol`. `DeviceIDRepositoryProtocol` pertence a `DataInterfaces`. Zero dependências locais.

Regra: módulos de tela (ex: `Launcher`) dependem daqui pros use cases, nunca de `Domain` concreto — permite injetar via `UseCaseContainer` sem acoplar tela↔domínio.

Testar: `cd Modules/DomainInterfaces && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
