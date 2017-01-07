//
//  SmartCarOAuthSDK.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/6/17.
//  Copyright © 2017 Ziyu Zhang. All rights reserved.
//

import UIKit
import SafariServices

// An array of all currently supported OEMs as OEM objects
let defaultOEM = [OEM(oemName: OEMName.acura), OEM(oemName: OEMName.audi), OEM(oemName: OEMName.bmw), OEM(oemName: OEMName.bmwConnected), OEM(oemName: OEMName.buick), OEM(oemName: OEMName.cadillac), OEM(oemName: OEMName.chevrolet), OEM(oemName: OEMName.chrysler), OEM(oemName: OEMName.dodge), OEM(oemName: OEMName.fiat), OEM(oemName: OEMName.ford), OEM(oemName: OEMName.gmc), OEM(oemName: OEMName.hyundai), OEM(oemName: OEMName.infiniti), OEM(oemName: OEMName.jeep), OEM(oemName: OEMName.kia), OEM(oemName: OEMName.landrover), OEM(oemName: OEMName.lexus), OEM(oemName: OEMName.mercedes), OEM(oemName: OEMName.nissan), OEM(oemName: OEMName.nissanev), OEM(oemName: OEMName.ram), OEM(oemName: OEMName.tesla), OEM(oemName: OEMName.volkswagen), OEM(oemName: OEMName.volvo)]

/**
    SmartCar Authentication API for iOS written in Swift 3.
        - Allows the ability to generate buttons to login with each manufacturer which launches the OAuth flow
        - Allows the ability to use dropdown/custom buttons to trigger OAuth flow
        - Facilitates the flow with a SFSafariViewController to redirect to SmartCar and retrieve an access code and an access token
*/
class SmartCarOAuthSDK {
    let clientID: String // app client ID
    let redirectURI: String //app redirect URI
    let scope: [String] //app oauth scope
    let state: String? // oauth state
    let grantType: GrantType //oauth grant type enum
    let approvalType: ApprovalType // force permission screen of ApprovalType enum
    let development: Bool // appends mock oem if true
    
    /**
        Initializes the SmartCarOAuthSDK Object
        
        - Parameters:
            - clientID: app client ID
            - redirectURI: app redirect URI
            - scope: app oauth scope
            - state: optional, oauth state
            - grantType: oauth grath type enum can be either "code" or "token", defaults to "code"
            - forcePrompt: forces permission screen if set to true, defaults to false
            - development: appends mock oem if true, defaults to false
    */
    init(clientID: String, redirectURI: String, scope: [String], state: String?, grantType: GrantType = GrantType.code, forcePrompt: Bool = false, development: Bool = false) {
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.scope = scope
        self.grantType = grantType
        self.approvalType = forcePrompt ? ApprovalType.force : ApprovalType.auto
        self.development = development
        self.state = state
    }
    
    func generateButtons(for oems: [OEM] = defaultOEM) -> [UIButton] {
        var buttons: [UIButton] = []
        var yPosition = 100
        
        for o in oems {
            let button = UIButton(frame: CGRect(x: 20, y: yPosition, width: 300, height: 50))
            button.backgroundColor = hexStringToUIColor(hex: o.oemConfig.color)
            button.setTitle("LOGIN WITH " + o.oemName.rawValue, for: .normal)
            buttons.append(button)
            yPosition += 50
        }
        
        return buttons
    }
    
    func generateLink(for oem: OEM) -> String {
        var stateString = ""
        
        if let s = self.state {
            stateString = "&state=" + s
        }
        
        let redirectString = self.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let scopeString = self.scope.joined(separator: " ").addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        return "https://\(oem.oemName.rawValue).smartcar.com/oauth/authorize?response_type=\(self.grantType.rawValue)&client_id=\(self.clientID)&redirect_uri=\(redirectString)&scope=\(scopeString)&approval_prompt=\(self.approvalType.rawValue + stateString)";
    }
    
    func initializeAuthorizationRequest(for oem: OEM) -> SFSafariViewController {
        let authorizationURL = generateLink(for: oem)
        
        return SFSafariViewController(url: URL(string: authorizationURL)!)
    }
    
    func resumeAuthorizationFlowWithURL(url: URL) {
        
    }
}
