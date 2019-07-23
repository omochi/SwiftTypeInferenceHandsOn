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
            name: "SwiftTypeInference",
            dependencies: ["SwiftSyntax"]
        ),
        .target(
            name: "infer",
            dependencies: ["SwiftTypeInference"],
            linkerSettings: [
                .unsafeFlags(["-rpath", rpath])
            ]
        ),
        .testTarget(
            name: "SwiftTypeInferenceTests",
            dependencies: ["SwiftTypeInference"],
            linkerSettings: [
                .unsafeFlags(["-rpath", rpath])
            ]
        )
    ]
)
