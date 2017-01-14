//
//  SmartCarOAuthPickerGenerator.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/14/17.
//  Copyright © 2017 Ziyu Zhang. All rights reserved.
//

import UIKit

// An array of all currently supported OEMs as OEM objects
let defaultOEM = [OEM(oemName: OEMName.acura), OEM(oemName: OEMName.audi), OEM(oemName: OEMName.bmw),
                  OEM(oemName: OEMName.bmwConnected), OEM(oemName: OEMName.buick), OEM(oemName: OEMName.cadillac),
                  OEM(oemName: OEMName.chevrolet), OEM(oemName: OEMName.chrysler), OEM(oemName: OEMName.dodge),
                  OEM(oemName: OEMName.fiat), OEM(oemName: OEMName.ford), OEM(oemName: OEMName.gmc),
                  OEM(oemName: OEMName.hyundai), OEM(oemName: OEMName.infiniti), OEM(oemName: OEMName.jeep),
                  OEM(oemName: OEMName.kia), OEM(oemName: OEMName.landrover), OEM(oemName: OEMName.lexus),
                  OEM(oemName: OEMName.mercedes), OEM(oemName: OEMName.nissan), OEM(oemName: OEMName.nissanev),
                  OEM(oemName: OEMName.ram), OEM(oemName: OEMName.tesla), OEM(oemName: OEMName.volkswagen),
                  OEM(oemName: OEMName.volvo)]

class SmartCarOAuthPickerGenerator: SmartCarOAuthUIGenerator, UIPickerViewDelegate, UIPickerViewDataSource {
    var oemList = defaultOEM
    var picker = UIPickerView()
    var toolBar = UIToolbar()
    var invisButton = UIButton()
    
    override init(sdk: SmartCarOAuthSDK, viewController: UIViewController) {
        super.init(sdk: sdk, viewController: viewController)
    }
    
    func generatePicker(for oems: [OEM] = defaultOEM, in view: UIView, with color: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)) -> UIButton {
        self.oemList = oems
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        button.backgroundColor = color
        button.setTitle("CONNECT A VEHICLE", for: .normal)
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(pickerButtonPressed), for: .touchUpInside)
        
        view.addSubview(button)
        return button
    }
    
    @objc private func pickerButtonPressed() {
        picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor(white: 1, alpha: 1)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        invisButton = UIButton()
        invisButton.backgroundColor = UIColor(white: 0, alpha: 0)
        invisButton.addTarget(self, action: #selector(hidePickerView), for: .touchUpInside)
        invisButton.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(picker)
        viewController.view.addSubview(toolBar)
        viewController.view.addSubview(invisButton)
        
        let pickerPinBottom = NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: viewController.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pickerHeight = NSLayoutConstraint(item: picker, attribute: .height, relatedBy: .equal, toItem: viewController.view, attribute: .height, multiplier: 0.33, constant: 0)
        let pickerWidth = NSLayoutConstraint(item: picker, attribute: .width, relatedBy: .equal, toItem: viewController.view, attribute: .width, multiplier: 1, constant: 0)
        let toolbarPinToPicker = NSLayoutConstraint(item: toolBar, attribute: .bottom, relatedBy: .equal, toItem: picker, attribute: .top, multiplier: 1.0, constant: 0)
        let toolbarWidth = NSLayoutConstraint(item: toolBar, attribute: .width, relatedBy: .equal, toItem: viewController.view, attribute: .width, multiplier: 1, constant: 0)
        let invisButtonPinTop = NSLayoutConstraint(item: invisButton, attribute: .top, relatedBy: .equal, toItem: viewController.view, attribute: .top, multiplier: 1.0, constant: 0)
        let invisButtonPinBottom = NSLayoutConstraint(item: invisButton, attribute: .bottom, relatedBy: .equal, toItem: toolBar, attribute: .top, multiplier: 1, constant: 0)
        let invisButtonWidth = NSLayoutConstraint(item: invisButton, attribute: .width, relatedBy: .equal, toItem: viewController.view, attribute: .width, multiplier: 1, constant: 0)
        
        viewController.view.addConstraints([pickerPinBottom, pickerHeight, pickerWidth, toolbarPinToPicker, toolbarWidth,invisButtonPinTop, invisButtonWidth, invisButtonPinBottom])
    }
    
    @objc private func donePicker() {
        hidePickerView()
        let val = self.oemList[picker.selectedRow(inComponent: 0)]
        let name = val.oemName.rawValue
        
        self.sdk.initializeAuthorizationRequest(for: OEM(oemName: OEMName(rawValue: name.lowercased())!), viewController: viewController)
    }
    
    @objc private func hidePickerView() {
        picker.isHidden = true
        invisButton.isHidden = true
        toolBar.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.oemList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.oemList[row].oemName.rawValue.uppercased()
    }
}
