import UIKit
import XCTest
@testable import DesignSystem

final class DSButtonSnapshotTests: DSSnapshotTestCase {
    func test_primaryStyle_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(style: .primary), width: 320)
    }

    func test_secondaryStyle_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(style: .secondary), width: 320)
    }

    func test_textStyle_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(style: .text), width: 320)
    }

    func test_primaryStyle_whenHighlighted_matchesReference() {
        let sut = makeSUT(style: .primary)
        sut.isHighlighted = true

        assertUIKitSnapshot(of: sut, width: 320)
    }
}

private extension DSButtonSnapshotTests {
    typealias SUT = DSButton

    func makeSUT(style: DSButton.Style) -> SUT {
        DSButton(title: "Continuar", style: style)
    }
}
