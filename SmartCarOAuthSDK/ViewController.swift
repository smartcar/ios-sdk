//
//  ViewController.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/6/17.
//  Copyright © 2017 Ziyu Zhang. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let smartCarRequest = SmartCarOAuthRequest(clientID: "b4503a8c-5acc-41d3-a9b7-07fc6dfd4c76", redirectURI: "https://www.gmail.com", scope: ["read_vehicle_info", "read_odometer"], development: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.smartCarSDK = SmartCarOAuthSDK(request: smartCarRequest, viewController: self)
        let sdk = appDelegate.smartCarSDK
        
        let button = sdk!.generatePicker(in: self.view.subviews[1])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

