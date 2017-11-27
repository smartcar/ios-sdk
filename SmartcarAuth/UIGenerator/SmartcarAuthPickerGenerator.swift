//
//  SmartcarAuthPickerGenerator.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import UIKit

/**
    Class to generate pickers to automatically initialize authentication flow for multiple OEMs
 */

public class SmartcarAuthPickerGenerator: SmartcarAuthUIGenerator, UIPickerViewDelegate, UIPickerViewDataSource {
    // List of OEMs within the picker. Defaults to a list of all OEMs
    var oemList = OEM.getDefaultOEMList()
    // UIPickerView object
    var picker = UIPickerView()
    // UIToolbar object that resides above the picker
    var toolBar = UIToolbar()
    // Invisible button to signal that outside the picker has been clicked
    var invisButton = UIButton()
    // Constraint attaching picker to bottom
    var pickerPinBottom: NSLayoutConstraint?
    // Constraint attaching toolbar to bottom
    var toolbarPinBottom: NSLayoutConstraint?
    
    public convenience init(sdk: SmartcarAuth, viewController: UIViewController, oem: [Int]?) {
        var oemList = OEM.getDefaultOEMList()
        if let oem = oem {
            oemList = oem.flatMap{ OEMName(rawValue: $0) }
        }
        self.init(sdk: sdk, viewController: viewController, oemList: oemList)
    }
    
    public init(sdk: SmartcarAuth, viewController: UIViewController, oemList: [OEMName] = OEM.getDefaultOEMList()){
        super.init(sdk: sdk, viewController: viewController)
        self.oemList = oemList.sortedByDisplayName()
        
        if sdk.request.development {
            self.oemList.append(OEMName.mock)
        }
    }
    
    /**
        Generates and displays the initial button which displays the UIPickerView when pressed
     
        - Parameters:
            - frame: CGRect object that determins the location and size of the button
            - with: color of the initial button. Defaults to black
     */
    
    public func generatePicker(frame: CGRect, with color: UIColor = .black) -> UIButton {
        let button = UIButton()
        button.frame = frame
        button.backgroundColor = color
        button.setTitle("CONNECT A VEHICLE", for: .normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(pickerButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    /**
        Action methods for the pressing of the initial picker button. Formats and displays the UIPickerView, UIToolbar, and the invisible button
    */
    @objc public func pickerButtonPressed() {
        self.picker = UIPickerView()
        self.picker.dataSource = self
        self.picker.delegate = self
        self.picker.translatesAutoresizingMaskIntoConstraints = false
        self.picker.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.toolBar = UIToolbar()
        self.toolBar.backgroundColor = UIColor(white: 1, alpha: 1)
        self.toolBar.translatesAutoresizingMaskIntoConstraints = false
        let doneButton = UIBarButtonItem(title: "Connect", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        self.toolBar.setItems([spaceButton, doneButton], animated: false)
        self.toolBar.isUserInteractionEnabled = true
        
        self.invisButton = UIButton()
        self.invisButton.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.invisButton.addTarget(self, action: #selector(hidePickerView), for: .touchUpInside)
        self.invisButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewController.view.addSubview(self.invisButton)
        self.viewController.view.addSubview(self.picker)
        self.viewController.view.addSubview(self.toolBar)
        
        //Format constraints for autolayout
        pickerPinBottom = NSLayoutConstraint(item: self.picker, attribute: .bottom, relatedBy: .equal, toItem: self.viewController.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pickerHeight = NSLayoutConstraint(item: self.picker, attribute: .height, relatedBy: .equal, toItem: self.viewController.view, attribute: .height, multiplier: 0.33, constant: 0)
        let pickerWidth = NSLayoutConstraint(item: self.picker, attribute: .width, relatedBy: .equal, toItem: self.viewController.view, attribute: .width, multiplier: 1, constant: 0)
        let pickerLeft = NSLayoutConstraint(item: self.picker, attribute: .leading, relatedBy: .equal, toItem: self.viewController.view, attribute: .leading, multiplier: 1, constant: 0)
        toolbarPinBottom = NSLayoutConstraint(item: self.toolBar, attribute: .top, relatedBy: .equal, toItem: self.viewController.view, attribute: .bottom, multiplier: 1, constant: 0)
        let toolbarPinToPicker = NSLayoutConstraint(item: self.toolBar, attribute: .bottom, relatedBy: .equal, toItem: self.picker, attribute: .top, multiplier: 1.0, constant: 0)
        let toolbarWidth = NSLayoutConstraint(item: self.toolBar, attribute: .width, relatedBy: .equal, toItem: self.viewController.view, attribute: .width, multiplier: 1, constant: 0)
        let toolbarLeft = NSLayoutConstraint(item: self.toolBar, attribute: .leading, relatedBy: .equal, toItem: self.viewController.view, attribute: .leading, multiplier: 1, constant: 0)
        let invisButtonPinTop = NSLayoutConstraint(item: self.invisButton, attribute: .top, relatedBy: .equal, toItem: self.viewController.view, attribute: .top, multiplier: 1.0, constant: 0)
        let invisButtonPinBottom = NSLayoutConstraint(item: self.invisButton, attribute: .bottom, relatedBy: .equal, toItem: self.viewController.view, attribute: .bottom, multiplier: 1, constant: 0)
        let invisButtonWidth = NSLayoutConstraint(item: self.invisButton, attribute: .width, relatedBy: .equal, toItem: self.viewController.view, attribute: .width, multiplier: 1, constant: 0)
        let invisButtonLeft = NSLayoutConstraint(item: self.invisButton, attribute: .leading, relatedBy: .equal, toItem: self.viewController.view, attribute: .leading, multiplier: 1, constant: 0)
        
        self.viewController.view.addConstraints([pickerHeight, pickerWidth, pickerLeft, toolbarPinToPicker, toolbarWidth, toolbarLeft, invisButtonPinTop, invisButtonWidth, invisButtonPinBottom, invisButtonLeft])
        
        //Setup initial state
        self.viewController.view.addConstraint(toolbarPinBottom!)
        self.viewController.view.layoutIfNeeded()
        self.invisButton.alpha = 0
        
        //Animate appearance
        UIView.animate(withDuration: 0.3) {
            self.viewController.view.removeConstraint(self.toolbarPinBottom!)
            self.viewController.view.addConstraint(self.pickerPinBottom!)
            self.viewController.view.layoutIfNeeded()
            self.invisButton.alpha = 1
        }
    }
    
    /**
        Initializes the authentication flow with the selected picker value
    */
    @objc func donePicker() {
        hidePickerView()
        let val = self.oemList[picker.selectedRow(inComponent: 0)]
        
        self.sdk.initializeAuthorizationRequest(for: val, viewController: self.viewController)
    }
    
    /**
        Hides the picker, invisButton, and toolBar
    */
    @objc func hidePickerView() {
        viewController.view.layoutIfNeeded()
        
        //Animate disappearance
        UIView.animate(withDuration: 0.3, animations: {
            self.viewController.view.removeConstraint(self.pickerPinBottom!)
            self.viewController.view.addConstraint(self.toolbarPinBottom!)
            self.viewController.view.layoutIfNeeded()
            self.invisButton.alpha = 0
        }, completion: { _ in
            self.invisButton.removeFromSuperview()
            self.picker.removeFromSuperview()
            self.toolBar.removeFromSuperview()
        })
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.oemList.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return OEM.getDisplayName(for: self.oemList[row])
    }
}
