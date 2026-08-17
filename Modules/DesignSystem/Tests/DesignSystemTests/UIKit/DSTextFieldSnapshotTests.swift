import UIKit
import XCTest
@testable import DesignSystem

final class DSTextFieldSnapshotTests: DSSnapshotTestCase {
    func test_placeholder_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(), width: 320)
    }

    func test_withLeadingIcon_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(systemImageName: "magnifyingglass"), width: 320)
    }

    func test_withText_matchesReference() {
        let sut = makeSUT()
        sut.text = "Abacaxi"

        assertUIKitSnapshot(of: sut, width: 320)
    }
}

private extension DSTextFieldSnapshotTests {
    typealias SUT = DSTextField

    func makeSUT(systemImageName: String? = nil) -> SUT {
        DSTextField(placeholder: "Buscar receita", systemImageName: systemImageName)
    }
}
