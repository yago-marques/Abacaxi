# Regras de Validação

Depois de alterar qualquer arquivo Swift, execute `Scripts/on-write-code-check.sh <arquivo>`. O script falha quando o lint ou os testes do módulo falham. Para validar todas as suítes antes de entregar, rode `Scripts/on-write-code-check.sh` sem argumentos.

O hook linta apenas o módulo do arquivo alterado e executa os testes dele pelo runtime adequado: `swift test` nativo (sem simulador) quando o `Package.swift` do módulo declara `.macOS`; `xcodebuild test` no simulador para módulos UIKit/SwiftUI e para o `Persistence`. Sem argumento, executa o scheme agregador `AllTests` no simulador, que roda todos os test targets e coleta coverage.

Depois da validação, revise o índice e os documentos de regras que o hook exibir para o contexto do arquivo alterado.
