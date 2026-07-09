// swift-tools-version:5.3
import PackageDescription

let version = "v6.4.0"
let checksum = "7fdfcb40291bd4581e16a2d4378beb6fc25f95fdc14bbfb95f0ce6ced1decf52"

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
