import UIKit
import XCTest
@testable import DesignSystem

final class DSCardViewSnapshotTests: DSSnapshotTestCase {
    func test_darkTheme_withoutImage_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(), width: 350)
    }

    func test_lightTheme_withoutImage_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(theme: .light), width: 350)
    }

    func test_compactImage_withChevron_matchesReference() {
        let sut = makeSUT(image: makeSolidImage(), mediaSize: .compact, showsChevron: true)

        assertUIKitSnapshot(of: sut, width: 350)
    }

    func test_regularImage_matchesReference() {
        assertUIKitSnapshot(of: makeSUT(image: makeSolidImage()), width: 350)
    }
}

private extension DSCardViewSnapshotTests {
    typealias SUT = DSCardView

    func makeSUT(
        image: UIImage? = nil,
        mediaSize: DSCardView.MediaSize = .regular,
        showsChevron: Bool = false,
        theme: DSCardView.Theme = .dark
    ) -> SUT {
        DSCardView(
            image: image,
            mediaSize: mediaSize,
            showsChevron: showsChevron,
            title: "Criar receita",
            description: "Escolha os ingredientes e deixe o resto com a gente",
            theme: theme
        )
    }
}
