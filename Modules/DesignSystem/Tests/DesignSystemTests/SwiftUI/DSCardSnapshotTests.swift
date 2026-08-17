import SwiftUI
import XCTest
@testable import DesignSystem

final class DSCardSnapshotTests: DSSnapshotTestCase {
    func test_darkTheme_withoutContent_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(), height: 160)
    }

    func test_lightTheme_withMediaContent_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(theme: .light, mediaHeight: 120), height: 300)
    }

    func test_darkTheme_withAccessibilityTextSize_matchesReference() {
        assertSwiftUISnapshot(
            of: makeSUT(),
            height: 320,
            sizeCategory: .accessibilityExtraExtraExtraLarge
        )
    }
}

private extension DSCardSnapshotTests {
    func makeSUT(theme: DSCard<AnyView>.Theme = .dark, mediaHeight: CGFloat? = nil) -> some View {
        DSCard(
            title: "Criar receita",
            description: "Escolha os ingredientes e deixe o resto com a gente",
            theme: theme
        ) {
            AnyView(mediaContent(height: mediaHeight))
        }
        .padding(DSSpacing.small)
    }

    @ViewBuilder
    func mediaContent(height: CGFloat?) -> some View {
        if let height {
            Color.dsAccent.frame(height: height)
        } else {
            EmptyView()
        }
    }
}
