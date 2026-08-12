// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Launcher",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Launcher", targets: ["Launcher"])
    ],
    dependencies: [
        .package(path: "../GeneralInterfaces"),
        .package(path: "../DomainInterfaces"),
        .package(path: "../DesignSystem"),
        .package(path: "../Extensions")
    ],
    targets: [
        .target(name: "Launcher", dependencies: ["GeneralInterfaces", "DomainInterfaces", "DesignSystem", "Extensions"]),
        .testTarget(name: "LauncherTests", dependencies: ["Launcher"])
    ]
)
