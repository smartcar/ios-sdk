//
//  SmartCarOAuthSDK.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/6/17.
//  Copyright © 2017 Ziyu Zhang. All rights reserved.
//

import UIKit
import SafariServices

/**
    SmartCar Authentication SDK for iOS written in Swift 3.
        - Allows the ability to generate buttons to login with each manufacturer which launches the OAuth flow
        - Allows the ability to use dropdown/custom buttons to trigger OAuth flow
        - Facilitates the flow with a SFSafariViewController to redirect to SmartCar and retrieve an access code and an 
            access token
*/

class SmartCarOAuthSDK {
    let request: SmartCarOAuthRequest
    //Access code for the current request, is nil if request has not been completed
    var code: String?
    
    /**
        Constructor for the SmartCarOAuthSDK
     
        - parameters
            - request: SmartCarOAuthRequest object for SmartCar API
    */
    init(request: SmartCarOAuthRequest) {
        self.request = request
    }
    
    /**
        Initializes the Authorization request and configures and return an SFSafariViewController with the correct 
            authorization URL
     
        - parameters
            - oem: OEM object to identify the oem name within the authorization request URL
    */
    func initializeAuthorizationRequest(for oem: OEM, viewController: UIViewController) {
        let authorizationURL = generateLink(for: oem)
        let safariVC = SFSafariViewController(url: URL(string: authorizationURL)!)
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    /**
        Generates the authorization request URL for a specific OEM from the request paramters
     
        - parameters
            - oem: OEM object to identify the oem name within the authorization request URL
        
        - returns:
            authorization request URL for the specific OEM
    */
    func generateLink(for oem: OEM) -> String {
        let stateString = self.request.state
        
        let redirectString = self.request.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let scopeString = self.request.scope.joined(separator: " ")
            .addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        return "https://\(oem.oemName.rawValue).smartcar.com/oauth/authorize?response_type=\(self.request.grantType.rawValue)&client_id=\(self.request.clientID)&redirect_uri=\(redirectString)&scope=\(scopeString)&approval_prompt=\(self.request.approvalType.rawValue + stateString)";
    }
    
    /**
        Authorization callback function. Verifies the state parameter of the URL matches the request state parameter and
            extract the authorization code
     
        - parameters 
            - url: callback URL containing authorization code
     
        - returns:
            true if authorization code was successfully extracted
    */
    func resumeAuthorizationFlowWithURL(url: URL) -> Bool {
        let urlString = url.absoluteString
        let urlArray = urlString.components(separatedBy: "?")[1].components(separatedBy: "&")
        
        if urlArray.count > 1 {
            if(urlArray[1].substring(from: urlArray[1].index(urlArray[1].startIndex, offsetBy: 6)) != self.request.state) {
                return false
            }
        }
        
        self.code = urlArray[0].substring(from: urlArray[0].index(urlArray[0].startIndex, offsetBy: 5))
        
        return true
    }
}
