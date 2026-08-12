import XCTest
@testable import GeneralInterfaces

final class UseCaseContainerTests: XCTestCase {
    private protocol SomeUseCase: AnyObject {}
    private final class SomeUseCaseStub: SomeUseCase {}

    func test_resolve_returnsTheRegisteredFactoryResult() {
        let sut = makeSUT()
        sut.register(SomeUseCase.self) { SomeUseCaseStub() }

        let resolved = sut.resolve(SomeUseCase.self)

        XCTAssertNotNil(resolved)
    }

    func test_resolve_forSingleton_returnsTheSameInstance() {
        let sut = makeSUT()
        sut.registerSingleton(SomeUseCase.self, instance: SomeUseCaseStub())

        let first = sut.resolve(SomeUseCase.self)
        let second = sut.resolve(SomeUseCase.self)

        XCTAssertTrue(first === second)
    }
}

private extension UseCaseContainerTests {
    func makeSUT() -> UseCaseContainer {
        UseCaseContainer()
    }
}
