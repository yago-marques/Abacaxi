// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DomainInterfaces",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "DomainInterfaces", targets: ["DomainInterfaces"])
    ],
    targets: [
        .target(
            name: "DomainInterfaces",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(name: "DomainInterfacesTests", dependencies: ["DomainInterfaces"])
    ]
)
