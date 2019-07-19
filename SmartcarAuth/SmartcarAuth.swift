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

import UIKit
import SafariServices

let domain = "connect.smartcar.com"

/**
Smartcar Authentication SDK for iOS written in Swift 3.
    - Facilitates the flow with a SFSafariViewController to redirect to Smartcar and retrieve an authorization code
*/

@objc public class SmartcarAuth: NSObject {
    var clientId: String
    var redirectUri: String
    var scope: [String]
    var completion: (Error?, String?, String?) -> Any?
    var development: Bool
    // NSNumber? is used here instead of Bool? because there is no concept of Bool? in Objective-C
    var testMode: NSNumber?

    /**
    Constructor for the SmartcarAuth

    - parameters:
        - clientId: app client id
        - redirectUri: app redirect uri
        - scope: app oauth scope
        - development: shows the mock OEM for testing, defaults to false. This is deprecated and has been replaced with testMode.
        - testMode: optional, launch the Smartcar auth flow in test mode, defaults to nil.
        - completion: callback function called upon the completion of the OAuth flow with the error, the auth code, and the state string
    */
    @objc public init(clientId: String, redirectUri: String, scope: [String] = [], development: Bool =  false, testMode: NSNumber? = nil, completion: @escaping (Error?, String?, String?) -> Any?) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.completion = completion
        self.development = development
        self.testMode = testMode
    }

    /**
    Presents a SFSafariViewController with the initial authorization url

    - parameters:
        - state: optional, oauth state
        - forcePrompt: optional, forces permission screen if set to true, defaults to false
        - vehicleInfo: optional, when 'make' property is present, allows user to bypass oem selector screen and go straight to vehicle login screen, defaults to nil
        - singleSelect: optional, controls the behavior of the grant dialog by only allowing the user to select a single vehicle to authorize, defaults to nil
        - singleSelectOptions: optional, when 'vin' property is present, controls the behavior of the grant dialog by only allowing the user to authorize the vehicle with the specified VIN, defaults to nil
        - viewController: the viewController responsible for presenting the SFSafariView
    */
    @objc public func launchAuthFlow(state: String? = nil, forcePrompt: Bool = false, vehicleInfo: VehicleInfo? = nil, singleSelect: NSNumber? = nil, singleSelectOptions: VehicleInfo? = nil, viewController: UIViewController) {

        let safariVC = SFSafariViewController(url: URL(string: generateUrl(state: state, forcePrompt: forcePrompt, vehicleInfo: vehicleInfo, singleSelect: singleSelect, singleSelectOptions: singleSelectOptions))!)
        viewController.present(safariVC, animated: true, completion: nil)
    }

    /**
    Generates the authorization request URL from the authorization parameters

    - parameters:
        - state: optional, oauth state
        - forcePrompt: optional, forces permission screen if set to true, defaults to false
        - vehicleInfo: optional, when 'make' property is present, allows user to bypass oem selector screen and go straight to vehicle login screen, defaults to nil
        - singleSelect: optional, controls the behavior of the grant dialog and by only allowing the user to select a single vehicle to authorize, defaults to nil
        - singleSelectOptions: optional, when 'vin' property is present, controls the behavior of the grant dialog by only allowing the user to authorize the vehicle with the specified VIN, defaults to nil
    - returns:
    authorization request URL

    */
    @objc public func generateUrl(state: String? = nil, forcePrompt: Bool = false, vehicleInfo: VehicleInfo? = nil, singleSelect: NSNumber? = nil, singleSelectOptions: VehicleInfo? = nil) -> String {
        var components = URLComponents(string: "https://\(domain)/oauth/authorize")!

        var queryItems: [URLQueryItem] = []

        queryItems.append(URLQueryItem(name: "response_type", value: "code"))
        queryItems.append(URLQueryItem(name: "client_id", value: self.clientId))

        if let redirectUri = self.redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
        }

        if !scope.isEmpty {
            let scopeString = self.scope.joined(separator: " ")
            queryItems.append(URLQueryItem(name: "scope", value: scopeString))

        }

        queryItems.append(URLQueryItem(name: "approval_prompt", value: forcePrompt ? "force" : "auto"))

        if let stateString = state {
            queryItems.append(URLQueryItem(name: "state", value: stateString))
        }

        // if testMode specified, override self.development
        var mode = self.development;
        if (self.testMode != nil) {
          // convert NSNumber to Bool
           mode = self.testMode!.boolValue;
        }

        queryItems.append(URLQueryItem(name: "mode", value: mode ? "test" : "live"))

        if let vehicleObject = vehicleInfo {
            if let vehicleObjectMake = vehicleObject.make {
                queryItems.append(URLQueryItem(name: "make", value: vehicleObjectMake))
            }
        }

        var singleSelectAdded = false;
        var noValidOptionsFound = false;

        if let singleSelectObject = singleSelectOptions {
            if let singleSelectVIN = singleSelectObject.vin {
                queryItems.append(URLQueryItem(name: "single_select_vin", value: singleSelectVIN))
                singleSelectAdded = true;
            }
            if singleSelectAdded == false {
                noValidOptionsFound = true;
            } else {
                queryItems.append(URLQueryItem(name: "single_select", value: "true"))
            }
        }

        if singleSelectAdded == false {
            if let singleSelectValue = singleSelect {
                let singleSelectBoolValue = singleSelectValue.boolValue;
                queryItems.append(URLQueryItem(name: "single_select", value: singleSelectBoolValue ? "true" : "false"))
            } else if (noValidOptionsFound) {
                queryItems.append(URLQueryItem(name: "single_select", value: "false"))
            }
        }

        components.queryItems = queryItems

        return components.url!.absoluteString
    }

    /**
    Authorization callback function. Verifies that no error occured during the OAuth process and extracts the auth code and state string. Invokes the completion function with the appropriate parameters.

    - parameters:
        - url: callback URL containing authorization code

    - returns:
    the output of the executed completion function
    */

    @objc public func handleCallback(with url: URL) -> Any? {
        let urlComp = URLComponents(url: url, resolvingAgainstBaseURL: false)

        guard let query = urlComp?.queryItems else {
            let authorizationError = AuthorizationError(type: .missingQueryParameters, errorDescription: nil, vehicleInfo: nil)
            return completion(authorizationError, nil, nil)
        }

        let queryState = query.filter({ $0.name == "state"}).first?.value
        
        let vehicle = VehicleInfo()
        
        if let vin = query.filter({ $0.name == "vin"}).first?.value {
            vehicle.vin = vin
            if let make = query.filter({ $0.name == "make"}).first?.value {
                vehicle.make = make
            }
            if let model = query.filter({ $0.name == "model"}).first?.value {
                vehicle.model = model
            }
            if let year = query.filter({ $0.name == "year"}).first?.value {
                vehicle.year = Int(year)
            }
        }
        
        let error = query.filter({ $0.name == "error"}).first?.value
        let errorDescription = query.filter({ $0.name == "error_description"}).first?.value
        
        if (error != nil) {
            switch (error) {
                case "vehicle_incompatible":
                    let authorizationError = AuthorizationError(type: .vehicleIncompatible, errorDescription: errorDescription, vehicleInfo: vehicle)

                    return completion(authorizationError, nil, queryState)
                case "access_denied":
                    let authorizationError = AuthorizationError(type: .accessDenied, errorDescription: errorDescription, vehicleInfo: nil)
                    
                    return completion(authorizationError, nil, queryState)
                default:
                    let authorizationError = AuthorizationError(type: .accessDenied, errorDescription: errorDescription, vehicleInfo: nil)
                    
                    return completion(authorizationError, nil, queryState)
            }
        }

        guard let code = query.filter({ $0.name == "code"}).first?.value else {
            let authorizationError = AuthorizationError(type: .missingAuthCode, errorDescription: nil, vehicleInfo: nil)
            return completion(authorizationError, nil, queryState)
        }

        return completion(nil, code, queryState)
    }
}
