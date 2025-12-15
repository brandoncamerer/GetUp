// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GetUp",
    platforms: [
        .macOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "GetUp",
            dependencies: []),
    ]
)
