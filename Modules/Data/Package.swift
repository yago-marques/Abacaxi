// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Data", targets: ["Data"])
    ],
    dependencies: [
        .package(path: "../DataInterfaces"),
        .package(path: "../PersistenceInterfaces"),
        .package(path: "../NetworkInterfaces")
    ],
    targets: [
        .target(name: "Data", dependencies: ["DataInterfaces", "PersistenceInterfaces", "NetworkInterfaces"]),
        .testTarget(name: "DataTests", dependencies: ["Data", "NetworkInterfaces"])
    ]
)
