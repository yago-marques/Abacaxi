// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GeneralInterfaces",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "GeneralInterfaces", targets: ["GeneralInterfaces"])
    ],
    targets: [
        .target(name: "GeneralInterfaces"),
        .testTarget(name: "GeneralInterfacesTests", dependencies: ["GeneralInterfaces"])
    ]
)
