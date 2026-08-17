import SwiftUI
import XCTest
@testable import DesignSystem

final class DSIngredientControlsSnapshotTests: DSSnapshotTestCase {
    func test_choiceRow_selected_matchesReference() {
        assertSwiftUISnapshot(of: makeChoiceRowSUT(isSelected: true), height: 72)
    }

    func test_choiceRow_unselected_matchesReference() {
        assertSwiftUISnapshot(of: makeChoiceRowSUT(isSelected: false), height: 72)
    }

    func test_listRow_withQuantityBadge_matchesReference() {
        assertSwiftUISnapshot(of: makeListRowSUT(), height: 72)
    }

    func test_listRow_withLongTitle_truncates_matchesReference() {
        let sut = makeListRowSUT(title: "Abacaxi pérola colhido na madrugada de domingo")

        assertSwiftUISnapshot(of: sut, height: 72)
    }

    func test_progressBar_atHalf_matchesReference() {
        assertSwiftUISnapshot(of: makeProgressBarSUT(progress: 0.5), height: 32)
    }

    func test_progressBar_full_matchesReference() {
        assertSwiftUISnapshot(of: makeProgressBarSUT(progress: 1), height: 32)
    }

    func test_toast_errorStyle_matchesReference() {
        assertSwiftUISnapshot(of: makeToastSUT(style: .error, progress: 1), height: 120)
    }

    func test_toast_successStyle_matchesReference() {
        assertSwiftUISnapshot(of: makeToastSUT(style: .success, progress: 0.4), height: 120)
    }
}

private extension DSIngredientControlsSnapshotTests {
    func makeChoiceRowSUT(isSelected: Bool) -> some View {
        DSChoiceRow(title: "Médio", isSelected: isSelected, action: {})
            .padding(DSSpacing.small)
    }

    func makeListRowSUT(title: String = "Abacaxi") -> some View {
        DSListRow(title: title) { DSQuantityBadge("2x") }
            .padding(DSSpacing.small)
    }

    func makeProgressBarSUT(progress: CGFloat) -> some View {
        DSProgressBar(progress: progress)
            .padding(DSSpacing.small)
    }

    func makeToastSUT(style: DSToastStyle, progress: CGFloat) -> some View {
        DSToast(message: "Receita salva com sucesso", style: style, progress: progress)
            .padding(DSSpacing.small)
    }
}
