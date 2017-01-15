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
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        
        let link = sdk.generateLink(for: OEM(oemName: OEMName.acura))
        
        XCTAssertEqual(link, "https://acura.smartcar.com/oauth/authorize?response_type=code&client_id=4a1b01e5-0497-417c-a30e-6df6ba33ba46&redirect_uri=smartcar://oidc.com&scope=read_vehicle_info%20read_odometer&approval_prompt=auto&state=ABC-123-DEFG", "Link generation failed to provide the accurate link")
    }
    
    func testLinkGenerationNoState() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)

        let link = sdk.generateLink(for: OEM(oemName: OEMName.acura))
        
        XCTAssertEqual(link, "https://acura.smartcar.com/oauth/authorize?response_type=code&client_id=4a1b01e5-0497-417c-a30e-6df6ba33ba46&redirect_uri=smartcar://oidc.com&scope=read_vehicle_info%20read_odometer&approval_prompt=auto", "Link generation failed to provide the accurate link")
    }
    
    func testResumingAuthorizationFlowWithIncorrectState() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        
        let url = "com.pingidentity.developer.mobile_app://oidc/cb?code=abc123&state=ABC-123-DEG"
        
        XCTAssertFalse(sdk.resumeAuthorizationFlowWithURL(url: URL(string: url)!), "ResumeAuthorizationFlowWithURL returned true for call back URL with different states")
    }
    
    func testResumingAuthorizationFlowWithCorrectState() {
        let smartCarRequest = SmartCarOAuthRequest(clientID: "4a1b01e5-0497-417c-a30e-6df6ba33ba46", redirectURI: "smartcar://oidc.com", scope: ["read_vehicle_info", "read_odometer"], state: "ABC-123-DEFG")
        let sdk = SmartCarOAuthSDK(request: smartCarRequest)
        
        let url = "com.pingidentity.developer.mobile_app://oidc/cb?code=abc123&state=ABC-123-DEFG"
        
        XCTAssertTrue(sdk.resumeAuthorizationFlowWithURL(url: URL(string: url)!), "ResumeAuthorizationFlowWithURL returned false for call back URL with the same states")
        XCTAssertEqual(sdk.code!, "abc123", "Code returned does not equal code in the URL")

    }
}
