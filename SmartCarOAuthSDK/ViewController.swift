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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let sdk = appDelegate.sdk
        let safariVC = sdk.initializeAuthorizationRequest(for: OEM(oemName: OEMName.acura))
        self.present(safariVC, animated: true, completion: nil)
    }
    
}

