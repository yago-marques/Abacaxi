import UIKit
import XCTest
@testable import DesignSystem

final class DSCardViewTests: XCTestCase {
    func test_init_withImage_addsMediaView() {
        let sut = makeSUT(image: UIImage())

        XCTAssertTrue(sut.subviews.contains { $0 is UIImageView })
    }

    func test_init_withoutImage_doesNotAddMediaView() {
        let sut = makeSUT()

        XCTAssertFalse(sut.subviews.contains { $0 is UIImageView })
    }

    func test_init_clipsSubviewsToCardBounds() {
        let sut = makeSUT(image: UIImage())

        XCTAssertTrue(sut.clipsToBounds)
    }

    func test_init_withCompactMediaSize_usesCompactMediaHeight() {
        let sut = makeSUT(image: UIImage(), mediaSize: .compact)
        let imageView = sut.subviews.first { $0 is UIImageView }
        let heightConstraint = imageView?.constraints.first { constraint in
            constraint.firstAttribute == .height && constraint.constant > 0
        }

        XCTAssertEqual(heightConstraint?.constant, 180)
    }

    func test_init_withImage_preservesImageAspectRatio() {
        let sut = makeSUT(image: UIImage())
        let imageView = sut.subviews.first { $0 is UIImageView } as? UIImageView

        XCTAssertEqual(imageView?.contentMode, .scaleAspectFit)
    }

    func test_init_withChevron_addsChevronIndicator() {
        let sut = makeSUT(showsChevron: true)

        let indicatorImageView = sut.subviews.first {
            $0.accessibilityIdentifier == "dsCardForwardIndicator"
        } as? UIImageView

        XCTAssertNotNil(indicatorImageView?.image)
    }
}

private extension DSCardViewTests {
    private func makeSUT(
        image: UIImage? = nil,
        mediaSize: DSCardView.MediaSize = .regular,
        showsChevron: Bool = false
    ) -> DSCardView {
        DSCardView(
            image: image,
            mediaSize: mediaSize,
            showsChevron: showsChevron,
            title: "Title",
            description: "Description"
        )
    }
}
