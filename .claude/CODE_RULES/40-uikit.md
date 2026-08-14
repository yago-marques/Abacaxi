# Regras de UIKit e Interface

## Strings de interface

Todo texto exibido por uma tela deve ficar no `Localizable.strings` do próprio módulo — nunca como literal em arquivo Swift. Use o `L10n` gerado pelo SwiftGen para acessar as chaves tipadas.

```swift
titleLabel.text = L10n.Onboarding.headline
```

O arquivo gerado em `Resources/Generated/L10n.swift` não é versionado. Depois de alterar uma string, execute `make generate-localizations` (ou `make start`) para regenerá-lo.

## Layout UIKit

Em telas UIKit programáticas, use `ViewCoding` para compor a view: chame `buildLayout()` em `viewDidLoad` e separe a implementação em `setupView`, `setupHierarchy` e `setupConstraints`.

Declare elementos visuais como `private lazy var` sempre que possível. Configure o elemento dentro da própria closure; isso mantém a declaração, configuração e ciclo de vida no mesmo lugar. Use `let` somente quando o elemento não precisar de configuração adiada nem de referência a `self`.

ViewControllers dependem do protocolo do seu ViewModel, nunca do tipo concreto. Declare esse protocolo no próprio arquivo do ViewModel, logo abaixo dos imports e antes da implementação concreta, seguindo a mesma convenção das factories simples de Use Case e Repository.

```swift
public protocol OnboardingViewModelProtocol {
    func start()
    func didTapStart()
}

public final class OnboardingViewModel: OnboardingViewModelProtocol {
    // ...
}

public final class OnboardingViewController: UIViewController {
    private let viewModel: OnboardingViewModelProtocol
}
```

Use os facilitadores de `Extensions/Constraints` em vez de declarar `NSLayoutConstraint` diretamente. Importe `Extensions`, adicione views com `addSubviews` e prefira as constraints encadeáveis (`top`, `bottom`, `leading`, `trailing`, `centerX`, `centerY`, `width`, `height`).

Para animações e transições UIKit, use os facilitadores de `Extensions/Animations`: `view.animate { }`, `view.animate(.slowEaseIn) { }`, `view.transition(.crossDissolve) { }` e `view.pulse()`. Os tipos `UIViewAnimation` e `UIViewTransition` encapsulam duração, curva e opções do UIKit; telas e coordinators não declaram `UIView.AnimationOptions` diretamente, nem replicam `UIView.animate`, `UIView.transition` ou grupos de `CAAnimation`.

```swift
view.addSubviews(
    titleLabel,
    actionButton
)

titleLabel.centerX(to: view.centerXAnchor).centerY(to: view.centerYAnchor)
actionButton.leading(to: view.layoutMarginsGuide.leadingAnchor)
    .trailing(to: view.layoutMarginsGuide.trailingAnchor)
    .bottom(to: view.safeAreaLayoutGuide.bottomAnchor, constant: -DSSpacing.large)
```

As extensions ativam as constraints imediatamente e substituem o uso de `NSLayoutConstraint.activate` nas ViewControllers. Em `setupConstraints`, agrupe cada cadeia pelo elemento que está sendo posicionado, com uma linha em branco entre elementos — nunca misture constraints de várias views no mesmo bloco.

Em `setupHierarchy`, use `view.addSubview(element)` quando houver um único elemento. Para duas ou mais subviews, use `view.addSubviews` com um elemento por linha e o parêntese de fechamento isolado.

```swift
public func setupHierarchy() {
    view.addSubviews(
        brandImageView,
        pineappleImageView,
        headlineLabel,
        startButton
    )
}
```

```swift
public func setupConstraints() {
    brandImageView
        .top(to: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.small)
        .centerX(to: view.centerXAnchor)
        .width(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.80)
        .height(76)

    headlineLabel
        .top(to: brandImageView.bottomAnchor, constant: DSSpacing.large)
        .leading(to: view.layoutMarginsGuide.leadingAnchor)
        .trailing(to: view.layoutMarginsGuide.trailingAnchor)
}
```
