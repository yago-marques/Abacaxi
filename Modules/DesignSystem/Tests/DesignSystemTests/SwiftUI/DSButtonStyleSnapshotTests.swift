import SwiftUI
import XCTest
@testable import DesignSystem

final class DSButtonStyleSnapshotTests: DSSnapshotTestCase {
    func test_primaryVariant_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(style: .dsPrimary), height: 72)
    }

    func test_secondaryVariant_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(style: .dsSecondary), height: 72)
    }

    func test_textVariant_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(style: .dsText), height: 72)
    }

    func test_destructiveVariant_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(style: .dsDestructive), height: 72)
    }

    func test_primaryVariant_withAccessibilityTextSize_matchesReference() {
        assertSwiftUISnapshot(
            of: makeSUT(style: .dsPrimary),
            height: 160,
            sizeCategory: .accessibilityExtraExtraExtraLarge
        )
    }
}

private extension DSButtonStyleSnapshotTests {
    func makeSUT(style: DSButtonStyle) -> some View {
        Button("Continuar") {}
            .buttonStyle(style)
            .padding(DSSpacing.small)
    }
}
