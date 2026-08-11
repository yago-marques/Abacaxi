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
