// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImagePipeline",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "ImagePipeline",
            targets: ["ImagePipeline"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/webpdecoder.git", .revision("bdba7712fd7e26e6ec3a2e4bcfaaa127b2d59844")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.2"),
    ],
    targets: [
        .target(name: "ImagePipeline", dependencies: ["webpdecoder"]),
        .testTarget(name: "ImagePipelineTests", dependencies: ["ImagePipeline", "SnapshotTesting"]),
    ]
)
