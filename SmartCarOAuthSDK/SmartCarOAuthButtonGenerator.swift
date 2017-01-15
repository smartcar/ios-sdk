//
//  SmartCarOAuthButtonGenerator.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 SmartCar Inc.. All rights reserved.
//

import UIKit

/**
    Class for generating buttons to automatically initialize the authentication flow
 */

public class SmartCarOAuthButtonGenerator: SmartCarOAuthUIGenerator {
    override public init(sdk: SmartCarOAuthSDK, viewController: UIViewController) {
        super.init(sdk: sdk, viewController: viewController)
    }
    
    /**
        Generate and displayes a single button for a OEM that resides in the specific UIView provided
     
        - parameters: 
            - for: the OEM that the button will open the authentication flow for
            - in: UIView object that the button will reside and fill
        
        - returns:
            the button that was generated
    */
    public func generateButton(for oem: OEM, in view: UIView) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        button.backgroundColor = hexStringToUIColor(hex: oem.oemConfig.color)
        button.setTitle("LOGIN WITH " + oem.oemName.rawValue.uppercased(), for: .normal)
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(oemButtonPressed(_:)), for: .touchUpInside)
        
        view.addSubview(button)
        return button
    }
    
    /**
        Action method for the generated OEM button that initiates the authentication flow
    */
    @objc func oemButtonPressed(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        let name = title!.substring(from: title!.index(title!.startIndex, offsetBy: 11))
        
        self.sdk.initializeAuthorizationRequest(for: OEM(oemName: OEMName(rawValue: name.lowercased())!), viewController: viewController)
    }
}
