# Smartcar iOS Auth SDK

[![CI Status](https://img.shields.io/travis/com/smartcar/ios-sdk.svg?style=flat-square)](https://travis-ci.com/smartcar/ios-sdk/)
[![Version](https://img.shields.io/cocoapods/v/SmartcarAuth.svg?style=flat-square)](http://cocoapods.org/pods/SmartcarAuth)
[![License](https://img.shields.io/cocoapods/l/SmartcarAuth.svg?style=flat-square)](http://cocoapods.org/pods/SmartcarAuth)
[![Platform](https://img.shields.io/cocoapods/p/SmartcarAuth.svg?style=flat-square)](http://cocoapods.org/pods/SmartcarAuth)

The SmartcarAuth iOS SDK makes it easy to handle the Smartcar authorization flow from iOS.

The SDK follows the best practices set out in [OAuth 2.0 for Native Apps](https://tools.ietf.org/html/draft-ietf-oauth-native-apps-06) including using _SFSafariViewController_ on iOS for the authorization request. _UIWebView_ is explicitly not supported due to usability and security reasons.

## Requirements

SmartcarAuth supports iOS 7 and above.

iOS 9+ uses the in-app browser tab pattern (via _SFSafariViewController_), and falls back to the system browser (mobile Safari) on earlier versions.

## Installation

SmartcarAuth is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```
pod "SmartcarAuth"
```

## Getting Started

First you need to have a global SmartcarAuth object in your AppDelegate to hold the session, in order to continue the authorization flow from the redirect.

```swift
// global variable in the app's AppDelegate
var smartcarSdk: SmartcarAuth? = nil
```

Then, initiate the SmartcarAuth object in the UIViewController.

```swift
let appDelegate = UIApplication.shared.delegate as! AppDelegate

func completionHandler(err: Error?, code: String?, state: String?) -> Any {
 // Receive authorization code
}

appDelegate.smartcar = SmartcarAuth(
  clientId: "afb0b7d3-807f-4c61-9b04-352e91fe3134",
  redirectUri: "scafb0b7d3-807f-4c61-9b04-352e91fe3134://page",
  scope: ["read_vin", "read_vehicle_info", "read_odometer"],
  completion: completionHandler
)
let smartcarSdk = appDelegate.smartcarSdk

// initialize authorization flow on the SFSafariViewController
smartcarSdk.launchAuthFlow(state: state, forcePrompt: false, testMode: false, viewController: viewController)
```

## Handling the Redirect

The authorization response URL is returned to the app via the iOS openURL app delegate method, so you need to pipe this through to the current authorization session

```swift
/**
	Intercepts callback from OAuth SafariView determined by the custom URI
 */
func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsLey : Any] = [:]) -> Bool {
    // Close the SFSafariViewController
    window!.rootViewController?.presentedViewController?.dismiss(animated: true , completion: nil)

    // Sends the URL to the current authorization flow (if any) which will
    // process it and then call the completion handler.
    if let sdk = smartcarSdk {
        sdk.handleCallback(url: url)
    }

    // Your additional URL handling (if any) goes here.

    return true
}
```

## SDK Reference

### Class `SmartcarAuth` Constructor

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `clientId` | `String` | _Required_ | Application client ID obtained from [Smartcar Developer Portal](https://developer.smartcar.com/). |
| `redirectUri` | `String` | _Required_ | Your app must register a custom URI scheme with iOS in order to receive the authorization callback. Smartcar requires the custom URI scheme to be in the format of `"sc" + clientId + "://" + hostname`. This URI must also be registered in [Smartcar's developer portal](https://developer.smartcar.com) for your app. You may append an optional path component or TLD (e.g. `sc4a1b01e5-0497-417c-a30e-6df6ba33ba46://page`). Read here for more information on [configuration of a custom scheme](http://www.idev101.com/code/Objective-C/custom_url_schemes.html). |
| `scope` | `Array<String>` | `[]` | Permissions requested from the user for specific grant. See the [Smartcar developer documentation](https://smartcar.com/docs/api) for a full list of available permissions. If the `scope` array is empty, all permissions will be requested. |
| `testMode` | `Bool` | `false` | Set to `true` to launch the Smartcar auth flow in test mode. |
| `completion` | `Function` | _Required_ | Callback function for when the Authorization Flow returns with either an Error or a `code` and the `state`. The function should take in the optional params `func (error: Error?, code: String?, state: String?) -> Any`. The return of the callback function will be returned from `smartcarSdk.launchAuthFlow()`. The completion handler should handle any Errors encountered during the Authorization Flow process and send the `code` to the server-side to retrieve an `accessToken`. If a `state` parameter was provided, then it should be checked to make sure the returned `state` matches the input `state`. |

### Method `.launchAuthFlow`

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `state` | `String` | `nil` | An opaque value used by the client to maintain state between the request and the callback. The authorization server includes this value when redirecting the user-agent back to the client. The parameter SHOULD be used for preventing cross-site request forgery attempts. Smartcar supports all `state` strings that can be url-encoded. |
| `forcePrompt` | `Bool` | `false` | The `false` option will skip the approval prompt for users who have already accepted the requested permissions for your application in the past. Set to `true` to force a user to see the approval prompt even if they have already accepted the permissions in the past. |
| `vehicleInfo` | `VehicleInfo` | `nil` | Passing in a `VehicleInfo` object with a `make` property causes the OEM selector screen to be bypassed, allowing the user to go directly to the specific brand vehicle login screen. For a complete list of supported makes, please see our [API Reference](https://smartcar.com/docs/api#authorization) documentation. |


### Class `VehicleInfo` Constructor

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `make` | String | `nil` | Including a `make` on the optional `VehicleInfo` object allows users to bypass the car brand selection screen. For a complete list of compabible makes, please see our [API Reference](https://smartcar.com/docs/api#authorization) documentation. |

## Author

Smartcar Inc., hello@smartcar.com

## License

SmartcarAuth is available under the MIT license. See the LICENSE file for more info.
