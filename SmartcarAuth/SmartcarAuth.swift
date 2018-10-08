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
        - viewController: the viewController responsible for presenting the SFSafariView
    */
    @objc public func launchAuthFlow(state: String? = nil, forcePrompt: Bool = false, viewController: UIViewController) {

        let safariVC = SFSafariViewController(url: URL(string: generateUrl(state: state, forcePrompt: forcePrompt))!)
        viewController.present(safariVC, animated: true, completion: nil)
    }

    /**
    Generates the authorization request URL from the authorization parameters

    - parameters:
        - state: optional, oauth state
        - forcePrompt: optional, forces permission screen if set to true, defaults to false

    - returns:
    authorization request URL

    */
    @objc public func generateUrl(state: String? = nil, forcePrompt: Bool = false) -> String {
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
            return completion(AuthorizationError.missingQueryParameters, nil, nil)
        }

        let queryState = query.filter({ $0.name == "state"}).first?.value

        if query.filter({ $0.name == "error"}).first?.value != nil {
            return completion(AuthorizationError.accessDenied, nil, queryState)
        }

        guard let code = query.filter({ $0.name == "code"}).first?.value else {
            return completion(AuthorizationError.missingAuthCode, nil, queryState)
        }

        return completion(nil, code, queryState)
    }
}
