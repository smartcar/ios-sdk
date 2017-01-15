//
//  ViewController.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/6/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

import UIKit
import SmartCarOAuthSDK

class ViewController: UIViewController {
    
    var ui: SmartCarOAuthButtonGenerator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.smartCarSDK = SmartCarOAuthSDK(request: smartCarRequest)
        let sdk = appDelegate.smartCarSDK
        ui = SmartCarOAuthButtonGenerator(sdk: sdk!, viewController: self)
        
        let button = ui!.generateButton(for: OEM(oemName: OEMName.mock), in: self.view.subviews[0])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

