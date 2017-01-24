//
//  SmartcarAuthPickerGeneratorTests.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import XCTest
@testable import SmartcarAuth

class SmartcarAuthPickerGeneratorTests: XCTestCase {
    
    var viewController = UIViewController()
    let defaultOEM = [OEMName.acura, OEMName.audi, OEMName.bmw, OEMName.bmwConnected]
    let smartCarRequest = SmartcarAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
    var sdk: SmartcarAuth?
    var gen: SmartcarAuthPickerGenerator?
    
    override func setUp() {
        super.setUp()
        sdk = SmartcarAuth(request: smartCarRequest)
        gen = SmartcarAuthPickerGenerator(sdk: sdk!, viewController: viewController, oemList: defaultOEM)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPickerButtonGeneration() {
        let button = gen!.generatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 50), with: .red)
        
        XCTAssertNotNil(button)
        XCTAssertEqual(button.titleLabel?.text, "CONNECT A VEHICLE")
        XCTAssertNotEqual(button.allTargets.count, 0)
        XCTAssertEqual(button.backgroundColor, .red)
        XCTAssertEqual(gen!.oemList.count, 4)
    }
    
    func testHidePickerButtonPress() {
        let button = gen!.generatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 50), with: .red)
        viewController.view.addSubview(button)
        
        gen!.pickerButtonPressed()
        gen!.hidePickerView()
        
        XCTAssertTrue(gen!.picker.isHidden)
        XCTAssertTrue(gen!.invisButton.isHidden)
        XCTAssertTrue(gen!.toolBar.isHidden)
    }
}
