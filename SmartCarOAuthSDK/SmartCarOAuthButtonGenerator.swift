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
    */
    public func generateButton(frame: CGRect, for oem: OEMName) -> UIButton {
        let button = UIButton()
        button.frame = frame
        button.backgroundColor = OEM.getColor(for: oem)
        button.setTitle("LOGIN WITH " + OEM.getDisplayName(for: oem).uppercased(), for: .normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(oemButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    /**
        Action method for the generated OEM button that initiates the authentication flow
    */
    @objc func oemButtonPressed(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        let name = title!.substring(from: title!.index(title!.startIndex, offsetBy: 11))
        
        self.sdk.initializeAuthorizationRequest(for: OEMName(rawValue: name.lowercased())!, viewController: viewController)
    }
}
