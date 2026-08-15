# Regras de Testes

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

## Test targets e coverage

Cada módulo com testes tem um bundle dedicado no `project.yml` (`HomeTests`, `NetworkTests`, etc.) que usa as mesmas fontes em `Modules/<Module>/Tests`; não duplique testes em outro diretório. A execução tem dois runtimes: módulos de lógica pura que declaram `.macOS` no `Package.swift` (interfaces, `Domain`, `Data`, `Network`) rodam nativamente via `swift test`, sem simulador; os demais (UIKit/SwiftUI e `Persistence`, que usa Keychain real via test host) rodam por `xcodebuild test` no simulador. Declarar `.macOS` no manifest é o opt-in do runtime nativo — se um módulo passar a depender de comportamento exclusivo de iOS, remova a plataforma do manifest. O scheme agregador `AllTests` executa todos os bundles de uma vez no simulador (é a rede de fidelidade dos pushes no `main`) e é usado por `Scripts/on-write-code-check.sh` sem argumentos. Módulos sem diretório `Tests` são apenas compilados pelo hook e devem ganhar um test target junto do primeiro teste.
