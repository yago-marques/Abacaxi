# Network

Implementação concreta de rede: `URLSessionHTTPClient`, `DefaultHeadersProvider`, `ConsoleRequestLogger`, `NetworkConfiguration`. Depende só de `NetworkInterfaces`.

Regra: não importa `Home`, `GeneralInterfaces`, `Persistence` nem nenhum outro module de tela/feature. Módulo de infra pura.

Testar: `cd Modules/Network && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
