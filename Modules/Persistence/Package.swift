// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Persistence", targets: ["Persistence"])
    ],
    dependencies: [
        .package(path: "../PersistenceInterfaces")
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: ["PersistenceInterfaces"],
            resources: [.process("Resources/DB.xcdatamodeld")]
        ),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence"])
    ]
)
