import SwiftUI
import UIKit
import XCTest
@testable import DesignSystem

final class DSIngredientControlsTests: XCTestCase {
    func test_choiceRow_withSelectedValue_loadsItsView() {
        let sut = UIHostingController(
            rootView: DSChoiceRow(title: "Médio", isSelected: true, action: {})
        )

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view)
    }

    func test_choiceRow_withUnselectedValue_loadsItsView() {
        let sut = UIHostingController(
            rootView: DSChoiceRow(title: "Pouco", isSelected: false, action: {})
        )

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view)
    }

    @MainActor
    func test_toastPresentation_withFirstRequest_showsTheToast() {
        let presentation = DSToastPresentation()
        let request = DSToastRequest(message: "Erro", style: .error)

        presentation.present(request: request, duration: 3, onDismiss: { _ in })

        XCTAssertTrue(presentation.isVisible)
        XCTAssertEqual(presentation.activeRequest, request)
        XCTAssertEqual(presentation.progress, 1)
    }

    @MainActor
    func test_toastPresentation_withRepeatedMessage_usesTheNewestRequest() {
        let presentation = DSToastPresentation()
        let firstRequest = DSToastRequest(message: "Erro", style: .error)
        let repeatedRequest = DSToastRequest(message: "Erro", style: .error)

        presentation.present(request: firstRequest, duration: 3, onDismiss: { _ in })
        presentation.present(request: repeatedRequest, duration: 3, onDismiss: { _ in })

        XCTAssertNotEqual(firstRequest.id, repeatedRequest.id)
        XCTAssertEqual(presentation.activeRequest, repeatedRequest)
        XCTAssertTrue(presentation.isVisible)
    }

    @MainActor
    func test_toastPresentation_whenAnOlderRequestDismisses_doesNotHideTheNewestToast() {
        let presentation = DSToastPresentation()
        let firstRequest = DSToastRequest(message: "Primeiro", style: .error)
        let secondRequest = DSToastRequest(message: "Segundo", style: .error)
        var dismissedRequestIDs: [UUID] = []

        presentation.present(request: firstRequest, duration: 3) { dismissedRequestIDs.append($0) }
        presentation.present(request: secondRequest, duration: 3) { dismissedRequestIDs.append($0) }
        presentation.dismiss(requestID: firstRequest.id) { dismissedRequestIDs.append($0) }

        XCTAssertTrue(presentation.isVisible)
        XCTAssertEqual(presentation.activeRequest, secondRequest)
        XCTAssertTrue(dismissedRequestIDs.isEmpty)
    }
}
