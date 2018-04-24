//
//  SmartcarAuth.swift
//  SmartcarAuth
//
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import UIKit
import SafariServices

let domain = "connect.smartcar.com"

/**
Smartcar Authentication SDK for iOS written in Swift 3.
    - Facilitates the flow with a SFSafariViewController to redirect to Smartcar and retrieve an authorization code
*/

public class SmartcarAuth: NSObject {
    
    var clientId: String
    var redirectUri: String
    var scope: [String]
    var completion: (Error?, String?, String?) -> Any?

    /**
    Constructor for the SmartcarAuth

    - parameters:
        - clientId: app client id
        - redirectUri: app redirect uri
        - scope: app oauth scope
        - completion: callback function called upon the completion of the OAuth flow with the error, the auth code, and the state string
    */
    public init(clientId: String, redirectUri: String, scope: [String] = [], completion: @escaping (Error?, String?, String?) -> Any?) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.completion = completion
    }

    /**
    Presents a SFSafariViewController with the initial authorization url

    - parameters:
        - state: optional, oauth state
        - forcePrompt: optional, forces permission screen if set to true, defaults to false
        - showMock: optional, shows the mock OEM for testing, defaults to false
        - viewController: the viewController resposible for presenting the SFSafariView
    */
    public func launchAuthFlow(state: String = "", forcePrompt: Bool = false, showMock: Bool = false, viewController: UIViewController) {
        
        let safariVC = SFSafariViewController(url: URL(string: generateUrl(state: state, forcePrompt: forcePrompt, showMock: showMock))!)
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    /**
     Generates the authorization request URL from the authorization parameters
     
     - parameters:
        - state: oauth state
        - forcePrompt: forces permission screen if set to true, defaults to false
        - showMock: shows the mock OEM for testing, defaults to false
     
     - returns:
     authorization request URL
     
     */
    public func generateUrl(state: String, forcePrompt: Bool, showMock: Bool) -> String {
        var components = URLComponents(string: "https://\(domain)/oauth/authorize")!
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "response_type", value: "code"))
        queryItems.append(URLQueryItem(name: "client_id", value: self.clientId))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: self.redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))
        
        if !scope.isEmpty {
            queryItems.append(URLQueryItem(name: "scope", value: self.scope.joined(separator: " ").addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!))
        }
        
        queryItems.append(URLQueryItem(name: "approval_prompt", value: forcePrompt ? "force" : "auto"))
        
        if state != "" {
            queryItems.append(URLQueryItem(name: "state", value: state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))
        }
        
        queryItems.append(URLQueryItem(name: "mock", value: showMock ? "true" : "false"))
        
        components.queryItems = queryItems
        
        return components.url!.absoluteString
    }

    /**
    Authorization callback function. Verifies that no error occured during the OAuth process and extracts the auth code and state string. Returns the call to the completion callback.

    - parameters:
        - url: callback URL containing authorization code

    - returns:
    the output of the executed completion function
    */
    
    public func resumeAuthFlow(with url: URL) -> Any {
        let urlComp = URLComponents(url: url, resolvingAgainstBaseURL: false)
    
        guard let query = urlComp?.queryItems else {
            return completion(AuthorizationError.missingURL, nil, nil)
        }

        guard let code = query.filter({ $0.name == "code"}).first?.value else {
            return completion(AuthorizationError.missingURL, nil, nil)
        }
        
        let queryState = query.filter({ $0.name == "state"}).first?.value
        
        return completion(nil, code, queryState)
    }
}
