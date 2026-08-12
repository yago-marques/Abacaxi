// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Extensions",
    platforms: [.iOS(.v16)],
    products: [.library(name: "Extensions", targets: ["Extensions"])],
    targets: [.target(name: "Extensions")]
)
