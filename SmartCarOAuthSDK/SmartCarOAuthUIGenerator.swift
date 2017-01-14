//
//  SmartCarOAuthUIGenerator.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/12/17.
//  Copyright © 2017 Ziyu Zhang. All rights reserved.
//

import UIKit

/**
    Base class for SmartCar OAuthorization UI Generation. Designed to be abstract, therefore not instantiated.
 */

class SmartCarOAuthUIGenerator: NSObject {
    let sdk: SmartCarOAuthSDK
    let viewController: UIViewController
    
    init(sdk: SmartCarOAuthSDK, viewController: UIViewController) {
        self.sdk = sdk
        self.viewController = viewController
    }

}
