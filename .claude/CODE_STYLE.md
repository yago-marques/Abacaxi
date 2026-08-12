# Code Style

## Estrutura de testes

Cada assunto testado ganha sua própria pasta dentro de `Tests/<Module>Tests/`, nomeada pelo tipo/feature sob teste:

```
Tests/<Module>Tests/
  <Feature>/
    <Feature>Tests.swift
    Doubles/                  (só existe se o teste usa duplos)
      <DoubleName>.swift
```

Exemplo real (`GeneralInterfaces`):
```
Tests/GeneralInterfacesTests/
  Coordinator/
    CoordinatorTests.swift
    Doubles/
      CoordinatorStub.swift
```

### Construindo o SUT

Toda classe de teste constrói o SUT (system under test) através de uma factory privada, nunca inline no corpo do teste.

**Sem duplos** — `private func makeSUT() -> SUT`:
```swift
private extension CoordinatorTests {
    private typealias SUT = CoordinatorStub

    private func makeSUT() -> SUT {
        CoordinatorStub()
    }
}
```

**Com duplos** — quando o SUT recebe dependências que precisam ser dubladas (mock/stub/spy), a factory vira `makeSUTAndDoubles()`, retorna a tupla `(SUT, Doubles)`, e a injeção acontece dentro dela:
```swift
private extension SomeTests {
    private typealias SUT = SomeConcreteType
    private typealias Doubles = (dependency: DependencyStub, otherDependency: OtherDependencyStub)

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let dependency = DependencyStub()
        let otherDependency = OtherDependencyStub()
        let sut = SomeConcreteType(dependency: dependency, otherDependency: otherDependency)
        return (sut, (dependency, otherDependency))
    }
}
```

Chamado assim no teste:
```swift
func test_something() {
    let (sut, doubles) = makeSUTAndDoubles()
    ...
}
```

Regra: se o teste não precisa de nenhum duplo, fica só `makeSUT()`. No momento em que precisar do primeiro duplo, migra pra `makeSUTAndDoubles()` — não mistura os dois estilos no mesmo arquivo.

### Nomeando duplos

Todo duplo de teste termina em `Mock`, `Stub` ou `Spy` — nunca fica sem sufixo (nada de `TestItem`, `FakeThing` etc.). Exemplos: `CoordinatorStub`, `KeyValueStoringStub`, `TestItemMock`, `TestItemManagedObjectMock`.

Tipos auxiliares que NÃO são duplos (factories/builders, ex: `TestItemModel` que monta container + store pra teste) não levam esse sufixo — o sufixo é só pra tipos que ficam no lugar de uma dependência real.

### Escopo e localização dos duplos

Um duplo usado por apenas uma feature fica junto dela, em `Tests/<Module>Tests/<Feature>/Doubles/`. Crie a pasta `Doubles/` somente quando houver ao menos um arquivo dentro; ela não deve permanecer vazia.

Quando o mesmo duplo representa uma colaboração do módulo e for útil a duas ou mais features/fluxos, ele fica em `Tests/<Module>Tests/SharedDoubles/`. O nome descreve o módulo, não a primeira tela que o usou. Por exemplo, `HomeCoordinatorSpy` pertence a `Tests/HomeTests/SharedDoubles/HomeCoordinatorSpy.swift`: ele registra `HomeAction` e pode ser reutilizado por Onboarding, HomeViewModel e novos fluxos de Home. Não crie variantes como `OnboardingCoordinatorSpy` para o mesmo coordinator do módulo.

Não mova para `SharedDoubles` por antecipação: enquanto houver um único consumidor, prefira o escopo da feature.

### Qualidade e comportamento dos testes

Todo teste deve comprovar um comportamento observável — valor retornado, estado público, efeito na dependência ou erro — e não detalhes privados de implementação. Use o nome `test_<método>_when<condição>_<resultado>` quando houver condição; omita `when` quando o comportamento já for direto.

Mantenha o teste em Arrange–Act–Assert, com uma linha em branco entre as etapas. A factory do SUT cria as dependências com defaults válidos; cada teste sobrescreve somente o dado necessário ao cenário. Para falhas de teste, declare um `enum` local conformando `Error` e use casos explícitos, nunca uma `struct` vazia.

Teste os caminhos relevantes de sucesso, falha e ausência/limite quando o tipo os expõe. Para spies, verifique a action ou chamada recebida; para stubs, configure a resposta de entrada. Não adicione teste de implementação sem comportamento observável apenas para aumentar cobertura.

### Validação obrigatória antes de entregar

Depois de alterar qualquer arquivo Swift, execute `Scripts/on-write-code-check.sh <arquivo>`. O script falha quando o lint ou o test target iOS do módulo falha. Para validar todas as suítes antes de entregar, rode `Scripts/on-write-code-check.sh` sem argumentos.

