# Smartcar iOS SDK

Smartcar iOS SDK documentation.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Class `SmartcarAuth` Constructor](#class-smartcarauth-constructor)
  - [Example](#example)
- [Completion Handler](#completion-handler)
  - [Example](#example-1)
- [Method `.launchAuthFlow`](#method-launchauthflow)
  - [Example](#example-2)
- [Class `VehicleInfo` Constructor](#class-vehicleinfo-constructor)
  - [Example](#example-3)
- [Enum `AuthorizationError`](#enum-authorizationerror)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Class `SmartcarAuth` Constructor

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `clientId` | `String` | _Required_ | Application client ID obtained from [Smartcar Developer Portal](https://developer.smartcar.com/). |
| `redirectUri` | `String` | _Required_ | Your app must register a custom URI scheme with iOS in order to receive the authorization callback. Smartcar requires the custom URI scheme to be in the format of `"sc" + clientId + "://" + hostname`. This URI must also be registered in [Smartcar's developer portal](https://developer.smartcar.com) for your app. You may append an optional path component or TLD (e.g. `sc4a1b01e5-0497-417c-a30e-6df6ba33ba46://page`). Read here for more information on [configuration of a custom scheme](http://www.idev101.com/code/Objective-C/custom_url_schemes.html). |
| `scope` | `Array<String>` | `[]` | Permissions requested from the user for specific grant. See the [Smartcar developer documentation](https://smartcar.com/docs/api) for a full list of available permissions. If the `scope` array is empty, all permissions will be requested. |
| `testMode` | `Bool` | `false` | Set to `true` to launch the Smartcar auth flow in test mode. |
| `completion` | `Function` | _Required_ | Callback function to be invoked upon completion of the Smartcar Authorization Flow. See the [Completion Handler](#completion-handler) section below for details on the function's inputs. |

### Example

```swift
let smartcar = SmartcarAuth(
  clientId: "afb0b7d3-807f-4c61-9b04-352e91fe3134",
  redirectUri: "scafb0b7d3-807f-4c61-9b04-352e91fe3134://page",
  scope: ["read_vin", "read_vehicle_info", "read_odometer"],
  completion: completionHandler
)
```

## Completion Handler

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `error` | [`AuthorizationError`](#enum-authorizationerror) | `nil` | This error will be present if there is a failure in the Smartcar Authorization Flow. Normally, this indicates that a vehicle owner pressed "Deny" to grant your application access to their vehicle. |
| `code` | `String` | `nil` | Received upon successful authorization. This code should be used to exchange with Smartcar for a long-lasting access token. See our [iOS Integration Guide](https://smartcar.com/docs/integration-guides/ios/introduction/) for more on this exchange. |
| `state` | `String` | `nil` | If `state` was provided in the `.launchAuthFlow` method, it will be returned here. |

### Example

```swift
func completionHandler(err: Error?, code: String?, state: String?) -> Any {
  // Receive authorization code
}
```

## Method `.launchAuthFlow`

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `state` | `String` | `nil` | An opaque value used by the client to maintain state between the request and the callback. The authorization server includes this value when redirecting the user-agent back to the client. The parameter SHOULD be used for preventing cross-site request forgery attempts. Smartcar supports all `state` strings that can be url-encoded. |
| `forcePrompt` | `Bool` | `false` | The `false` option will skip the approval prompt for users who have already accepted the requested permissions for your application in the past. Set to `true` to force a user to see the approval prompt even if they have already accepted the permissions in the past. |
| `vehicleInfo` | [`VehicleInfo`](#class-vehicleinfo-constructor) | `nil` | Passing in a [`VehicleInfo`](#class-vehicleinfo-constructor) object with a `make` property causes the OEM selector screen to be bypassed, allowing the user to go directly to the specific brand vehicle login screen. For a complete list of supported makes, please see our [API Reference](https://smartcar.com/docs/api#authorization) documentation. |
| `viewController` | `UIViewController` | _Required_ | The ViewController responsible for presenting the SFSafariView to the user. |

### Example

```swift
smartcar.launchAuthFlow(viewController: self)
```

## Class `VehicleInfo` Constructor

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `make` | String | `nil` | For a complete list of compabible makes, please see our [API Reference](https://smartcar.com/docs/api#authorization) documentation. |

### Example

```swift
// Launch authorization flow directly to the Tesla login screen
smartcar.launchAuthFlow(vehicleInfo: VehicleInfo(make: "Tesla"), viewController: self)
```

## Enum `AuthorizationError`

| Case | Description |
| ---- | ----------- |
| `accessDenied` | The vehicle owner denied your application access to their vehicle. This case is common and should be handled. |
| `missingQueryParameters` | The redirect callback was received with no query parameters. This is unexpected and should not occur in normal operation. |
| `missingAuthCode` | The redirect callback was received with some query parameters, but neither a `code` nor an `error` was present. This is unexpected and should not occur in normal operation. |
