// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Home",
    defaultLocalization: "pt-BR",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Home", targets: ["Home"])
    ],
    dependencies: [
        .package(path: "../GeneralInterfaces"),
        .package(path: "../DomainInterfaces"),
        .package(path: "../DesignSystem"),
        .package(path: "../Extensions")
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: ["GeneralInterfaces", "DomainInterfaces", "DesignSystem", "Extensions"],
            resources: [.process("Resources/Base.lproj")]
        ),
        .testTarget(name: "HomeTests", dependencies: ["Home", "DomainInterfaces"])
    ]
)
