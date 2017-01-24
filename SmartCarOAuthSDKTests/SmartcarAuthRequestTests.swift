//
//  SmartCarOAuthRequestTests.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

import XCTest
@testable import SmartCarOAuthSDK

class SmartCarOAuthRequestTests: XCTestCase {
    let clientId = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    let redirectURI = "scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page"
    let scope = ["read_vehicle_info", "read_odometer"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialization() {
        let request = SmartCarOAuthRequest(clientID: clientId, redirectURI: redirectURI, scope: scope,  forcePrompt: true)
        
        XCTAssertEqual(request.clientID, clientId)
        XCTAssertEqual(request.redirectURI, redirectURI)
        XCTAssertEqual(request.scope, scope)
        XCTAssertEqual(request.grantType, GrantType.code)
        XCTAssertEqual(request.approvalType, ApprovalType.force)
    }
    
}