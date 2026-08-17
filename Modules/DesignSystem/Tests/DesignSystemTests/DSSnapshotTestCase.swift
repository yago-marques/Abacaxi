import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

// Snapshots comparam pixels, e pixels dependem de device + iOS + Xcode.
// O ambiente canônico é a pipeline (.github/workflows/snapshot.yml:
// iPhone 16, iOS 18.5, Xcode 16.4), que exporta SNAPSHOT_TESTS=1.
// Fora dela (hook local, AllTests, test-impacted) os testes dão skip —
// nunca falham por divergência de simulador.
class DSSnapshotTestCase: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SNAPSHOT_TESTS"] == "1",
            "Snapshots rodam apenas no ambiente canônico da pipeline (SNAPSHOT_TESTS=1)"
        )
    }

    func assertUIKitSnapshot(
        of view: UIView,
        width: CGFloat,
        named name: String? = nil,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        assertSnapshot(
            of: view,
            as: .image(
                size: fittingSize(of: view, width: width),
                traits: UITraitCollection(preferredContentSizeCategory: .large)
            ),
            named: name,
            fileID: fileID,
            file: file,
            testName: testName,
            line: line,
            column: column
        )
    }

    func assertSwiftUISnapshot(
        of view: some View,
        width: CGFloat = 350,
        height: CGFloat,
        sizeCategory: UIContentSizeCategory = .large,
        named name: String? = nil,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: width, height: height),
                traits: UITraitCollection(preferredContentSizeCategory: sizeCategory)
            ),
            named: name,
            fileID: fileID,
            file: file,
            testName: testName,
            line: line,
            column: column
        )
    }

    // Imagem sólida gerada em runtime: fixture determinística que não depende
    // da versão de SF Symbols do simulador.
    func makeSolidImage(size: CGSize = CGSize(width: 600, height: 400)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            DSColorFixture.fill.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func fittingSize(of view: UIView, width: CGFloat) -> CGSize {
        let target = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: target.height)
    }
}

private enum DSColorFixture {
    static let fill = UIColor(red: 0.29, green: 0.56, blue: 0.35, alpha: 1)
}
