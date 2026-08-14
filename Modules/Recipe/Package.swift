// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Recipe",
    defaultLocalization: "pt-BR",
    platforms: [.iOS(.v16)],
    products: [.library(name: "Recipe", targets: ["Recipe"])],
    dependencies: [
        .package(path: "../GeneralInterfaces"),
        .package(path: "../DomainInterfaces"),
        .package(path: "../DesignSystem"),
        .package(path: "../Extensions")
    ],
    targets: [
        .target(
            name: "Recipe",
            dependencies: ["GeneralInterfaces", "DomainInterfaces", "DesignSystem", "Extensions"],
            resources: [.process("Resources/Base.lproj")]
        ),
        .testTarget(name: "RecipeTests", dependencies: ["Recipe"])
    ]
)
