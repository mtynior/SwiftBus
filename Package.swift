// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBus",
    platforms: [.iOS(.v13), .macOS(.v10_15), .macCatalyst(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "SwiftBus", targets: ["SwiftBus"])
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftBus", dependencies: []),
        .testTarget(name: "SwiftBusTests", dependencies: ["SwiftBus"])
    ]
)
