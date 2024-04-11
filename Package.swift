// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftTypeInference",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "510.0.1"),
    ],
    targets: [
        .target(
            name: "SwiftcBasic",
            dependencies: []
        ),
        .target(
            name: "SwiftcType",
            dependencies: ["SwiftcBasic"]
        ),
        .target(
            name: "SwiftcAST",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                "SwiftcBasic",
                "SwiftcType"
            ]
        ),
        .target(
            name: "SwiftcSema",
            dependencies: ["SwiftcBasic", "SwiftcType", "SwiftcAST"]
        ),
        .target(
            name: "SwiftcTest",
            dependencies: ["SwiftcBasic", "SwiftcType", "SwiftcAST", "SwiftcSema"]
        ),
        .target(
            name: "SwiftCompiler",
            dependencies: ["SwiftcAST", "SwiftcSema"]
        ),
        .executableTarget(
            name: "swsc",
            dependencies: ["SwiftcAST", "SwiftcSema"]
        ),
        .testTarget(
            name: "SwiftTypeInferenceTests",
            dependencies: ["SwiftcTest", "SwiftcAST", "SwiftcSema"]
        )
    ]
)
