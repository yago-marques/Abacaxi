# Code Rules

As convenções do repositório são organizadas por domínio. Cada regra normativa vive em um único documento.

| Documento | Quando consultar |
| --- | --- |
| `10-testing.md` | Testes, doubles, test targets e coverage. |
| `20-swift.md` | Erros, comentários, formatação, protocolos, acesso entre módulos e Swift Testing. |
| `30-architecture.md` | Composição, MVVM, coordinators, factories, camadas e modelos. |
| `40-uikit.md` | Textos de interface, UIKit, layout, constraints e animações. |
| `50-validation.md` | Hook pós-escrita, lint e execução dos testes. |

## Roteamento do hook

`Scripts/on-write-code-check.sh <arquivo>` mostra este índice e as regras relevantes ao arquivo alterado:

- arquivos em `Tests/`: testes, Swift e validação;
- arquivos de apresentação ou que importam UIKit/SwiftUI: Swift, arquitetura, UIKit e validação;
- demais arquivos Swift: Swift, arquitetura e validação.

Sem argumento, o hook executa `AllTests` e mostra todos os documentos para uma revisão completa.
