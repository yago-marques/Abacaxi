// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Domain", targets: ["Domain"])
    ],
    dependencies: [
        .package(path: "../DataInterfaces"),
        .package(path: "../DomainInterfaces")
    ],
    targets: [
        .target(name: "Domain", dependencies: ["DataInterfaces", "DomainInterfaces"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain", "DataInterfaces"])
    ]
)
