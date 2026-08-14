# Home

Primeiro fluxo do app: `HomeCoordinator` (navegação) + `HomeViewModel` + `HomeViewController`. A Home expõe conteúdo visual pelo `HomeViewState`; o ViewModel começa exibindo as tentativas em carregamento, usa apenas `GetRemainingAttemptsUseCaseProtocol` e transforma falhas em estado indisponível. Enquanto o card de receita for somente visual, não crie action ou coordinator para ele. O subfluxo `Onboarding/` contém `OnboardingViewModel`, `OnboardingViewController` e `OnboardingFactory`, responsáveis pelo estado de primeiro acesso. Depende de `GeneralInterfaces`, `DomainInterfaces`, `DesignSystem` e `Extensions`.

`OnboardingViewModel` chama `CoordinatorProtocol.handle(_:)` com `HomeAction` (`.openOnboarding` ou `.openHome`). `OnboardingFactory.makeViewController` resolve os protocolos de Use Case do container, injeta o coordinator e monta o ViewModel e a tela; o coordinator chama a factory diretamente. Factories são `enum` com métodos estáticos `make`.

## Localização

Textos de interface pertencem ao próprio módulo, em `Sources/Home/Resources/Base.lproj/Localizable.strings`. O SwiftGen da máquina gera `Resources/Generated/L10n.swift` pelo `make start`; use `L10n` em vez de literais em telas. O arquivo gerado não deve ser versionado.

Regra: não importa nenhum outro module de tela. Se `HomeCoordinator` precisar acionar um fluxo de outro módulo, recebe um callback de navegação pela factory; a composição do app decide o módulo de destino. Nunca importe o módulo de destino diretamente.

Testar: `xcodebuild -project Abacaxi.xcodeproj -scheme HomeTests -destination 'platform=iOS Simulator,name=iPhone 16' test`, ou `Scripts/on-write-code-check.sh Modules/Home/Tests/HomeTests/<arquivo>.swift`.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
