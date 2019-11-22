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
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif


/**
Smartcar Authentication SDK for iOS written in Swift 5.
    - Facilitates the authorization flow to launch the flow and retrieve an authorization code
*/
@objcMembers public class SmartcarAuth: NSObject {
    var clientId: String
    var redirectUri: String
    var scope: [String]
    var completionHandler: (_ code: String?, _ state: String?, _ error: AuthorizationError?) -> Void
    var testMode: Bool
    
    // SFAuthenticationSession/ASWebAuthenticationSession require a strong reference to the session so that the system doesn't deallocate the session before the user finishes authenticating
    private var session: Session?

    /**
    Constructor for the SmartcarAuth
    - parameters:
        - clientId: The application's client ID
        - redirectUri: The application's redirect URI
        - scope: An array of authorization scopes
        - testMode: Optional, launch the Smartcar auth flow in test mode when set to true. Defaults to false.
        - completion: Callback function called upon the completion of the Smartcar Connect
    */
    public init(clientId: String, redirectUri: String, scope: [String], completionHandler: @escaping (String?, String?, AuthorizationError?) -> Void, testMode: Bool = false) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.testMode = testMode
        self.completionHandler = completionHandler
    }
    
    /**
     Helper method to generate a SCURLBuilder instance, which then can be used (with various setters) to build an auth URL
        See `SCURLBuilder` for a full list of query parameters that can be set on the authorization URL
    */
    public func authUrlBuilder() -> SCUrlBuilder {
        return SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
    }
    
    /**
     Starts the launch of Smartcar Connect.
     
     The way that the browser is launched depends on the iOS version:
     
        iOS 10: `SFSafariViewController`
     
        iOS 11: `SFAuthenticationSession`
     
        iOS 12+: `ASWebAuthenticationSession`
     
     If you are supporting iOS 10, you will need to pass in a UIViewController, as well as intercept the callback in your application (see `README` for an example).
     
     - parameters:
        - authUrl: the authorization URL for Smartcar Connect. Use `SCURLBuilder` to generate a auth URL
        - viewController: Optional, the view controller responsible for presenting the SFSafariView. Only necessary if the application supports iOS 10 and lower. Defaults to nil.
    */
    public func launchAuthFlow(url: String, viewController: UIViewController? = nil) {
        let authUrl = URL(string: url)
        let redirectUriScheme = "sc" + self.clientId

        if #available(iOS 11.0, *) {
            if #available(iOS 13.0, *) {
                let authSession = ASWebAuthenticationSession.init(url: authUrl!, callbackURLScheme: redirectUriScheme, completionHandler: webAuthSessionCompletion)
                // this is required for the browser to open in iOS 13
                authSession.presentationContextProvider = self
                self.session = authSession
            } else if #available(iOS 12.0, *) {
                let authSession = ASWebAuthenticationSession.init(url: authUrl!, callbackURLScheme: redirectUriScheme, completionHandler: webAuthSessionCompletion)
                self.session = authSession
            } else {
                let authSession = SFAuthenticationSession.init(url: authUrl!, callbackURLScheme: redirectUriScheme, completionHandler: webAuthSessionCompletion)
                self.session = authSession
            }
            self.session?.start()
        // fall back to SFSafariViewController
        } else if viewController != nil {
            let safariVC = SFSafariViewController(url: authUrl!)
            viewController?.present(safariVC, animated: true, completion: nil)
        }
    }

    
    /**
    Authorization callback function that is called when the session is completed, or if the user cancels the session. Upon session completion, calls handleCallback, which extracts the auth code and state string upon success, or the error upon authentication failure. If the user cancels mid-session, the completionHandler is called with an AuthorizationError
    - parameters:
        - callback: callback URL containing either an authorization code or error
        - error: error that comes back if user cancels mid authorization flow
    */
    private func webAuthSessionCompletion(callback: URL?, error: Error?) -> Void {
        var authorizationError: AuthorizationError? = nil
        guard error == nil, let callback = callback else {
            let canceledLoginCode: Int?
            if #available(iOS 12.0, *) {
                canceledLoginCode = ASWebAuthenticationSessionError.canceledLogin.rawValue
            } else if #available(iOS 11.0, *) {
                canceledLoginCode = SFAuthenticationError.canceledLogin.rawValue
            } else {
                canceledLoginCode = nil
            }
            
            switch error?._code {
                case canceledLoginCode:
                    authorizationError = AuthorizationError(type: .userExitedFlow, errorDescription: "User exited flow before authorizing vehicles")
                default:
                    authorizationError = AuthorizationError(type: .unknownError)
            }
            return self.completionHandler(nil, nil, authorizationError)
        }
        handleCallback(callbackUrl: callback)
    }
    
    /**
    Authorization callback function. Verifies that no error occured during the OAuth process and extracts the auth code and state string upon success. Invokes the completion function with either the code or an error (and state if included).
    - parameters:
        - url: callback URL containing authorization code or an error
    */
    public func handleCallback(callbackUrl: URL) {
        let authorizationError: AuthorizationError
        
        let urlComp = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
        guard let query = urlComp?.queryItems else {
            authorizationError = AuthorizationError(type: .missingQueryParameters, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, nil, authorizationError)
        }
        
        let queryState = query.filter({$0.name == "state"}).first?.value!
        
        let vehicle: VehicleInfo?
        
        if let vin = query.filter({$0.name == "vin"}).first?.value {
            vehicle = VehicleInfo(vin: vin)
            if let make = query.filter({$0.name == "make"}).first?.value {
                vehicle?.make = make
            }
            if let model = query.filter({$0.name == "model"}).first?.value {
                vehicle?.model = model
            }
            if let year = query.filter({$0.name == "year"}).first?.value {
                vehicle?.year = NSNumber(value: Int(year)!)
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
                default:
                    authorizationError = AuthorizationError(type: .unknownError, errorDescription: errorDescription)
            }
            return self.completionHandler(nil, queryState, authorizationError)
        }

        guard let code = query.filter({$0.name == "code"}).first?.value else {
            let authorizationError = AuthorizationError(type: .missingAuthCode, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, queryState, authorizationError)
        }

        return self.completionHandler(code, queryState, nil)
    }
    
}

// Required if we want to provide a default browser window so that developers don't have to (so that they can  use launchWebAuthSession with the same interface regardless of iOS versioning)
@available(iOS 13, *)
extension SmartcarAuth: ASWebAuthenticationPresentationContextProviding {
    /**
        Provides a default window to act as the presentation anchor for the authentication session
     */
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first ?? ASPresentationAnchor()
    }
}

private protocol Session {
    @discardableResult
    func start() -> Bool
}

@available(iOS 12.0, *)
extension ASWebAuthenticationSession: Session {
}

@available(iOS 11.0, *)
extension SFAuthenticationSession: Session {
}
