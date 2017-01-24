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
        
        let smartCarRequest = SmartCarOAuthRequest(clientID: "7cc72cc2-6464-4245-9fed-b971361a820e", redirectURI: "sc7cc72cc2-6464-4245-9fed-b971361a820e://page", scope: ["read_vehicle_info", "read_odometer"])
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.smartCarSDK = SmartCarOAuthSDK(request: smartCarRequest)
        let sdk = appDelegate.smartCarSDK
        ui = SmartCarOAuthButtonGenerator(sdk: sdk!, viewController: self)
        
        let button = ui!.generateButton(frame: CGRect(x: 0, y: 0, width: 250, height: 50), for: OEMName.mock)
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
    
    func accessCodeRecieved() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let sdk = appDelegate.smartCarSDK

        let label = UILabel()
        label.text = "Access code is " + sdk!.code!
        label.numberOfLines = 2
        
        self.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let labelPinMiddleX = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let labelPinMiddleY = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0)
        let labelWidth = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 350)
        let labelHeight = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        
         self.view.addConstraints([labelPinMiddleX, labelPinMiddleY, labelWidth, labelHeight])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

