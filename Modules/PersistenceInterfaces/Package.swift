// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PersistenceInterfaces",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "PersistenceInterfaces", targets: ["PersistenceInterfaces"])
    ],
    targets: [
        .target(name: "PersistenceInterfaces"),
        .testTarget(name: "PersistenceInterfacesTests", dependencies: ["PersistenceInterfaces"])
    ]
)
