# GeneralInterfaces

Protocolos de navegação: `CoordinatorProtocol` (`navigationController`, `start()`, `handle(_:)`), `CoordinatorActionProtocol` (marker), e `UseCaseContainer` (composition). Zero dependências locais — importa só UIKit.

Regra: todo module de tela (`Home`, e os que vierem depois) conforma `CoordinatorProtocol` daqui. Nada aqui sabe de nenhum module de tela específico.

Testar: `xcodebuild -project Abacaxi.xcodeproj -scheme GeneralInterfacesTests -destination 'platform=iOS Simulator,name=iPhone 16' test`, ou `Scripts/on-write-code-check.sh Modules/GeneralInterfaces/Tests/GeneralInterfacesTests/<arquivo>.swift`.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
