//
//  SmartcarAuth.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/6/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import UIKit
import SafariServices

/**
    Smartcar Authentication SDK for iOS written in Swift 3.
        - Allows the ability to generate buttons to login with each manufacturer which launches the OAuth flow
        - Allows the ability to use dropdown/custom buttons to trigger OAuth flow
        - Facilitates the flow with a SFSafariViewController to redirect to Smartcar and retrieve an access code and an
            access token
*/

public class SmartcarAuth: NSObject {
    let request: SmartcarAuthRequest

    /**
        Constructor for the SmartcarAuth
     
        - parameters
            - request: SmartcarAuthRequest object for Smartcar API
    */
    public init(request: SmartcarAuthRequest) {
        self.request = request
    }
    
    /**
        Constructor for the SmartcarAuth
     
        - Parameters:
            - clientID: app client ID
            - redirectURI: app redirect URI
            - scope: app oauth scope
            - state: optional, oauth state
            - grantType: oauth grath type enum can be either "code" or "token", defaults to "code"
            - forcePrompt: forces permission screen if set to true, defaults to false
            - development: appends mock oem if true, defaults to false
    */
    public init(clientID: String, redirectURI: String, state: String = "", scope: [String], grantType: GrantType = GrantType.code, forcePrompt: Bool = false, development: Bool = false) {
        self.request = SmartcarAuthRequest(clientID: clientID, redirectURI: redirectURI, state: state, scope: scope, grantType: grantType, forcePrompt: forcePrompt, development: development)
    }
    
    /**
        Initializes the Authorization request and configures and return an SFSafariViewController with the correct
            authorization URL
     
        - Parameters
            - oem: OEMName object for the OEM
            - viewController: the viewController resposible for presenting the SFSafariView
    */
    public func initializeAuthorizationRequest(for oem: OEMName, viewController: UIViewController) {
        let authorizationURL = generateLink(for: oem)
        let safariVC = SFSafariViewController(url: URL(string: authorizationURL)!)
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    /**
        Generates the authorization request URL for a specific OEM from the request paramters (Not recommended for direct use. Use initializeAuthorizationRequest)
     
        - Parameters
            - oem: OEMName object for the OEM
        
        - Returns:
            authorization request URL for the specific OEM
    */
    public func generateLink(for oem: OEMName) -> String {
        var stateString = ""
        
        if self.request.state.characters.count > 0 {
            stateString = "&state=" + self.request.state
        }
        
        let redirectString = self.request.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let scopeString = self.request.scope.joined(separator: " ")
            .addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        return "https://\(oem.stringValue).smartcar.com/oauth/authorize?response_type=\(self.request.grantType.stringValue)&client_id=\(self.request.clientID)&redirect_uri=\(redirectString)&scope=\(scopeString)&approval_prompt=\(self.request.approvalType.rawValue + stateString)";
    }
    
    /**
        Authorization callback function. Verifies the state parameter of the URL matches the request state parameter and extract the authorization code
     
        - Parameters
            - url: callback URL containing authorization code
     
        - Returns:
            true if authorization code was successfully extracted
    */
    public func resumeAuthorizationFlow(with url: URL) throws -> String {
        let urlComp = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = urlComp?.queryItems
        
        if let code = query?[0].value {
            if let state = query?[1].value {
                if state != self.request.state {
                    throw AuthorizationError.invalidState
                }
                return code
            } else {
                throw AuthorizationError.missingState
            }
        } else {
            throw AuthorizationError.missingURL
        }
    }
}
