import DomainInterfaces
import XCTest
@testable import Home

@MainActor
final class HomeViewModelTests: XCTestCase {
    func test_state_startsWithLoadingAttemptsAndHomeContent() {
        let (sut, _) = makeSUTAndDoubles()

        XCTAssertEqual(sut.state.title, "Abacaxi")
        XCTAssertEqual(sut.state.dailyAttemptsText, "Carregando tentativas")
        XCTAssertEqual(sut.state.recipeCreationCardTitle, "Gerar nova receita")
        XCTAssertEqual(
            sut.state.recipeCreationCardSubtitle,
            "Crie uma receita personalizada com os ingredientes que você tem em casa."
        )
    }

    func test_load_whenAttemptsAreAvailable_updatesTheDisplayedRemainingCount() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getRemainingAttemptsUseCase.stubbedResult = .success(
            RemainingAttempts(remaining: 17, limit: 20, windowSeconds: 3_600)
        )

        await sut.load()

        XCTAssertEqual(sut.state.dailyAttemptsText, "17 tentativas hoje")
    }

    func test_load_whenSavedRecipesExist_showsTheSavedRecipesShortcut() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.hasSavedRecipesUseCase.stubbedResult = .success(true)

        await sut.load()

        XCTAssertTrue(sut.state.showsSavedRecipesShortcut)
    }

    func test_load_whenSavedRecipesDoNotExist_hidesTheSavedRecipesShortcut() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.hasSavedRecipesUseCase.stubbedResult = .success(false)

        await sut.load()

        XCTAssertFalse(sut.state.showsSavedRecipesShortcut)
    }

    func test_load_whenAttemptsAreUnavailable_updatesTheUnavailableState() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getRemainingAttemptsUseCase.stubbedResult = .failure(StubbedError.unavailable)

        await sut.load()

        XCTAssertEqual(sut.state.dailyAttemptsText, "Tentativas indisponíveis")
    }
}

private extension HomeViewModelTests {
    private typealias SUT = HomeViewModel
    private typealias Doubles = (
        getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseStub,
        hasSavedRecipesUseCase: HasSavedRecipesUseCaseStub
    )

    private enum StubbedError: Error {
        case unavailable
    }

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let getRemainingAttemptsUseCase = GetRemainingAttemptsUseCaseStub()
        let hasSavedRecipesUseCase = HasSavedRecipesUseCaseStub()
        let sut = HomeViewModel(
            getRemainingAttemptsUseCase: getRemainingAttemptsUseCase,
            hasSavedRecipesUseCase: hasSavedRecipesUseCase
        )
        return (sut, (getRemainingAttemptsUseCase, hasSavedRecipesUseCase))
    }
}
