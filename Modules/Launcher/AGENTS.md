# Launcher

Primeiro fluxo do app, roda antes da Home: `LauncherViewController` (splash com a logo do app) + `LauncherViewModel` (orquestra `GetDeviceIDUseCaseProtocol`/`CreateDeviceIDUseCaseProtocol` — chama get, se `nil` chama create, então envia `LauncherAction.closeLauncher`) + `LauncherCoordinator` + `LauncherFactory` (monta a tela e o ViewModel a partir do container). Depende de `GeneralInterfaces`, `DomainInterfaces`, `DesignSystem` e `Extensions` — nunca de `Domain` concreto.

Regra: mesma do `Home` — não importa nenhum outro module de tela. O coordinator só recebe actions e navega; ele não conhece nem retém ViewModels. Ao terminar a animação, chama `parentCoordinator?.handle(CloseFlowAction())` (sinal genérico de `GeneralInterfaces`), nunca uma action própria — nem `Launcher` pode importar o app target pra referenciar `AppAction`, nem o coordinator pai deveria importar `Launcher` só pra reconhecer uma action específica.

Testar: `xcodebuild -project Abacaxi.xcodeproj -scheme LauncherTests -destination 'platform=iOS Simulator,name=iPhone 16' test`, ou `Scripts/on-write-code-check.sh Modules/Launcher/Tests/LauncherTests/<arquivo>.swift`.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