Cada módulo com testes tem um bundle dedicado no `project.yml` (`HomeTests`, `NetworkTests`, etc.) que usa as mesmas fontes em `Modules/<Module>/Tests`; não duplique testes em outro diretório. Esses bundles são executados por `xcodebuild test` no simulador. Módulos sem diretório `Tests` são apenas compilados pelo hook e devem ganhar um test target junto do primeiro teste.

## Erros

Todo erro lançado (`throws`) é um `enum` conformando `Error`, nunca `struct`. Cada caso de falha vira um `case`, com dado associado quando fizer sentido (ex: código de status, nome da entidade).

```swift
public enum KeychainError: Error {
    case missingBundleIdentifier
    case unhandledStatus(OSStatus)
}
```

Motivo: várias formas de falhar dentro do mesmo domínio (Keychain, CoreData, rede) — um `enum` deixa isso exaustivo e faz o `switch` no chamador ser exaustivo também. `struct` força um tipo de erro por domínio inteiro, escondendo os casos possíveis.

## Quebra de linha

**Assinatura de método com muitos parâmetros**: um parâmetro por linha, parêntese de fechamento sozinho.

```swift
public init(
    container: NSPersistentContainer,
    entityName: String,
    idKeyPath: String,
    map: @escaping (Entity, ManagedObject) -> Void,
    toEntity: @escaping (ManagedObject) -> Entity
) {
```

**Chamada encadeada sobre retorno de função** (`data.join().find().use()`): cada chamada em linha própria, ponto alinhado.

```swift
let names = items
    .filter { $0.isActive }
    .map(\.name)
    .sorted()
```

Regra: se cabe legível numa linha só, fica numa linha só. Quebra quando a assinatura/cadeia passa de ~2-3 elementos ou estoura a largura legível — não é regra de contagem de caractere fixa, é legibilidade.

## Protocolos

Todo `protocol` termina em `Protocol`, sem exceção — `Coordinator` → `CoordinatorProtocol`, `HTTPClient` → `HTTPClientProtocol`, `KeyValueStoring` → `KeyValueStoringProtocol`. O tipo concreto que implementa NÃO leva o sufixo e mantém seu próprio nome descritivo (`HomeCoordinator`, `URLSessionHTTPClient`, `UserDefaultsStore` continuam iguais).

```swift
public protocol SecureStoringProtocol {
    func save(_ data: Data, forKey key: String) throws
}

public final class KeychainStore: SecureStoringProtocol { ... }
```

Motivo: deixa inequívoco na leitura da assinatura/import se algo é contrato (`Protocol`) ou implementação concreta — sem isso, nome do protocolo e nome do implementador ficam parecidos demais (`Coordinator` vs. `HomeCoordinator`) e confundem qual é qual.

## Strings de interface

Todo texto exibido por uma tela deve ficar no `Localizable.strings` do próprio módulo — nunca como literal em arquivo Swift. Use o `L10n` gerado pelo SwiftGen para acessar as chaves tipadas.

```swift
titleLabel.text = L10n.Onboarding.headline
```

O arquivo gerado em `Resources/Generated/L10n.swift` não é versionado. Depois de alterar uma string, execute `make generate-localizations` (ou `make start`) para regenerá-lo.

## MVVM, coordinators e factories

### Coordinator

Coordinator cuida exclusivamente de navegação: recebe actions e apresenta, empilha ou substitui telas. Não contém regras de negócio, consulta storage, decide estado de primeiro acesso ou guarda ViewModels.

As actions de coordinator são comandos de navegação no infinitivo: `openHome`, `openOnboarding`, `closeLauncher`, `backToProfile`. Evite estados e eventos no passado, como `didFinish`, `isLoggedIn` ou `onboardingCompleted`.

### Closures e ciclo de vida

Avalie retenção ao escrever closures. Quando a closure puder ser mantida por um objeto que `self` também retém — callbacks, observers, animações assíncronas, tasks e APIs que escapam a closure — capture `self` fracamente e trate sua ausência:

```swift
viewModel.onStateChange = { [weak self] state in
    self?.render(state)
}
```

Quando a closure só precisa de uma dependência local, use lista de captura explícita para não capturar `self` por acidente e para deixar a intenção visível:

```swift
navigationController.view.transition(.crossDissolve) { [homeCoordinator] in
    homeCoordinator.start()
}
```

Não use `[weak self]` por reflexo em closures síncronas e efêmeras que não capturam `self`; escolha a lista de captura conforme a relação de retenção real.

### ViewModel

ViewModel concentra regras de negócio e decisões de fluxo. Quando precisar navegar, chama `CoordinatorProtocol.handle(_:)` com uma action tipada do módulo; nunca instancia uma tela diretamente.

### Factory

