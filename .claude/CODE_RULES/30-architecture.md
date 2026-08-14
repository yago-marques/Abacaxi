# Regras de Arquitetura

## MVVM, coordinators e factories

### Organização da composição do app

Em `AbacaxiApp/Modules`, organize cada domínio de composição assim:

```text
Modules/
  Home/
    Builders/
      <UseCase>Builder.swift
    HomeModule.swift
  Launcher/
    Builders/
      <UseCase>Builder.swift
    LauncherModule.swift
  Recipe/
    RecipeModule.swift
  Shared/
    <Infra>Builder.swift
```

`<Feature>Module.swift` é a única porta do domínio na composição do app: registra dependências e/ou inicia o fluxo. Builders específicos ficam em `Builders/`; builders compartilhados de infraestrutura ficam em `Shared/`. Não misture builders de feature diretamente ao lado de seu `Module` nem coloque builders de um domínio dentro de outro.

### Coordinator

Coordinator cuida exclusivamente de navegação: recebe actions e apresenta, empilha ou substitui telas. Não contém regras de negócio, consulta storage, decide estado de primeiro acesso ou guarda ViewModels.

Um módulo de tela nunca importa nem inicia diretamente outro módulo de tela. A camada de composição do app (`AbacaxiApp/Modules/<Feature>/<Feature>Module`) expõe `start(...)`, monta o coordinator do próprio package e injeta callbacks de transição. `CoordinatorProtocol` não tem `parentCoordinator`; use callbacks explícitos para qualquer saída ou transição entre módulos.

Para uma única saída externa, injete uma closure. Quando um coordinator tiver duas ou mais saídas externas coesas, declare um protocolo público e específico do módulo, como `HomeExternalRouterProtocol`, no próprio package. O coordinator depende desse protocolo e chama métodos diretos (`externalRouter.openRecipeCreation()`); a implementação concreta fica em `AbacaxiApp/Modules/<Feature>/`, onde pode iniciar módulos vizinhos. Não crie routers globais ou genéricos.

```swift
enum RecipeModule {
    static func start(navigationController: UINavigationController) -> CoordinatorProtocol { ... }
}

// Na composição de Home:
onOpenRecipeCreation: {
    RecipeModule.start(navigationController: navigationController)
}
```

Para fluxos que apenas encerram, injete `onFinish` pela factory/coordinator. Não use uma action genérica como `CloseFlowAction`: o destino de um término é uma decisão da composição, não um evento global.

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

### Receita gerada e salvamento local

Para o domínio Recipe, resultados remotos são `BusinessModels` de `DomainInterfaces`; a apresentação os converte em modelos próprios quando precisar de estado de UI. Request/response models da API continuam privados em `Data`.

Salvar uma receita é sempre uma ação explícita do usuário, chamada por `SaveRecipeUseCaseProtocol`. O repository concreto em `Data` depende de `PersistentStoringProtocol` e `RecipeImageStoringProtocol`, nunca de `Persistence` concreto. Core Data armazena metadados estruturados e o caminho da imagem; bytes/base64 da imagem ficam em arquivo no diretório do app, nunca no banco.

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

### Modelos e mappers entre camadas

Toda feature que atravessa Presentation, Domain e Data separa seus modelos por responsabilidade:

- `PresentationModel`: estado e identidade necessários à UI (por exemplo `Identifiable`); é interno à feature e não conforma com `Codable` para atender a API.
- `BusinessModel`: entrada e saída de Use Cases e repositories; fica em `DomainInterfaces`, não conhece SwiftUI, persistência ou transporte.
- `RemoteModel`: request `Encodable` e response/error `Decodable`; é privado de `Data` e representa o contrato HTTP, inclusive literals e `CodingKeys` específicos da API.

Os mappers ficam na fronteira que os usa: o ViewModel mapeia `PresentationModel → BusinessModel`; o repository em Data mapeia `BusinessModel → RequestRemoteModel` e `ResponseRemoteModel → BusinessModel`. Nunca envie um PresentationModel ao Use Case, nem exponha um RemoteModel em protocolos de Domain/DataInterfaces ou na apresentação.

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
