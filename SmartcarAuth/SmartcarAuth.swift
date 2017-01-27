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

public class SmartcarAuth {
    let request: SmartcarAuthRequest
    //Access code for the current request, is nil if request has not been completed
    var code: String?
    
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
    public init(clientID: String, redirectURI: String, scope: [String], grantType: GrantType = GrantType.code, forcePrompt: Bool = false, development: Bool = false) {
        self.request = SmartcarAuthRequest(clientID: clientID, redirectURI: redirectURI, scope: scope, grantType: grantType, forcePrompt: forcePrompt, development: development)
    }
    
    /**
        Initializes the Authorization request and configures and return an SFSafariViewController with the correct
            authorization URL
     
        - parameters
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
     
        - parameters
            - oem: OEMName object for the OEM
        
        - returns:
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
        
        return "https://\(oem.rawValue).smartcar.com/oauth/authorize?response_type=\(self.request.grantType.rawValue)&client_id=\(self.request.clientID)&redirect_uri=\(redirectString)&scope=\(scopeString)&approval_prompt=\(self.request.approvalType.rawValue + stateString)";
    }
    
    /**
        Authorization callback function. Verifies the state parameter of the URL matches the request state parameter and
            extract the authorization code
     
        - parameters 
            - url: callback URL containing authorization code
     
        - returns:
            true if authorization code was successfully extracted
    */
    public func resumeAuthorizationFlowWithURL(url: URL) -> Bool {
        let urlString = url.absoluteString
        
        if !urlString.contains("?") {
            return false
        }
        
        let urlArray = urlString.components(separatedBy: "?")[1].components(separatedBy: "&")
        
        if urlArray.count > 1 {
            let comp = urlArray[1].components(separatedBy: "=")
            if(comp[1] != self.request.state) {
                return false
            }
        }
        
        self.code = urlArray[0].substring(from: urlArray[0].index(urlArray[0].startIndex, offsetBy: 5))
        
        return true
    }
}
