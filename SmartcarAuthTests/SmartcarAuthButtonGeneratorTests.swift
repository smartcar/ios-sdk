//
//  SmartcarAuthButtonGeneratorTests.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import XCTest
import SmartcarAuth

class SmartcarAuthButtonGeneratorTests: XCTestCase {
    
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
        let smartCarRequest = SmartcarAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartcarAuth(request: smartCarRequest)
        let gen = SmartcarAuthButtonGenerator(sdk: sdk, viewController: viewController)
        
        let button = gen.generateButton(frame: CGRect(x: 0, y: 0, width: 250, height: 50), for: OEMName.acura)
        
        XCTAssertNotNil(button)
        XCTAssertEqual(button.titleLabel?.text, "LOGIN WITH ACURA")
        XCTAssertNotEqual(button.allTargets.count, 0)
    }
}
