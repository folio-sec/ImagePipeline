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
        .package(url: "https://github.com/kishikawakatsumi/webpdecoder.git", .branch("master")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.2"),
    ],
    targets: [
        .target(name: "ImagePipeline", dependencies: ["webpdecoder"]),
        .testTarget(name: "ImagePipelineTests", dependencies: ["ImagePipeline", "SnapshotTesting"]),
    ]
)
