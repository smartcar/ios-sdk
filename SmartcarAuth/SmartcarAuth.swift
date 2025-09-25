/*
 SmartcarAuth.swift
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

import Foundation
import SafariServices

/**
Smartcar Authentication SDK for iOS written in Swift 5.
    - Facilitates the authorization flow to launch the flow and retrieve an authorization code
*/
@objcMembers public class SmartcarAuth: NSObject {
    var clientId: String
    var redirectUri: String
    var scope: [String]?
    var completionHandler: (_ code: String?, _ state: String?, _ virtualKeyUrl: String?, _ error: AuthorizationError?) -> Void
    var mode: SCMode?
    @available(*, deprecated, message: "Use mode instead")
    var testMode: Bool

    /**
    Constructor for the SmartcarAuth
    - parameters:
        - clientId: The application's client ID
        - redirectUri: The application's redirect URI. Must be a valid URI.
        - scope: An array of authorization scopes
        - completion: Callback function called upon the completion of the Smartcar Connect
        - testMode: Deprecated, please use `mode` instead. Optional, launch the Smartcar auth flow in test mode when set to true. Defaults to false.
        - mode: Optional, determine what mode Smartcar Connect should be launched in. Should be one of .test, .live or .simulated. If none specified, defaults to live mode.

    */
    public init(
        clientId: String,
        redirectUri: String,
        scope: [String] = [],
        completionHandler: @escaping (String?, String?, String?, AuthorizationError?) -> Void,
        testMode: Bool = false,
        mode: SCMode? = nil
    ) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.completionHandler = completionHandler
        self.testMode = testMode
        self.mode = mode
    }
    
    /**
     Helper method to generate a SCURLBuilder instance, which then can be used (with various setters) to build an auth URL
        See `SCURLBuilder` for a full list of query parameters that can be set on the authorization URL
    */
    public func authUrlBuilder() -> SCUrlBuilder {
        return SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode, mode: mode)
    }

    /**
     Starts the launch of Smartcar Connect.
     
     - parameters:
        - authUrl: the authorization URL for Smartcar Connect. Use `SCURLBuilder` to generate a auth URL
        - viewController: The view controller responsible for presenting the Connect flow
    */
    public func launchAuthFlow(url: String, viewController: UIViewController) {
        let authUrl = URL(string: url)!
        let redirectUrl = URL(string: redirectUri)
        let redirectUriScheme = redirectUrl?.scheme
        let redirectUriHost = (redirectUrl?.host!)!

        let connectVC = ConnectController(authUrl: authUrl, redirectUriHost: redirectUriHost, handleCallback: handleCallback)
        viewController.present(connectVC, animated: true)
    }

    /**
    Authorization callback function. Verifies that no error occured during the OAuth process and extracts the auth code, state string, and virtualKeyUrl upon success. Invokes the completion function with either the code or an error (and state and/or virtualKeyUrl if included).
    - parameters:
        - url: callback URL containing authorization code or an error
    */
    public func handleCallback(callbackUrl: URL) {
        let authorizationError: AuthorizationError
        
        let urlComp = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
        guard let query = urlComp?.queryItems else {
            authorizationError = AuthorizationError(type: .missingQueryParameters, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, nil, nil, authorizationError)
        }
        
        let queryState = query.filter({$0.name == "state"}).first?.value!
        
        let vehicle: VehicleInfo?
        
        if let vin = query.filter({$0.name == "vin"}).first?.value {
            vehicle = VehicleInfo(vin: vin)
            if let make = query.filter({$0.name == "make"}).first?.value {
                vehicle?.make = make
            }
        } else {
            vehicle = nil
        }
        
        let error = query.filter({$0.name == "error"}).first?.value
        
        if (error != nil) {
            let errorDescription = query.filter({$0.name == "error_description"}).first?.value
            switch (error) {
                case "vehicle_incompatible":
                    authorizationError = AuthorizationError(type: .vehicleIncompatible, errorDescription: errorDescription, vehicleInfo: vehicle)
                case "invalid_subscription":
                    authorizationError = AuthorizationError(type: .invalidSubscription, errorDescription: errorDescription)
                case "access_denied":
                    authorizationError = AuthorizationError(type: .accessDenied, errorDescription: errorDescription)
                case "no_vehicles":
                    authorizationError = AuthorizationError(type: .noVehicles, errorDescription: errorDescription)
                case "configuration_error":
                    let statusCode = query.filter({$0.name == "status_code"}).first?.value;
                    let errorMessage = query.filter({$0.name == "error_message"}).first?.value;
                    authorizationError = AuthorizationError(type: .configurationError, errorDescription: errorDescription, statusCode: statusCode, errorMessage: errorMessage)
                case "server_error":
                    authorizationError = AuthorizationError(type: .serverError, errorDescription: errorDescription)
                case "user_manually_returned_to_application", "user_cancelled":
                    authorizationError = AuthorizationError(type: .userExitedFlow, errorDescription: errorDescription)
                default:
                    authorizationError = AuthorizationError(type: .unknownError, errorDescription: errorDescription)
            }
            return self.completionHandler(nil, queryState, nil, authorizationError)
        }

        let virtualKeyUrl = query.filter({$0.name == "virtual_key_url"}).first?.value!

        guard let code = query.filter({$0.name == "code"}).first?.value else {
            let authorizationError = AuthorizationError(type: .missingAuthCode, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, queryState, nil, authorizationError)
        }

        return self.completionHandler(code, queryState, virtualKeyUrl, nil)
    }
    
}
