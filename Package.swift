// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBus",
    products: [
        .library(name: "SwiftBus", targets: ["SwiftBus"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftBus", dependencies: []),
        .testTarget(name: "SwiftBusTests", dependencies: ["SwiftBus"]),
    ]
)
