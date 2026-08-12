# DesignSystem

Biblioteca visual compartilhada pelas telas UIKit e SwiftUI. Expõe tokens (cor, tipografia, espaçamento e bordas) e componentes sem regra de negócio ou dependência de feature.

Para cada decisão visual, prefira token do `DSColor`, `DSSpacing`, `DSBorder` ou `DSTypography`; não replique valores literais em features. Componentes UIKit usam prefixo `DS`; em SwiftUI, os controles seguem a mesma linguagem através de `DSButtonStyle`, `DSTextFieldView` e `DSCard`.

Testar: o pacote usa UIKit/SwiftUI e deve ser validado pelo projeto Xcode, com destino de simulador iOS.
