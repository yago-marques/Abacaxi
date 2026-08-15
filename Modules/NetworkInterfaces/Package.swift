// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkInterfaces",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "NetworkInterfaces", targets: ["NetworkInterfaces"])
    ],
    targets: [
        .target(
            name: "NetworkInterfaces",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(name: "NetworkInterfacesTests", dependencies: ["NetworkInterfaces"])
    ]
)
