//
//  OEMConfig.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/6/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

/**
    Class to store OEM specific configurations. Will be expanded in the future as more configurations are avaliable
 */

import UIKit

public class OEMConfig {
    // The default color of the OEM in Hex
    let color: UIColor
    let displayName: String
    
    init(color: String, displayName: String) {
        self.color = hexStringToUIColor(hex: color)
        self.displayName = displayName
    }
}
