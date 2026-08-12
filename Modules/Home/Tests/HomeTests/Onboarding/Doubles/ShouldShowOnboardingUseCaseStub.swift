import DomainInterfaces

final class ShouldShowOnboardingUseCaseStub: ShouldShowOnboardingUseCaseProtocol {
    var executeReturn = true

    func execute() -> Bool {
        executeReturn
    }
}
