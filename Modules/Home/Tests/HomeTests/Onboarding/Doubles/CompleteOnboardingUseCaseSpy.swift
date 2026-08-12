import DomainInterfaces

final class CompleteOnboardingUseCaseSpy: CompleteOnboardingUseCaseProtocol {
    private(set) var executeCalled = false

    func execute() {
        executeCalled = true
    }
}
