# DesignSystem

Biblioteca visual compartilhada pelas telas UIKit e SwiftUI. Expõe tokens (cor, tipografia, espaçamento e bordas) e componentes sem regra de negócio ou dependência de feature.

Para cada decisão visual, prefira token do `DSColor`, `DSSpacing`, `DSBorder` ou `DSTypography`; não replique valores literais em features. Componentes UIKit usam prefixo `DS`; em SwiftUI, os controles seguem a mesma linguagem através de `DSButtonStyle`, `DSTextFieldView` e `DSCard`.

Testar: o pacote usa UIKit/SwiftUI e deve ser validado pelo projeto Xcode, com destino de simulador iOS.

Snapshots: os componentes têm testes de snapshot (`*SnapshotTests`, base `DSSnapshotTestCase`) que só executam com `SNAPSHOT_TESTS=1` — fora do ambiente canônico (pipeline `snapshot.yml`: iPhone 16, iOS 18.5, Xcode 16.4) eles dão skip, para nunca falhar por divergência de simulador. Referências vivem em `__Snapshots__/` e são (re)gravadas exclusivamente pela pipeline em modo record (workflow_dispatch → artifact → commit). Ao criar componente novo, adicione o snapshot de cada variante visual.
