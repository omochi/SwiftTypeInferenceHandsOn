// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftTypeInference",
    dependencies: [
         .package(url: "https://github.com/apple/swift-syntax.git",
                  .revision("swift-DEVELOPMENT-SNAPSHOT-2019-07-10-m")),
    ],
    targets: [
        .target(
            name: "SwiftTypeInference",
            dependencies: ["SwiftSyntax"],
            linkerSettings: [
                .unsafeFlags(["-rpath", "/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"])
        ]),
        .testTarget(
            name: "SwiftTypeInferenceTests",
            dependencies: ["SwiftTypeInference"]),
    ]
)
