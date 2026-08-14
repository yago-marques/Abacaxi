import DataInterfaces
import PersistenceInterfaces
import XCTest
@testable import Data

final class OnboardingRepositoryTests: XCTestCase {
    func test_hasCompletedOnboarding_whenNothingStored_returnsFalse() {
        let (sut, _) = makeSUTAndDoubles()

        XCTAssertFalse(sut.hasCompletedOnboarding())
    }

    func test_hasCompletedOnboarding_afterCompleteOnboarding_returnsTrue() {
        let (sut, _) = makeSUTAndDoubles()

        sut.completeOnboarding()

        XCTAssertTrue(sut.hasCompletedOnboarding())
    }

    func test_completeOnboarding_persistsForNewInstanceSharingTheStore() {
        let (sut, doubles) = makeSUTAndDoubles()
        sut.completeOnboarding()

        let newInstance = OnboardingRepository(keyValueStore: doubles)

        XCTAssertTrue(newInstance.hasCompletedOnboarding())
    }
}

private extension OnboardingRepositoryTests {
    func makeSUTAndDoubles() -> (sut: OnboardingRepository, doubles: KeyValueStoringStub) {
        let keyValueStore = KeyValueStoringStub()
        return (OnboardingRepository(keyValueStore: keyValueStore), keyValueStore)
    }
}
