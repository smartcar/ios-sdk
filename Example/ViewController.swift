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
        
        let smartCarRequest = SmartCarOAuthRequest(clientID: "c5937ac4-3634-49a6-806c-291e536d9910", redirectURI: "scc5937ac4-3634-49a6-806c-291e536d9910://page", scope: ["read_vehicle_info", "read_odometer"])
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.smartCarSDK = SmartCarOAuthSDK(request: smartCarRequest)
        let sdk = appDelegate.smartCarSDK
        ui = SmartCarOAuthButtonGenerator(sdk: sdk!, viewController: self)
        
        let button = ui!.generateButton(frame: CGRect(x: 0, y: 0, width: 250, height: 50), for: OEMName.acura)
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonPinMiddleX = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let buttonPinMiddleY = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.5, constant: 0)
        let buttonWidth = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        let buttonHeight = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)

        self.view.addConstraints([buttonPinMiddleX, buttonPinMiddleY, buttonWidth, buttonHeight])
        
        let image = UIImageView(image: UIImage(named: "logo")!)
        self.view.addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        let imPinMiddleX = NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let imPinMiddleY = NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.5, constant: 0)
        let imWidth = NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 350)
        
        self.view.addConstraints([imPinMiddleX, imPinMiddleY, imWidth])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

