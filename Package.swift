// swift-tools-version:5.1

import PackageDescription

let rpath = "/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"

let package = Package(
    name: "SwiftTypeInference",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git",
                 .revision("swift-DEVELOPMENT-SNAPSHOT-2019-07-10-m")),
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
            dependencies: ["SwiftSyntax", "SwiftcBasic", "SwiftcType"]
        ),
        .target(
            name: "SwiftcSema",
            dependencies: ["SwiftcBasic", "SwiftcType", "SwiftcAST"]
        ),
        .target(
            name: "SwiftcTest",
            dependencies: ["SwiftcBasic", "SwiftcType"]
        ),
        .target(
            name: "SwiftCompiler",
            dependencies: ["SwiftcAST", "SwiftcSema"]
        ),
        .target(
            name: "swsc",
            dependencies: ["SwiftcAST", "SwiftcSema"],
            linkerSettings: [
                .unsafeFlags(["-rpath", rpath])
            ]
        ),
        .testTarget(
            name: "SwiftTypeInferenceTests",
            dependencies: ["SwiftcTest", "SwiftcSema"],
            linkerSettings: [
                .unsafeFlags(["-rpath", rpath])
            ]
        )
    ]
)
