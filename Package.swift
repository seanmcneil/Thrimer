// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Thrimer",
    platforms: [.iOS(.v11),
                .macOS(.v10_12)],
    products: [
        .library(
            name: "Thrimer",
            targets: ["Thrimer"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Thrimer",
            dependencies: []),
        .testTarget(
            name: "ThrimerTests",
            dependencies: ["Thrimer"]),
    ]
)
