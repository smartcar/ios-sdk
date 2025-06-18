// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SmartcarAuth",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SmartcarAuth",
            targets: ["SmartcarAuth"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1")
    ],
    targets: [
        .target(
            name: "SmartcarAuth",
            path: "SmartcarAuth",
            exclude: [],
            resources: [],
            swiftSettings: []
        ),
        .testTarget(
            name: "SmartcarAuthTests",
            dependencies: [
                "SmartcarAuth",
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "SmartcarAuthTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)