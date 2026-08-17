import SwiftUI
import XCTest
@testable import DesignSystem

final class DSTextFieldViewSnapshotTests: DSSnapshotTestCase {
    func test_placeholderOnly_matchesReference() {
        assertSwiftUISnapshot(of: makeSUT(), height: 84)
    }

    func test_withLabelIconAndText_matchesReference() {
        let sut = makeSUT(text: "Abacaxi", label: "Ingrediente", systemImageName: "carrot")

        assertSwiftUISnapshot(of: sut, height: 120)
    }

    func test_searchField_empty_matchesReference() {
        assertSwiftUISnapshot(of: makeSearchSUT(), height: 84)
    }

    func test_searchField_withText_matchesReference() {
        assertSwiftUISnapshot(of: makeSearchSUT(text: "abacaxi"), height: 84)
    }
}

private extension DSTextFieldViewSnapshotTests {
    func makeSUT(text: String = "", label: String? = nil, systemImageName: String? = nil) -> some View {
        DSTextFieldView(
            "Digite o ingrediente",
            text: .constant(text),
            label: label,
            systemImageName: systemImageName
        )
        .padding(DSSpacing.small)
    }

    func makeSearchSUT(text: String = "") -> some View {
        DSSearchField("Buscar receita", text: .constant(text))
            .padding(DSSpacing.small)
    }
}
