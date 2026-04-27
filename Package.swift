// swift-tools-version:5.3
import PackageDescription

let version = "v6.3.1"
let checksum = "8e53c3e75164bc0eafc72bf2d2806556961c98a945898b12a3d25b4aab510c61"

let package = Package(
    name: "SmartcarAuth",
    platforms: [
        .iOS(.v14)
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
        .binaryTarget(
            name: "SmartcarAuthBinary",
            url: "https://github.com/smartcar/ios-sdk/releases/download/\(version)/framework.zip",
            checksum: checksum
        ),
        .target(
            name: "SmartcarAuth",
            dependencies: ["SmartcarAuthBinary"],
            path: "SmartcarAuth"
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
