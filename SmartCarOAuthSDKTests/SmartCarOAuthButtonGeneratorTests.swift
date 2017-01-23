//
//  SmartCarOAuthButtonGeneratorTests.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

import XCTest
import SmartCarOAuthSDK

class SmartCarOAuthButtonGeneratorTests: XCTestCase {
    
    var viewController = UIViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testButtonGeneration() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "7cc72cc2-6464-4245-9fed-b971361a820e", redirectURI: "sc7cc72cc2-6464-4245-9fed-b971361a820e://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        let gen = SmartCarOAuthButtonGenerator(sdk: sdk, viewController: viewController)
        
        let button = gen.generateButton(frame: CGRect(x: 0, y: 0, width: 250, height: 50), for: OEMName.acura)
        
        XCTAssertNotNil(button)
        XCTAssertEqual(button.titleLabel?.text, "LOGIN WITH ACURA")
        XCTAssertNotEqual(button.allTargets.count, 0)
    }
}
