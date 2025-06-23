// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DogUIPackage",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DogUILib",
            targets: ["DogUIComponents", "DogUIIcons", "DogUI"]
        ),
    ],
    dependencies: [
        .package(path: "../DogCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DogUIComponents"
        ),
        .target(
            name: "DogUIIcons"
        ),
        .target(
            name: "DogUI",
            dependencies: [
                "DogCore"
            ]
        ),
        .testTarget(
            name: "DogUITests",
            dependencies: ["DogUIComponents"]
        )
    ]
)
