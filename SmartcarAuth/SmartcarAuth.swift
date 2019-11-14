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
@objc public class SmartcarAuth: NSObject {
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
        - clientId: app client id
        - redirectUri: app redirect uri
        - scope: app oauth scope
        - testMode: optional, launch the Smartcar auth flow in test mode, defaults to nil.
        - completion: callback function called upon the completion of the OAuth flow with the auth code, the state string, and the error
    */
    @objc public init(clientId: String, redirectUri: String, completionHandler: @escaping (String?, String?, AuthorizationError?) -> Void, scope: [String] = [], testMode: Bool = false) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.testMode = testMode
        self.completionHandler = completionHandler
    }
    
    /**
       Presents a SFSafariViewController with the initial authorization url. Should only be used in iOS 10 and under
       - parameters:
           - authUrl: the authorization url that the user the browser opens
           - viewController: the viewController responsible for presenting the SFSafariView
       */
    @objc public func launchAuthFlow(authUrl: URL, viewController: UIViewController) {
        let safariVC = SFSafariViewController(url: authUrl)
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    /**
    Presents an ASWebAuthenticationSession or SFAuthenticationSession with the initial authorization url
    - parameters:
        - authUrl: the authorization url that the user the browser opens
        - redirectUriScheme: the custom uri scheme that the application can expect the redirect uri to be in
    */
    @objc public func launchWebAuthSession(authUrl: URL, redirectUriScheme: String) {
        if #available(iOS 12.0, *) {
            let authSession = ASWebAuthenticationSession.init(url: authUrl, callbackURLScheme: redirectUriScheme, completionHandler: webAuthSessionCompletion)
            self.session = authSession
            // this is required for the browser to open in iOS 13
            if #available(iOS 13.0, *) {
                authSession.presentationContextProvider = self
            }
        } else if #available(iOS 11.0, *) {
            let authSession = SFAuthenticationSession.init(url: authUrl, callbackURLScheme: redirectUriScheme, completionHandler: webAuthSessionCompletion)
            self.session = authSession
        }
        self.session?.start()
    }

    
    /**
    Authorization callback function. Verifies that no error occured during the OAuth process and calls handleCallback, which extracts the auth code and state string
    - parameters:
        - callback: callback URL containing authorization code
        - error: error that comes back if user cancels mid authorization flow or
    */
    @objc private func webAuthSessionCompletion(callback: URL?, error: Error?) -> Void {
        var authorizationError: AuthorizationError? = nil
        guard error == nil, let successUrl = callback else {
            let canceledLoginCode: Int?
            if #available(iOS 12.0, *) {
                canceledLoginCode = ASWebAuthenticationSessionError.canceledLogin.rawValue
            } else if #available(iOS 11.0, *) {
                canceledLoginCode = SFAuthenticationError.canceledLogin.rawValue
            } else {
                canceledLoginCode = nil
            }
            
            if let error = error {
                switch error._code {
                case canceledLoginCode:
                    authorizationError = AuthorizationError(type: .userExitedFlow, errorDescription: "User exited flow before authorizing vehicles")
                    default:
                        authorizationError = AuthorizationError(type: .unknownError)
                }
            } else {
                authorizationError = AuthorizationError(type: .unknownError)
            }
            
            return self.completionHandler(nil, nil, authorizationError)
        }
        handleCallback(successUrl: successUrl)
    }
    
    /**
    Authorization callback function. Verifies that no error occured during the OAuth process and extracts the auth code and state string. Invokes the completion function with the appropriate parameters.
    - parameters:
        - url: callback URL containing authorization code
    - returns:
    the output of the executed completion function
    */
    @objc public func handleCallback(successUrl: URL) {
        let authorizationError: AuthorizationError
        
        let urlComp = URLComponents(url: successUrl, resolvingAgainstBaseURL: false)
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
                vehicle?.year = NSNumber(pointer: year)
            }
        } else {
            vehicle = nil
        }
        
        let error = query.filter({ $0.name == "error"}).first?.value
        
        if (error != nil) {
            let errorDescription = query.filter({$0.name == "error_description"}).first?.value
            switch (error) {
                case "vehicle_incompatible":
                    authorizationError = AuthorizationError(type: .vehicleIncompatible, errorDescription: errorDescription, vehicleInfo: vehicle)
                case "invalid_subscription":
                    authorizationError = AuthorizationError(type: .subscriptionInactive, errorDescription: errorDescription)
                default:
                    authorizationError = AuthorizationError(type: .accessDenied, errorDescription: errorDescription)
            }
            return self.completionHandler(nil, queryState, authorizationError)
        }

        guard let code = query.filter({ $0.name == "code"}).first?.value else {
            let authorizationError = AuthorizationError(type: .missingAuthCode, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, queryState, authorizationError)
        }

        return self.completionHandler(code, queryState, nil)
    }
    
}

// Required if we want to provide a default browser window so that developers don't have to (so that they can  use launchWebAuthSession the same regardless of iOS versioning)
@available(iOS 13, *)
extension SmartcarAuth: ASWebAuthenticationPresentationContextProviding {
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
