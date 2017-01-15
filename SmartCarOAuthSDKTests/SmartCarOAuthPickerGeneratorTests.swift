//
//  SmartCarOAuthPickerGeneratorTests.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

import XCTest
@testable import SmartCarOAuthSDK

class SmartCarOAuthPickerGeneratorTests: XCTestCase {
    
    var viewController = UIViewController()
    let defaultOEM = [OEM(oemName: OEMName.acura), OEM(oemName: OEMName.audi), OEM(oemName: OEMName.bmw),
                      OEM(oemName: OEMName.bmwConnected)]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPickerButtonGeneration() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        let gen = SmartCarOAuthPickerGenerator(sdk: sdk, viewController: viewController, oemList: defaultOEM)
        
        let button = gen.generatePicker(in: UIView(), with: .red)
        
        XCTAssertNotNil(button)
        XCTAssertEqual(button.titleLabel?.text, "CONNECT A VEHICLE")
        XCTAssertNotEqual(button.allTargets.count, 0)
        XCTAssertEqual(button.backgroundColor, .red)
        XCTAssertEqual(gen.oemList.count, 4)
    }
    
    func testHidePickerButtonPress() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        let gen = SmartCarOAuthPickerGenerator(sdk: sdk, viewController: viewController, oemList: defaultOEM)
        
        let button = gen.generatePicker(in: UIView(), with: .red)
        
        button.sendActions(for: .touchUpInside)
        gen.invisButton.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(gen.picker.isHidden)
        XCTAssertTrue(gen.invisButton.isHidden)
        XCTAssertTrue(gen.toolBar.isHidden)
    }
}
