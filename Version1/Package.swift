// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Version1",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Version1",
            targets: ["Version1"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../CoreUI"),
    ],
    targets: [
        .target(
            name: "Version1",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "CoreUI", package: "CoreUI"),
            ]
        ),
        .testTarget(
            name: "Version1Tests",
            dependencies: ["Version1"]),
    ]
)
