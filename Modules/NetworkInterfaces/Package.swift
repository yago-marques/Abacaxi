// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkInterfaces",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "NetworkInterfaces", targets: ["NetworkInterfaces"])
    ],
    targets: [
        .target(name: "NetworkInterfaces"),
        .testTarget(name: "NetworkInterfacesTests", dependencies: ["NetworkInterfaces"])
    ]
)
