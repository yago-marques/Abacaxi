---
name: new-ds-component
description: Cria um componente novo no DesignSystem (SwiftUI, UIKit ou ambos) usando só tokens, com acessibilidade embutida (alvo 44pt, Dynamic Type, traits), textos por parâmetro e teste de apresentação quando houver estado. Use para qualquer view/estilo reutilizável; não use para views específicas de uma feature (essas moram no módulo da feature).
---

# new-ds-component

Componentes do DS são a única fonte de aparência do app — tudo neles sai de tokens.
Referências canônicas: `DSButtonStyle.swift` (estilo SwiftUI com variantes),
`DSCardView.swift` (componente UIKit), e os testes de `DSToastPresentation`
(componente com estado + corrida resolvida por request ID — o padrão de teste a espelhar).

## Regras estruturais

1. **Um tipo público por arquivo, nomeado pelo arquivo.** O anti-exemplo a NÃO repetir é
   `DSIngredientControls.swift` (13 tipos num arquivo) — está na fila de refatoração, não o use
   como referência de organização.
2. **Só tokens**: cores por `DSColor`/`Color.ds*`, fontes por `DSTypography`/`Font.ds*`
   (já escalam com Dynamic Type — nunca `Font.system(size:)` direto), espaçamento por
   `DSSpacing`, borda por `DSBorder`. Nenhum literal de cor/tamanho/fonte.
3. **Textos por parâmetro.** O DS não tem L10n próprio; qualquer string user-facing (inclusive
   `accessibilityLabel`) chega por init/parametro do consumidor. Anti-exemplo: o `"Voltar"`
   hardcoded que já existiu no DS.
4. **UIKit e SwiftUI**: se o componente será usado nos dois stacks, forneça as duas variantes
   no mesmo padrão de nome (`DSXView` UIKit / `DSX` SwiftUI) em arquivos separados.

## Checklist de acessibilidade (obrigatório)

- **Alvo de toque ≥ 44x44pt**: visual pode ser menor; expanda o hit area com
  `.frame(minWidth: 44, minHeight: 44)` + `.contentShape(Rectangle())` (SwiftUI — ver
  `DSIconButton`) ou `point(inside:with:)`/constraints (UIKit).
- **Dynamic Type**: use os tokens (já escalam). Se criar variação tipográfica nova, adicione
  o token em `DSTypography` com `UIFontMetrics`/`Font(DSTypography...)` — não crie fonte local.
- **Traits e rótulos**: elemento acionável expõe `.button` (UIKit: `accessibilityTraits`;
  SwiftUI: `Button` nativo já expõe) e rótulo significativo vindo por parâmetro.
- **Estados anunciáveis**: componente com estado visual (selecionado, loading) reflete isso em
  `accessibilityValue`/`accessibilityHint` quando o visual sozinho não comunica.

## Testes

- Componente **com estado ou lógica de apresentação** (toast, sheet, progress): teste de
  comportamento observável espelhando `DSToastPresentationTests` — sem sleeps, estados por
  request/ID quando houver corrida possível.
- Componente puramente visual: sem teste obrigatório (não crie teste sem comportamento
  observável só por cobertura — regra do `CODE_RULES/10-testing.md`).

## Validação

- Hook roda lint + `DesignSystemTests` a cada arquivo salvo.
- `make lint-strict` limpo (regras `file_name`/nesting valem aqui).
- Se o componente substitui um existente, remova o antigo e todos os call sites — o DS não
  acumula variantes mortas (havia `DSCard`, `DSTextField` etc. mortos na fila de poda).
