// swift-tools-version:5.3
import PackageDescription

let version = "v6.5.0"
let checksum = "cb5c2ced5ee71d60e782c846ea741f486c9c77de355dd2881cd4d28887cf03d8"

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
