# Home

Primeira tela do app: `HomeCoordinator` + `HomeViewController` (placeholder) + `HomeAction`. Depende só de `GeneralInterfaces`.

Regra: não importa nenhum outro module de tela. Se `HomeCoordinator` precisar acionar um fluxo de outro module (ex: Auth), isso sobe pro coordinator pai (`AppCoordinator`, no app target) via `parentCoordinator?.handle(_:)` — nunca importando o module de destino direto.

Testar: `cd Modules/Home && swift test` **não funciona** — módulo usa UIKit (`HomeViewController`, `UINavigationController`). Mesma limitação do `GeneralInterfaces`: roda via Xcode (Cmd+U), não via CLI.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
