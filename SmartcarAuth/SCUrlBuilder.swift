/*
SCUrlBuilder.swift
SmartcarAuth
Copyright (c) 2017-present, Smartcar, Inc. All rights reserved.
You are hereby granted a limited, non-exclusive, worldwide, royalty-free
license to use, copy, modify, and distribute this software in source code or
binary form, for the limited purpose of this software's use in connection
with the web services and APIs provided by Smartcar.
As with any software that integrates with the Smartcar platform, your use of
this software is subject to the Smartcar Developer Agreement. This copyright
notice shall be included in all copies or substantial portions of the software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/**
* A builder used for generating Smartcar Connect authorization URLs.
* Use the built string with `SmartcarAuth.launchAuthFlow(...)` in iOS 10 and under or `SmartcarAuth.launchWebAuthSession(...)` in iOS 11 and above
* To see a full description of Smartcar Connect parameters, see the [Smartcar API Reference](https://smartcar.com/api#smartcar-connect)
*/
@objcMembers public class SCUrlBuilder: NSObject {
    private var components: URLComponents
    private var queryItems: [URLQueryItem] = []

    /**
    Constructor for SCUrlBuilder. Represents the minimum requirements for an authorization URL.
    - parameters:
        - clientId: The application's client ID
        - redirectUri: The application's redirect URI
        - scope: An array of authorization scopes
        - testMode: Optional, launch the Smartcar auth flow in test mode when set to true. Defaults to false.
    */
    public init(clientId: String, redirectUri: String, scope: [String], testMode: Bool) {
        self.components = URLComponents()
        self.components.scheme = "https"
        self.components.host = "connect.smartcar.com"
        self.components.path = "/oauth/authorize"

        self.queryItems.append(contentsOf: [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "mode", value: testMode ? "test" : "live")
        ])

        if let redirectUri = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
        }

        if !scope.isEmpty {
            let scopeString = scope.joined(separator: " ")
            self.queryItems.append(URLQueryItem(name: "scope", value: scopeString))
        }
    }

    /**
    Set an optional state parameter
    - parameters:
        - state: An optional value included on the redirect uri returned to `SmartcarAuth.webAuthSessionCompletion(...)` and `SmartcarAuth.handleCallback(...)`
    - returns:
        A reference to this object
    */
    public func setState(state: String) -> SCUrlBuilder {
        if (!state.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "state", value: state))
        }
        return self
    }

    /**
    Force display of the grant approval dialog in Smartcar Connect.
     
    Defaults to false and will only display the approval dialog if the user has not previously approved the scope. Set this to true to ensure the approval dialog is always shown to the user even if they have previously approved the same scope.
    - parameters:
        - forcePrompt: Set to true to ensure the grant approval dialog is always shown
    - returns:
        A reference to this object
    */
    public func setForcePrompt(forcePrompt: Bool) -> SCUrlBuilder {
        self.queryItems.append(URLQueryItem(name: "approval_prompt", value: forcePrompt ? "force" : "auto"))
        return self
    }

    /**
    Bypass the brand selector screen to a specified make.
     
    A list of compatible makes is available on the [Smartcar API Reference](https://smartcar.com/docs/api#connect-direct)
    - see: [Smartcar Connect Direct](https://smartcar.com/docs/api#connect-direct)
    - parameters:
        - make: The selected make
    - returns:
        A reference to this object
    */
    public func setMakeBypass(make: String) -> SCUrlBuilder {
        if (!make.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "make", value: make))
        }
        return self
    }

    /**
    Ensure the user only authorizes a single vehicle.
    
    A user's connected service account can be connected to multiple vehicles. Setting this parameter to true forces the user to select only a single vehicle.
    - see: [Smartcar Connect Match](https://smartcar.com/docs/api#connect-match)
    - parameters:
      - singleSelect: Set to true to ensure only a single vehicle is authorized
    - returns:
        A reference to this object
    */
    public func setSingleSelect(singleSelect: Bool) -> SCUrlBuilder {
        self.queryItems.append(URLQueryItem(name: "single_select", value: singleSelect.description))
        return self
    }

    /**
    Specify the vin a user can authorize in Smartcar Connect.
    When `setSingleSelect(...)` is set to true, this parameter can be used to ensure that Smartcar Connect will allow the user to authorize only the vehicle with a specific VIN.
    
    - see: [Smartcar Connect Match](https://smartcar.com/docs/api#connect-match)
    - parameters:
      - vin: The specific VIN to authorize
    - returns:
        A reference to this object
    */
    public func setSingleSelectVin(vin: String) -> SCUrlBuilder {
        if (!vin.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "single_select_vin", value: vin))
        }
        return self
    }

    /**
    Set flags to enable early access features.

    - parameters:
      - flags: List of feature flags that your application has early access to.
    - returns:
        A reference to this object
    */
    public func setFlags(flags: [String]) -> SCUrlBuilder {
        if (!flags.isEmpty) {
            let flagsString = flags.joined(separator: " ")
            self.queryItems.append(URLQueryItem(name: "flags", value: flagsString))
        }
        return self
    }

    /**
    Build a Smartcar Connect authorization URL string
     
    Use the built string with `SmartcarAuth.launchAuthFlow(...)` in iOS 10 and under or `SmartcarAuth.launchWebAuthSession(...)` in iOS 11 and above
    
    - returns:
        An authorization URL string
    */
    public func build() -> String {
        self.components.queryItems = self.queryItems
        return self.components.url!.absoluteString
    }

}
