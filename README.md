# Smartcar iOS Auth SDK

[![CI Status](https://img.shields.io/travis/smartcar/ios-sdk.svg?style=flat)](https://travis-ci.com/smartcar/ios-sdk/)
[![Version](https://img.shields.io/cocoapods/v/SmartcarAuth.svg?style=flat)](http://cocoapods.org/pods/SmartcarAuth)
[![License](https://img.shields.io/cocoapods/l/SmartcarAuth.svg?style=flat)](http://cocoapods.org/pods/SmartcarAuth)
[![Platform](https://img.shields.io/cocoapods/p/SmartcarAuth.svg?style=flat)](http://cocoapods.org/pods/SmartcarAuth)

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

## Authorization

First you need to have a global SmartcarAuth object in your AppDelegate to hold the session, in order to continue the authorization flow from the redirect.

```swift
// global variable in the app's AppDelegate
var smartcarSdk: SmartcarAuth? = nil
```

Then, initiate the SmartcarAuth object in the UIViewController.

```swift
let appDelegate = UIApplication.shared.delegate as! AppDelegate
appDelegate.smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completion: completionHandler)
let smartcarSdk = appDelegate.smartcarSdk

// initialize authorization flow on the SFSafariViewController
smartcarSdk.launchAuthFlow(state: state, forcePrompt: false, showMock: false, viewController: viewController)
```

### SmartcarAuth Parameters

`clientId`

Application client ID obtained from [Smartcar Developer Portal](https://developer.smartcar.com/).

`redirectUri`

Your app must register a custom URI scheme with iOS in order to receive the authorization callback. Smartcar requires the custom URI scheme to be in the format of `"sc" + clientId + "://" + hostname`. This URI must also be registered
in [Smartcar's developer portal](https://developer.smartcar.com) for your app. You may append an optional path component or TLD (e.g. `sc4a1b01e5-0497-417c-a30e-6df6ba33ba46://oauth2redirect.com/page`).

More information on [configuration of custom scheme](http://www.idev101.com/code/Objective-C/custom_url_schemes.html).

`scope` (optional)

Permissions requested from the user for specific grant. See the [Smartcar developer documentation](https://developer.smartcar.com/docs) for a full list of available permissions. If no `scope` variable is provided, then Smartcar Authorization Flow will display the full list of permissions granted to the clientId.

`development` (optional)

Defaults to `false`. Set to `true` to enable the Mock OEM for testing.

`completion`

Callback function for when the Authorization Flow returns with either an Error or a `code` and the `state`. The function should take in the optional params `func (error: Error?, code: String?, state: String?) -> Any`. The return of the callback function will be returned from `smartcarSdk.launchAuthFlow()`. The completion handler should handle any Errors encountered during the Authorization Flow process and send the `code` to the server-side to retrieve an `accessToken`. If a `state` parameter was provided, then it should be checked to make sure the returned `state` matches the input `state`.

### launchAuthFlow Parameters

`state` (optional)

Defaults to `nil`. An opaque value used by the client to maintain state between the request and the callback. The authorization server includes this value when redirecting the user-agent back to the client. The parameter SHOULD be used for preventing cross-site request forgery attempts. Smartcar supports all `state` strings that can be url-encoded.

`forcePrompt` (optional)

Defaults to `false`. The `false` option will skip the approval prompt for users who have already accepted the requested permissions for your application in the past. Set to `true` to force a user to see the approval prompt even if they have already accepted the permissions in the past.

### Handling the Redirect

The authorization response URL is returned to the app via the iOS openURL app delegate method, so you need to pipe this through to the current authorization session

```swift
/**
	Intercepts callback from OAuth SafariView determined by the custom URI
 */
func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
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

## Author

Smartcar Inc., hello@smartcar.com

## License

SmartcarAuth is available under the MIT license. See the LICENSE file for more info.
