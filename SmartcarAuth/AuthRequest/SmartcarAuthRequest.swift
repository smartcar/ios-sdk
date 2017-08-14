//
//  SmartcarAuthRequest.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/7/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Foundation

/**
    Class encapsulating the data required within a Smartcar Authorization Request
 */

@objc public class SmartcarAuthRequest: NSObject {
    let clientID: String // app client ID
    let redirectURI: String //app redirect URI
    let scope: [String] //app oauth scope
    let state: String // oauth state
    let grantType: GrantType //oauth grant type enum
    let approvalType: ApprovalType // force permission screen of ApprovalType enum
    let development: Bool // appends mock oem if true
    
    /**
     Initializes the SmartcarAuth Object
     
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
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.scope = scope
        self.grantType = grantType
        self.approvalType = forcePrompt ? ApprovalType.force : ApprovalType.auto
        self.development = development
        self.state = state
    }
}
