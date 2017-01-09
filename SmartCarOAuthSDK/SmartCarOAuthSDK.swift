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
let defaultOEM = [OEM(oemName: OEMName.acura), OEM(oemName: OEMName.audi), OEM(oemName: OEMName.bmw),
                  OEM(oemName: OEMName.bmwConnected), OEM(oemName: OEMName.buick), OEM(oemName: OEMName.cadillac),
                  OEM(oemName: OEMName.chevrolet), OEM(oemName: OEMName.chrysler), OEM(oemName: OEMName.dodge),
                  OEM(oemName: OEMName.fiat), OEM(oemName: OEMName.ford), OEM(oemName: OEMName.gmc),
                  OEM(oemName: OEMName.hyundai), OEM(oemName: OEMName.infiniti), OEM(oemName: OEMName.jeep),
                  OEM(oemName: OEMName.kia), OEM(oemName: OEMName.landrover), OEM(oemName: OEMName.lexus),
                  OEM(oemName: OEMName.mercedes), OEM(oemName: OEMName.nissan), OEM(oemName: OEMName.nissanev),
                  OEM(oemName: OEMName.ram), OEM(oemName: OEMName.tesla), OEM(oemName: OEMName.volkswagen),
                  OEM(oemName: OEMName.volvo)]

/**
    SmartCar Authentication API for iOS written in Swift 3.
        - Allows the ability to generate buttons to login with each manufacturer which launches the OAuth flow
        - Allows the ability to use dropdown/custom buttons to trigger OAuth flow
        - Facilitates the flow with a SFSafariViewController to redirect to SmartCar and retrieve an access code and an 
            access token
*/

class SmartCarOAuthSDK: NSObject {
    let request: SmartCarOAuthRequest
    //Access code for the current request, is nil if request has not been completed
    var code: String?
    
    /**
        Constructor for the SmartCarOAuthSDK
     
        - Parameter request: SmartCarOAuthRequest object for SmartCar API
    */
    init(request: SmartCarOAuthRequest) {
        self.request = request
    }
    
    func generateButton(for oem: OEM, in view: UIView) -> UIButton {
        let button = UIButton(frame: view.frame)
        button.backgroundColor = hexStringToUIColor(hex: oem.oemConfig.color)
        button.setTitle("LOGIN WITH " + oem.oemName.rawValue.uppercased(), for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        view.addSubview(button)
        return button
    }
    
    @objc func buttonPressed() {
        print("Pressed")
    }
    
    func generatePicker(for oems: [OEM] = defaultOEM, in view: UIView, with color: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) -> UIButton {
        let button = UIButton(frame: view.frame)
        button.backgroundColor = color
        button.setTitle("CONNECT VEHICLES", for: .normal)
        
        view.addSubview(button)
        return button
    }
    
    /**
        Initializes the Authorization request and configures and return an SFSafariViewController with the correct 
            authorization URL
     
        - Parameter oem: OEM object to identify the oem name within the authorization request URL
     
        - Returns: SFSafariViewController object configured with the authorization URL corresponding to the request 
            paramters and the provide OEM
    */
    func initializeAuthorizationRequest(for oem: OEM) -> SFSafariViewController {
        let authorizationURL = generateLink(for: oem)
        
        return SFSafariViewController(url: URL(string: authorizationURL)!)
    }
    
    /**
        Generates the authorization request URL for a specific OEM from the request paramters
     
        - Parameter oem: OEM object to identify the oem name within the authorization request URL
        
        - Returns: authorization request URL for the specific OEM
    */
    func generateLink(for oem: OEM) -> String {
        let stateString = self.request.state
        
        let redirectString = self.request.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let scopeString = self.request.scope.joined(separator: " ")
            .addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        return "https://\(oem.oemName.rawValue).smartcar.com/oauth/authorize?response_type=\(self.request.grantType.rawValue)&client_id=\(self.request.clientID)&redirect_uri=\(redirectString)&scope=\(scopeString)&approval_prompt=\(self.request.approvalType.rawValue + stateString)";
    }
    
    /**
        Authorization callback function. Verifies the state parameter of the URL matches the request state paramter and 
            extract the authorization code
     
        - Parameter url: callback URL containing authorization code
     
        - Return: true if authorization code was successfully extracted
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
