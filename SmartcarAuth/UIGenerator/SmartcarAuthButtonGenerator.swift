//
//  SmartcarAuthButtonGenerator.swift
//  SmartcarAuthSDK
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 Smartcar Inc.. All rights reserved.
//

import UIKit

/**
    Class for generating buttons to automatically initialize the authentication flow
 */

public class SmartcarAuthButtonGenerator: SmartcarAuthUIGenerator {
    var oem: OEMName?
    
    override public init(sdk: SmartcarAuth, viewController: UIViewController) {
        super.init(sdk: sdk, viewController: viewController)
    }
    
    /**
        Generate and displayes a single button for a OEM that resides in the specific UIView provided
     
        - Parameters: 
            - for: the OEM that the button will open the authentication flow for
            - frame: CGRect object that determines the position and size of the button
     */
    public func generateButton(frame: CGRect, for oem: OEMName) -> UIButton {
        self.oem = oem
        let button = UIButton()
        button.frame = frame
        button.backgroundColor = OEM.getColor(for: oem)
        button.setTitle("LOGIN WITH " + OEM.getDisplayName(for: oem).uppercased(), for: .normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let img = UIImage(named: "SmartcarAuthResources.bundle/" + oem.rawValue + "_logo.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        button.setImage(img, for: .normal)
        
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -(img!.size.width - (frame.maxX - (frame.maxX - frame.maxY + 5))), 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, frame.maxX - frame.maxY + 5)
        
        button.addTarget(self, action: #selector(oemButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    /**
        Action method for the generated OEM button that initiates the authentication flow
    */
    @objc func oemButtonPressed(_ sender: UIButton) {
        self.sdk.initializeAuthorizationRequest(for: self.oem!, viewController: viewController)
    }
}
