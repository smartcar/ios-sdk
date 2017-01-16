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
```

### Request Configuration

`clientId`
Application client ID obtained from [Smartcar Developer Portal] (https://developer.smartcar.com/).

`redirectURI`
Your app must register with the system for the custom URI scheme in order to receive the authorization response. Smartcar API requires the custom URI scheme to be in the format of `sk + clientId`. Where clienId is the application client ID obtained from the Smartcar Developer Portal. You may append an optional path component (e.g. sk4a1b01e5-0497-417c-a30e-6df6ba33ba46://oauth2redirect).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Smartcar Inc., jeremyziyuzhang@gmail.com

## License

SmartCarOAuthSDK is available under the MIT license. See the LICENSE file for more info.
