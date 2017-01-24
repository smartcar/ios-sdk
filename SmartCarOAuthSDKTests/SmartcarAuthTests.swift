//
//  SmartCarOAuthSDKTests.swift
//  SmartCarOAuthSDKTests
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

import XCTest
import SmartCarOAuthSDK


class SmartCarOAuthSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinkGeneration() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        
        let link = sdk.generateLink(for: OEMName.acura)
        
        XCTAssertEqual(link, "https://acura.smartcar.com/oauth/authorize?response_type=code&client_id=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa&redirect_uri=scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page&scope=read_vehicle_info%20read_odometer&approval_prompt=auto&state=" + smartCarRequest.state, "Link generation failed to provide the accurate link")
    }
    
    func testResumingAuthorizationFlowWithIncorrectState() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        
        let url = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page?code=abc123&state=ABC-123-DEG"
        
        XCTAssertFalse(sdk.resumeAuthorizationFlowWithURL(url: URL(string: url)!), "ResumeAuthorizationFlowWithURL returned true for call back URL with different states")
    }
    
    func testResumingAuthorizationFlowWithCorrectState() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        
        let url = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page?code=abc123&state=" + smartCarRequest.state
        
        XCTAssertTrue(sdk.resumeAuthorizationFlowWithURL(url: URL(string: url)!), "ResumeAuthorizationFlowWithURL returned false for call back URL with the same states")
        XCTAssertEqual(sdk.code!, "abc123", "Code returned does not equal code in the URL")

    }
}