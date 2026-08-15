// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Data", targets: ["Data"])
    ],
    dependencies: [
        .package(path: "../DataInterfaces"),
        .package(path: "../DomainInterfaces"),
        .package(path: "../PersistenceInterfaces"),
        .package(path: "../NetworkInterfaces")
    ],
    targets: [
        .target(name: "Data", dependencies: ["DataInterfaces", "DomainInterfaces", "PersistenceInterfaces", "NetworkInterfaces"]),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", "DomainInterfaces", "NetworkInterfaces", "PersistenceInterfaces"]
        )
    ]
)
