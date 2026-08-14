---
name: new-screen
description: Cria uma tela nova seguindo o stack correto do repositório — SwiftUI (padrão Recipe) para fluxos novos, UIKit MVVM-C + ViewCoding (padrão Home) ao estender fluxos UIKit existentes. Cobre ViewModel, estado, feedback tipado, navegação via coordinator e testes. Não prescreve layout visual — só os contratos estruturais.
---

# new-screen

O repositório mantém dois stacks de UI **deliberadamente** (decisão documentada no README).
Regra de escolha: fluxo novo → SwiftUI; tela dentro de fluxo UIKit existente → UIKit.
Leia `.claude/CODE_RULES/40-uikit.md` e `20-swift.md` antes. Layout/hierarquia visual são
decisão de design caso a caso — esta skill padroniza estado, feedback, navegação e testes.

## Trilha SwiftUI (golden path: IngredientPicker)

Referências: `Modules/Recipe/Sources/Recipe/Creation/IngredientPicker/IngredientPickerView.swift`,
`IngredientPickerViewModel.swift` e `IngredientPickerViewModelTests.swift` (o conjunto canônico);
para orquestração de fluxo/rotas: `RecipeFlowViewModel.swift` + `RecipeFlowViewModelTests.swift`.

1. **ViewModel**: `@MainActor final class <Nome>ViewModel: ObservableObject`, estado em
   `@Published private(set)`, use cases injetados por init (nunca o container).
2. **Feedback tipado**: `struct <Nome>Feedback: Identifiable { enum Kind }` publicado pelo VM;
   a View observa `.onChange(of: viewModel.feedback?.id)` e mapeia `Kind → L10n` no toast do DS.
   O VM **nunca** carrega texto — só casos. Cancelamento (`.cancelled`/`CancellationError`)
   volta ao estado neutro **sem** feedback.
3. **Trabalho async**: `Task` guardada em propriedade (`private(set) var` no VM ou `@State` na
   View), cancelada em `onDisappear`/`deinit`. Erros de domínio capturados por caso; `catch`
   genérico só como último recurso com feedback `requestFailed`-like.
4. **Navegação**: rotas num enum `Hashable` + `NavigationStack(path:)` tipado no VM de fluxo;
   saída do fluxo via closure `onFinish` fornecida pelo coordinator (nunca import de outra feature).
5. **Strings**: chaves novas em `Resources/Base.lproj/Localizable.strings` + entrada manual em
   `Resources/Generated/L10n.swift` (até o próximo `make generate-localizations` regenerar).
6. **Testes**: Swift Testing — `@MainActor struct <Nome>ViewModelTests`, `@Test`, `#expect`,
   `makeSUTAndDoubles()` em extension privada com defaults válidos. Cubra: estados de sucesso,
   cada braço de feedback (parametrizado), cancelamento silencioso, reentrância se houver guard.

## Trilha UIKit (golden path: Home)

Referências: `Modules/Home/Sources/Home/HomeViewController.swift`, `HomeViewModel.swift`,
`HomeCoordinator.swift` e `HomeViewModelTests.swift`.

1. **ViewModel**: protocolo `@MainActor <Nome>ViewModelProtocol: AnyObject` + classe `@MainActor`
   concreta; estado num `struct <Nome>ViewState: Equatable` imutável; coordinator `weak`.
2. **ViewController**: conforma `ViewCoding` (`setupView`/`setupHierarchy`/`setupConstraints`);
   subviews `lazy` usando tokens do DS; constraints pelos helpers de `Extensions`.
   Task de carga guardada (`private var loadTask: Task<Void, Never>?`) e cancelada em `deinit`.
3. **Acessibilidade** em todo elemento tocável não-nativo (view + tap gesture):
   `isAccessibilityElement = true`, `accessibilityTraits = .button`, `accessibilityLabel`
   com o texto do estado.
4. **Navegação**: VC → VM (`didTap...`) → `coordinator?.handle(<Feature>Action.case)`;
   o coordinator resolve a factory. Cross-feature via router protocol com `onFinish`
   propagado ao pai (exemplo: `HomeExternalRouterProtocol` + teste de desalocação em
   `HomeCoordinatorTests`).
5. **Testes**: XCTest — `@MainActor final class ...Tests: XCTestCase`, `makeSUTAndDoubles`,
   spy de coordinator assertando a action recebida; para coordinators, inclua teste de
   desalocação do child (`weak var` + `XCTAssertNil` após onFinish).

## Validação

- Hook roda lint + testes do módulo a cada arquivo salvo — não avance com `** TEST FAILED **`.
- Arquivo de teste novo exige `make generate` para entrar no build (XcodeGen).
- `make lint-strict` limpo antes de encerrar (o CI trata warning como erro).
