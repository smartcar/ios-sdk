// swift-tools-version:5.3
import PackageDescription

let version = "v6.2.0"
let checksum = "d8eaa1a8074af77c575c21d7f19cddceb9349cbb1714aaca1efbbb24de59045f"

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
