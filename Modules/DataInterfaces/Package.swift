// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DataInterfaces",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "DataInterfaces", targets: ["DataInterfaces"])
    ],
    targets: [
        .target(name: "DataInterfaces"),
        .testTarget(name: "DataInterfacesTests", dependencies: ["DataInterfaces"])
    ]
)
