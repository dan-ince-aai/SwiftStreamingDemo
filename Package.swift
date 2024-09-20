// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealtimeTranscriptionScript",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "RealtimeTranscriptionScript",
            dependencies: [
                "Starscream"
            ]),
    ]
)