Toda factory é um `enum` e expõe apenas métodos estáticos `make`. Factory monta dependências e retorna o objeto pronto para uso, mas não mantém estado. Quando uma tela precisar enviar actions ao coordinator, a factory injeta o `CoordinatorProtocol` na criação do ViewModel.

```swift
public enum OnboardingFactory {
    public static func makeViewController(
        useCaseContainer: UseCaseContainer,
        coordinator: CoordinatorProtocol
    ) -> UIViewController {
        let shouldShowOnboardingUseCase = useCaseContainer.resolve(ShouldShowOnboardingUseCaseProtocol.self)
        let completeOnboardingUseCase = useCaseContainer.resolve(CompleteOnboardingUseCaseProtocol.self)
        let viewModel = OnboardingViewModel(
            shouldShowOnboardingUseCase: shouldShowOnboardingUseCase,
            completeOnboardingUseCase: completeOnboardingUseCase,
            coordinator: coordinator
        )
        return OnboardingViewController(viewModel: viewModel)
    }
}
```

## Fronteiras de camadas

A camada de apresentação (View, ViewController, ViewModel, Coordinator e Factory de fluxo) não importa nem recebe tipos de `Persistence` ou `PersistenceInterfaces`.

Regras de negócio entram na apresentação somente por Use Cases definidos em `DomainInterfaces`. O Use Case depende de um repositório definido em `DataInterfaces`; a implementação concreta fica em `Data` e é a única camada que interage com `Persistence`/`PersistenceInterfaces`.

```text
Presentation → DomainInterfaces ← Domain → DataInterfaces ← Data → PersistenceInterfaces ← Persistence
```

Factory de fluxo resolve apenas protocolos de Use Case. A composição no app pode chamar builders de Use Case, que usam as factories de Domain e Data para montar o grafo de dependências.

Quando uma factory de fluxo precisa montar uma tela com ViewModel, ela recebe `UseCaseContainer`, resolve nela apenas protocolos de `DomainInterfaces` e injeta os Use Cases no ViewModel. Coordinator não resolve nem armazena Use Cases; ele chama a factory da tela passando o container e a si mesmo como `CoordinatorProtocol`.

```swift
public enum OnboardingFactory {
    public static func makeViewController(
        useCaseContainer: UseCaseContainer,
        coordinator: CoordinatorProtocol
    ) -> UIViewController {
        let shouldShowOnboardingUseCase = useCaseContainer.resolve(ShouldShowOnboardingUseCaseProtocol.self)
        let completeOnboardingUseCase = useCaseContainer.resolve(CompleteOnboardingUseCaseProtocol.self)
        let viewModel = OnboardingViewModel(
            shouldShowOnboardingUseCase: shouldShowOnboardingUseCase,
            completeOnboardingUseCase: completeOnboardingUseCase,
            coordinator: coordinator
        )
        return OnboardingViewController(viewModel: viewModel)
    }
}
```

### Direção das dependências

Cada camada conhece somente os contratos da camada imediatamente abaixo; implementações concretas não sobem para as camadas superiores.

```text
Presentation → DomainInterfaces
Domain       → DataInterfaces + DomainInterfaces
Data         → DataInterfaces + PersistenceInterfaces + NetworkInterfaces
Persistence  → PersistenceInterfaces
Network      → NetworkInterfaces
```

Presentation não importa `Domain`, `Data`, `Persistence` ou `Network`. Domain não importa Data, Persistence ou Network concretos. Data é a fronteira que implementa repositórios e pode usar os contratos de Persistence e Network.

### Organização por contexto

Dentro de `DataInterfaces`, `Data`, `DomainInterfaces` e `Domain`, arquivos são agrupados pelo contexto da funcionalidade, tanto em `Sources` quanto em `Tests`.

```text
Sources/<Módulo>/
  DeviceID/
  Onboarding/

Tests/<Módulo>Tests/
  DeviceID/
    Doubles/
  Onboarding/
    Doubles/
```

Não crie arquivos soltos na raiz de `Sources/<Módulo>` ou `Tests/<Módulo>Tests` quando eles pertencem a um contexto. Dublês ficam no `Doubles/` do mesmo contexto que os consome.

### Factories de Domain e Data

Em `Domain`, a factory simples de um Use Case fica no mesmo arquivo do Use Case. Em `Data`, a factory simples de um Repository fica no mesmo arquivo do Repository. Declare o `enum` da factory logo abaixo dos imports, antes do tipo concreto.

```swift
import DataInterfaces
import DomainInterfaces

public enum ShouldShowOnboardingUseCaseFactory {
    public static func make(repository: OnboardingRepositoryProtocol) -> ShouldShowOnboardingUseCaseProtocol {
        ShouldShowOnboardingUseCase(repository: repository)
    }
}

public final class ShouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseProtocol {
    // ...
}
```

Não crie arquivos exclusivos para essas factories quando elas só montam o tipo do mesmo arquivo.

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
