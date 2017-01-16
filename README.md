# SmartCarOAuthSDK

[![CI Status](http://img.shields.io/travis/Jeremy Zhang/SmartCarOAuthSDK.svg?style=flat)](https://travis-ci.org/Jeremy Zhang/SmartCarOAuthSDK)
[![Version](https://img.shields.io/cocoapods/v/SmartCarOAuthSDK.svg?style=flat)](http://cocoapods.org/pods/SmartCarOAuthSDK)
[![License](https://img.shields.io/cocoapods/l/SmartCarOAuthSDK.svg?style=flat)](http://cocoapods.org/pods/SmartCarOAuthSDK)
[![Platform](https://img.shields.io/cocoapods/p/SmartCarOAuthSDK.svg?style=flat)](http://cocoapods.org/pods/SmartCarOAuthSDK)

SmartCarOAuthSDK is a client SDK for communicating with the SmartCar API OAuth 2.0. It strives to map the requests and responses to the SmartCar API and ensures the specifications are followed. In addition to ensuring specification, convenience methods are avaliable to assist common tasks like auto-generation of buttons to initiate the authorization flow.

It follows the best practices set out in [OAuth 2.0 for Native Apps] (https://tools.ietf.org/html/draft-ietf-oauth-native-apps-06) including using _SFSafariViewController_ on iOS for the authorization request. For this reason, UIWebView is explicitly not supported due to usability and security reasons.

## Requirements

SmartCarOAuthSDK supports iOS 7 and above.

iOS 9+ uses the in-app browser tab pattern (via _SFSafariViewController_), and falls back to the system browser (mobile Safari) on earlier versions.

## Installation

SmartCarOAuthSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SmartCarOAuthSDK"
```

## Authorization

First you need to have a global SmartCarOAuthSDK object in your AppDelegate to hold the session, in order to continue the authorization flow from the redirect.

```swift
// global variable in the app's AppDelegate
var smartCarSDK: SmartCarOAuthSDK? = nil
```

Then, initiate the authorization request.

```swift
// build OAuth request
let smartCarRequest = SmartCarOAuthRequest(clientID: clientId, redirectURI: redirectURI, scope: scope, state: state)

// initialize authorization request for Acura
let appDelegate = UIApplication.shared.delegate as! AppDelegate
appDelegate.smartCarSDK = SmartCarOAuthSDK(request: smartCarRequest)
let sdk = appDelegate.smartCarSDK

sdk.initializeAuthorizationRequest(for oem: OEM(oemName: OEMName.acura), viewController: viewController)
```

### Request Configuration

`clientId`

Application client ID obtained from [Smartcar Developer Portal] (https://developer.smartcar.com/).

`redirectURI`

Your app must register with the system for the custom URI scheme in order to receive the authorization response. Smartcar API requires the custom URI scheme to be in the format of `sk + clientId`. Where clienId is the application client ID obtained from the Smartcar Developer Portal. You may append an optional path component (e.g. `sk4a1b01e5-0497-417c-a30e-6df6ba33ba46://oauth2redirect`).

`scope`

Permissions requested from the user for specific grant.

`state`

OAuth state parameter. Typically used for passing a user's ID or token to prevent CORS attacks

`grantType` (optional)

Defaults to `GrantType.code`. `GrantType.code` is used for a server-side OAuth transaction.

`GrantType.token` sends back a 2 hour token typically used for client-side applications.

`forcePrompt` (optional)

Defaults to `ApprovalType.auto`. Set to `ApprovalType.force` to force a user to re-grant permissions.

`development` (optional)

Defaults to `false`. Set to `true` to enable the Mock OEM.

### Handling the Redirect

The authorization response URL is returned to the app via the iOS openURL app delegate method, so you need to pipe this through to the current authorization session

```swift
/**
	Intercepts callback from OAuth Safari view determined by the custom URI
 */
func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    if smartCarSDK!.resumeAuthorizationFlowWithURL(url: url) {
        return true
    }
    return false
}
```

## Auxillary Objects

### SmartCarOAuthButtonGenerator

The code below initiaztes the Client SDK with the minimum configuration options and generate a single button to initialize the OAuth flow for Tesla

```swift
// global SmartCarOAuthButtonGenerator variable to store the button and action
var ui: SmartCarOAuthButtonGenerator? = nil
    
func mainFunction {
    
    // build OAuth request
    let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "sk4a1b01e5-0497-417c-a30e-6df6ba33ba46://", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.smartCarSDK = SmartCarOAuthSDK(request: smartCarRequest)
    let sdk = appDelegate.smartCarSDK

    // initialize ButtonGenerator
    ui = SmartCarOAuthButtonGenerator(sdk: sdk!, viewController: self)
    
    let button = ui!.generateButton(frame: CGRect(x: 0, y: 0, width: 250, height: 50), for: OEM(oemName: OEMName.acura))
    self.view.addSubview(button)
    
    // add autolayout constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    let buttonPinMiddleX = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
    let buttonPinMiddleY = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.5, constant: 0)
    let buttonWidth = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
    let buttonHeight = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)

    self.view.addConstraints([buttonPinMiddleX, buttonPinMiddleY, buttonWidth, buttonHeight])
}
```

Here are a subset of the buttons that can be generated: 

![](Example/Assets.xcassets/buttons.png)

### SmartCarOAuthPickerGenerator

Similar to SmartCarOAuthButtonGenerator but for selecting between different OEMs to initiate the authorization flow via the UIPickerView

```swift
let button = ui!.generatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
self.view.addSubview(button)
```

Below is the generated UIPickerView in action

<p align="center">
  <img src="Example/Assets.xcassets/picker.png"/>
</p>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Smartcar Inc., hello@smartcar.com

## License

SmartCarOAuthSDK is available under the MIT license. See the LICENSE file for more info.
