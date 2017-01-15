# SmartCarOAuthSDK

[![CI Status](http://img.shields.io/travis/Jeremy Zhang/SmartCarOAuthSDK.svg?style=flat)](https://travis-ci.org/Jeremy Zhang/SmartCarOAuthSDK)
[![Version](https://img.shields.io/cocoapods/v/SmartCarOAuthSDK.svg?style=flat)](http://cocoapods.org/pods/SmartCarOAuthSDK)
[![License](https://img.shields.io/cocoapods/l/SmartCarOAuthSDK.svg?style=flat)](http://cocoapods.org/pods/SmartCarOAuthSDK)
[![Platform](https://img.shields.io/cocoapods/p/SmartCarOAuthSDK.svg?style=flat)](http://cocoapods.org/pods/SmartCarOAuthSDK)

SmartCarOAuthSDK is a client SDK for communicating with the SmartCar API OAuth 2.0. It strives to map the requests and responses to the SmartCar API and ensures the specifications are followed. In addition to ensuring specification, convenience methods are avaliable to assist common tasks like auto-generation of buttons to initiate the authentication flow.

It follows the best practices set out in [OAuth 2.0 for Native Apps] (https://tools.ietf.org/html/draft-ietf-oauth-native-apps-06) including using _SFSafariViewController_ on iOS for the auth request. For this reason, UIWebView is explicitly not supported due to usability and security reasons.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

SmartCarOAuthSDK supports iOS 7 and above.

iOS 9+ uses the in-app browser tab pattern (via _SFSafariViewController_), and falls back to the system browser (mobile Safari) on earlier versions.

## Installation

SmartCarOAuthSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SmartCarOAuthSDK"
```

## Author

Jeremy Zhang, jeremyziyuzhang@gmail.com

## License

SmartCarOAuthSDK is available under the MIT license. See the LICENSE file for more info.
