//
//  SmartCarOAuthSDK.swift
//  SmartCarOAuthSDK
//
//  Created by Ziyu Zhang on 1/6/17.
//  Copyright © 2017 Ziyu Zhang. All rights reserved.
//

import UIKit
import SafariServices

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

/**
    SmartCar Authentication API for iOS written in Swift 3.
        - Allows the ability to generate buttons to login with each manufacturer which launches the OAuth flow
        - Allows the ability to use dropdown/custom buttons to trigger OAuth flow
        - Facilitates the flow with a SFSafariViewController to redirect to SmartCar and retrieve an access code and an 
            access token
*/

class SmartCarOAuthSDK: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let request: SmartCarOAuthRequest
    let viewController: UIViewController
    //Access code for the current request, is nil if request has not been completed
    var code: String?
    var picker: UIPickerView?
    var toolBar: UIToolbar?
    var invisButton: UIButton?
    var oemList = defaultOEM
    
    /**
        Constructor for the SmartCarOAuthSDK
     
        - Parameter request: SmartCarOAuthRequest object for SmartCar API
    */
    init(request: SmartCarOAuthRequest, viewController: UIViewController) {
        self.viewController = viewController
        self.request = request
    }
    
    func generateButton(for oem: OEM, in view: UIView) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        button.backgroundColor = hexStringToUIColor(hex: oem.oemConfig.color)
        button.setTitle("LOGIN WITH " + oem.oemName.rawValue.uppercased(), for: .normal)
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(oemButtonPressed(_:)), for: .touchUpInside)
        
        view.addSubview(button)
        return button
    }
    
    @objc func oemButtonPressed(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        let name = title!.substring(from: title!.index(title!.startIndex, offsetBy: 11))
        
        let safariVC = self.initializeAuthorizationRequest(for: OEM(oemName: OEMName(rawValue: name.lowercased())!))
        self.viewController.present(safariVC, animated: true, completion: nil)
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
    
    @objc func pickerButtonPressed() {
        picker = UIPickerView()
        picker!.dataSource = self
        picker!.delegate = self
        picker!.translatesAutoresizingMaskIntoConstraints = false
        picker!.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        viewController.view.addSubview(picker!)
        
        let pinBottom = NSLayoutConstraint(item: picker!, attribute: .bottom, relatedBy: .equal, toItem: viewController.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let height = NSLayoutConstraint(item: picker!, attribute: .height, relatedBy: .equal, toItem: viewController.view, attribute: .height, multiplier: 0.33, constant: 0)
        let width = NSLayoutConstraint(item: picker!, attribute: .width, relatedBy: .equal, toItem: viewController.view, attribute: .width, multiplier: 1, constant: 0)
        
        viewController.view.addConstraints([pinBottom, height, width])
        
        toolBar = UIToolbar()
        toolBar!.backgroundColor = UIColor(white: 1, alpha: 1)
        toolBar!.translatesAutoresizingMaskIntoConstraints = false
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar!.setItems([spaceButton, doneButton], animated: false)
        toolBar!.isUserInteractionEnabled = true
        
        viewController.view.addSubview(toolBar!)
        
        let pinToPicker = NSLayoutConstraint(item: toolBar!, attribute: .bottom, relatedBy: .equal, toItem: picker, attribute: .top, multiplier: 1.0, constant: 0)
        let widthToolBar = NSLayoutConstraint(item: toolBar!, attribute: .width, relatedBy: .equal, toItem: viewController.view, attribute: .width, multiplier: 1, constant: 0)
        
        viewController.view.addConstraints([pinToPicker, widthToolBar])
        
        invisButton = UIButton()
        invisButton!.backgroundColor = UIColor(white: 0, alpha: 0)
        invisButton!.addTarget(self, action: #selector(transparentButtonPressed), for: .touchUpInside)
        invisButton!.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(invisButton!)
        
        let pinTop = NSLayoutConstraint(item: invisButton!, attribute: .top, relatedBy: .equal, toItem: viewController.view, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomButton = NSLayoutConstraint(item: invisButton!, attribute: .bottom, relatedBy: .equal, toItem: toolBar, attribute: .top, multiplier: 1, constant: 0)
        let widthButton = NSLayoutConstraint(item: invisButton!, attribute: .width, relatedBy: .equal, toItem: viewController.view, attribute: .width, multiplier: 1, constant: 0)
        
        viewController.view.addConstraints([pinTop, bottomButton, widthButton])
    }
    
    @objc func donePicker() {
        picker!.isHidden = true
        invisButton!.isHidden = true
        toolBar!.isHidden = true
        let val = self.oemList[picker!.selectedRow(inComponent: 0)]
        let name = val.oemName.rawValue
        
        let safariVC = self.initializeAuthorizationRequest(for: OEM(oemName: OEMName(rawValue: name.lowercased())!))
        self.viewController.present(safariVC, animated: true, completion: nil)
    }
    
    @objc func transparentButtonPressed() {
        picker!.isHidden = true
        invisButton!.isHidden = true
        toolBar!.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.oemList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.oemList[row].oemName.rawValue.uppercased()
    }
    
    /**
        Initializes the Authorization request and configures and return an SFSafariViewController with the correct 
            authorization URL
     
        - Parameter oem: OEM object to identify the oem name within the authorization request URL
     
        - Returns: SFSafariViewController object configured with the authorization URL corresponding to the request 
            paramters and the provide OEM
    */
    func initializeAuthorizationRequest(for oem: OEM) -> SFSafariViewController {
        let authorizationURL = generateLink(for: oem)
        
        return SFSafariViewController(url: URL(string: authorizationURL)!)
    }
    
    /**
        Generates the authorization request URL for a specific OEM from the request paramters
     
        - Parameter oem: OEM object to identify the oem name within the authorization request URL
        
        - Returns: authorization request URL for the specific OEM
    */
    func generateLink(for oem: OEM) -> String {
        let stateString = self.request.state
        
        let redirectString = self.request.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let scopeString = self.request.scope.joined(separator: " ")
            .addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        return "https://\(oem.oemName.rawValue).smartcar.com/oauth/authorize?response_type=\(self.request.grantType.rawValue)&client_id=\(self.request.clientID)&redirect_uri=\(redirectString)&scope=\(scopeString)&approval_prompt=\(self.request.approvalType.rawValue + stateString)";
    }
    
    /**
        Authorization callback function. Verifies the state parameter of the URL matches the request state paramter and 
            extract the authorization code
     
        - Parameter url: callback URL containing authorization code
     
        - Return: true if authorization code was successfully extracted
    */
    func resumeAuthorizationFlowWithURL(url: URL) -> Bool {
        let urlString = url.absoluteString
        let urlArray = urlString.components(separatedBy: "?")[1].components(separatedBy: "&")
        
        if urlArray.count > 1 {
            if(urlArray[1].substring(from: urlArray[1].index(urlArray[1].startIndex, offsetBy: 6)) != self.request.state) {
                return false
            }
        }
        
        self.code = urlArray[0].substring(from: urlArray[0].index(urlArray[0].startIndex, offsetBy: 5))
        
        return true
    }
}
