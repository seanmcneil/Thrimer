// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "Thrimer",
    platforms: [.iOS(.v13),
                .macOS(.v10_15)],
    products: [
        .library(
            name: "Thrimer",
            targets: ["Thrimer"]
        ),
    ],
    targets: [
        .target(
            name: "Thrimer",
            dependencies: []
        ),
        .testTarget(
            name: "ThrimerTests",
            dependencies: ["Thrimer"]
        ),
    ]
)
