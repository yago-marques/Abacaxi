# Abacaxi (app target)

`CompositionRoot` monta o object graph do app: um `UseCaseContainer` compartilhado, as module factories (`LauncherModule`, `HomeModule`, em `Sources/AbacaxiApp/Modules/`) — cada uma registra suas próprias dependências — e `AppCoordinator`.

Regra: as module factories e builders em `Sources/AbacaxiApp/Modules/` são os únicos lugares do app permitidos a importar implementação concreta de outro module (`Persistence`, `Network`, `Domain`, `Data`, `Home`, `Launcher`) — é o composition root fazendo seu trabalho. `Modules/Shared` contém builders compartilhados de infraestrutura; cada use case builder devolve seu use case pronto. `AppCoordinator` importa só `GeneralInterfaces`; módulos de tela (`Home`, `Launcher`) importam só `*Interfaces`. Não espalhar imports concretos pra fora de `Sources/AbacaxiApp/Modules/`.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
