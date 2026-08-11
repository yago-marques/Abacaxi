# GeneralInterfaces

Protocolo de navegação: `Coordinator` (`navigationController`, `start()`, `handle(_:)`) e `CoordinatorAction` (marker). Zero dependências locais — importa só UIKit.

Regra: todo module de tela (`Home`, e os que vierem depois) conforma `Coordinator` daqui. Nada aqui sabe de nenhum module de tela específico.

Testar: `cd Modules/GeneralInterfaces && swift test` **não funciona** — o módulo importa UIKit (por causa de `navigationController` no protocol), e o SDK de macOS usado pelo `swift test` da linha de comando não tem UIKit. Rodar via Xcode (Cmd+U) depois de `File > Packages > Resolve Package Versions`. `xcodebuild test` no scheme do package também não funciona (scheme gerado não vem configurado pra test action, e isso não dá pra configurar via `project.yml`/XcodeGen).

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_STYLE.md`.
