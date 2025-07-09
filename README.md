# Smartcar iOS Auth SDK

[![CI Status](https://img.shields.io/travis/com/smartcar/ios-sdk.svg?style=flat-square)](https://travis-ci.com/smartcar/ios-sdk/)
[![Version](https://img.shields.io/cocoapods/v/SmartcarAuth.svg?style=flat-square)](http://cocoapods.org/pods/SmartcarAuth)
[![License](https://img.shields.io/cocoapods/l/SmartcarAuth.svg?style=flat-square)](http://cocoapods.org/pods/SmartcarAuth)
[![Platform](https://img.shields.io/cocoapods/p/SmartcarAuth.svg?style=flat-square)](http://cocoapods.org/pods/SmartcarAuth)

The SmartcarAuth iOS SDK makes it easy to integrate with Smartcar Connect from iOS.

The SDK follows the best practices set out in [OAuth 2.0 for Native Apps](https://tools.ietf.org/html/draft-ietf-oauth-native-apps-06).

## Requirements

SmartcarAuth supports iOS 13 and above.

Smartcar Connect is presented in a webview in your application using the Smartcar iOS SDK.

## Installation via CocoaPods

SmartcarAuth is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```
pod "SmartcarAuth"
```
## Installation via Swift Package Manager (SPM)

Alternatively, you can add the Smarcar iOS SDK to your Xcode project using Swift Package Manager.
Option 1: Add via Xcode
1. In Xcode, go to File → Add Packages...
2. Enter the Smartcar SDK Git URL: https://github.com/smartcar/ios-sdk.git
3. Select the latest version or specify a version range (e.g. "Up to Next Major" from X.X.X)
4. Add the Smartcar product to your app target.

Option 2: Add via Package.swift
If you manage your dependencies manually using Package.swift, add the following:
```swift
dependencies: [
    .package(url: "https://github.com/smartcar/ios-sdk.git", from: "X.X.X")
]
```

Then add "Smartcar" to your target dependencies:
```swift
.target(
    name: "YourApp",
    dependencies: [
        "Smartcar"
    ]
)
```

## Getting Started

First, you need to have a global SmartcarAuth object in your AppDelegate to hold the session, in order to continue the authorization flow from the redirect.

```swift
// global variable in the app's AppDelegate
var smartcarSdk: SmartcarAuth? = nil
```

Next, you will need to configure your redirect URI. Your redirect URI must follow this format: `<custom scheme>://<hostname>`. We suggest `"sc" + clientId + "://" + hostname`. 

Then, initiate the SmartcarAuth object in the UIViewController.

```swift
let appDelegate = UIApplication.shared.delegate as! AppDelegate

func completionHandler(code: String?, state: String?, virtualKeyUrl: String?, err: AuthorizationError?,) -> Void {
 // Receive authorization code
}

appDelegate.smartcar = SmartcarAuth(
  clientId: "afb0b7d3-807f-4c61-9b04-352e91fe3134",
  redirectUri: "scafb0b7d3-807f-4c61-9b04-352e91fe3134://exchange",
  scope: ["read_vin", "read_vehicle_info", "read_odometer"],
  completionHandler: completionHandler
)
let smartcar = appDelegate.smartcar

// Generate a Connect URL
let authUrl = smartcar.authUrlBuilder().build()

// Pass in the generated Connect URL and a UIViewController
smartcar.launchAuthFlow(url: authUrl, viewController: viewController)
```

## Bluetooth Support
To support OEMs that utilize Bluetooth pairing, you'll need to add an entry to Info.plist with a string value explaining to the user why your app needs Bluetooth access.
```
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires Bluetooth access to discover and connect to vehicles.</string>
```

## Handling the Redirect

For iOS 13 and above, the callback URL with the authentication code (or error) is automatically passed to the completion handler and no further action to intercept the callback is required.

## SDK Reference

For detailed documentation on parameters and available methods, please refer to
the [SDK Reference](https://smartcar.github.io/ios-sdk/).

## Developing the SDK
```
# Clone the repository
git clone https://github.com/smartcar/ios-sdk.git --recurse-submodules
# Initialize Kotlin project so we can `pod install`
pushd android-sdk && ./gradlew generateDummyFramework && popd
# Install CocoaPods dependencies
pod install
```
To consume the in-development SDK locally, add the following to your app's Podfile. Be sure to compile the SDK through Xcode with your desired device architecture selected to build the framework binaries.
```
pod 'SmartcarAuth', :path => '/path/to/ios-sdk'
```

## Author

Smartcar Inc., hello@smartcar.com

## License

SmartcarAuth is available under the MIT license. See the LICENSE file for more info.
