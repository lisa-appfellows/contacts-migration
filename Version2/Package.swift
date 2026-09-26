// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Version2",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Version2",
            targets: ["Version2"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../CoreUI"),
        .package(path: "../Version1"),
    ],
    targets: [
        .target(
            name: "Version2",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "CoreUI", package: "CoreUI"),
                .product(name: "Version1", package: "Version1"),
            ]
        ),
        .testTarget(
            name: "Version2Tests",
            dependencies: [
                "Version2",
                .product(name: "Version1", package: "Version1"),
            ]),
    ]
)
