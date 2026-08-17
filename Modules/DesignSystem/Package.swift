// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    dependencies: [
        // Pin exato: não há Package.resolved commitado (o xcodeproj é gerado),
        // então o range aberto tornaria o build da CI não determinístico.
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.19.4")
    ],
    targets: [
        .target(name: "DesignSystem"),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: [
                "DesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
