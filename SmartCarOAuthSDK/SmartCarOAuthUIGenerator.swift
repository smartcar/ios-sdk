//
//  SmartCarOAuthUIGenerator.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/12/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

import UIKit

/**
    Base class for SmartCar OAuthorization UI Generation. Designed to be abstract, therefore not instantiated.
 */

public class SmartCarOAuthUIGenerator: NSObject {
    let sdk: SmartCarOAuthSDK
    let viewController: UIViewController
    
    public init(sdk: SmartCarOAuthSDK, viewController: UIViewController) {
        self.sdk = sdk
        self.viewController = viewController
    }

}
