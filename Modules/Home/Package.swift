// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Home",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Home", targets: ["Home"])
    ],
    dependencies: [
        .package(path: "../GeneralInterfaces")
    ],
    targets: [
        .target(name: "Home", dependencies: ["GeneralInterfaces"]),
        .testTarget(name: "HomeTests", dependencies: ["Home"])
    ]
)
