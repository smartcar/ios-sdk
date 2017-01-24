//
//  SmartcarAuthUIGenerator.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/12/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import UIKit

/**
    Base class for Smartcar Authorization UI Generation. Designed to be abstract, therefore not instantiated.
 */

public class SmartcarAuthUIGenerator: NSObject {
    let sdk: SmartcarAuth
    let viewController: UIViewController
    
    public init(sdk: SmartcarAuth, viewController: UIViewController) {
        self.sdk = sdk
        self.viewController = viewController
    }

}
