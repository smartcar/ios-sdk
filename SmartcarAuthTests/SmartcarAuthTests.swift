//
//  SmartcarAuthTests.swift
//  SmartcarAuthTests
//
//  Created by Jeremy Zhang on 1/14/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import XCTest
import SmartcarAuth


class SmartcarAuthTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinkGeneration() {
        let smartCarRequest = SmartcarAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", state: randomString(length: 8), scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartcarAuth(request: smartCarRequest)
        
        let link = sdk.generateLink(for: OEMName.acura)
        
        XCTAssertEqual(link, "https://acura.smartcar.com/oauth/authorize?response_type=code&client_id=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa&redirect_uri=scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page&scope=read_vehicle_info%20read_odometer&approval_prompt=auto&state=" + smartCarRequest.state, "Link generation failed to provide the accurate link")
    }
    
    func testLinkGenerationWithoutRequest() {
        let sdk = SmartcarAuth(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", state: randomString(length: 8), scope: ["read_vehicle_info", "read_odometer"])
        
        let link = sdk.generateLink(for: OEMName.acura)
        
        XCTAssertEqual(link, "https://acura.smartcar.com/oauth/authorize?response_type=code&client_id=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa&redirect_uri=scaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page&scope=read_vehicle_info%20read_odometer&approval_prompt=auto&state=" + sdk.request.state, "Link generation failed to provide the accurate link")
    }
    
    func testResumingAuthorizationFlowWithIncorrectURL() {
        let smartCarRequest = SmartcarAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartcarAuth(request: smartCarRequest)
        
        let url = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page"
        
        do {
            try sdk.resumeAuthorizationFlow(with: URL(string: url)!)
            XCTFail()
        } catch {
        }
    }
    
    func testResumingAuthorizationFlowWithIncorrectState() {
        let smartCarRequest = SmartcarAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartcarAuth(request: smartCarRequest)
        
        let url = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page?code=abc123&state=ABC-123-DEG"
        
        do {
            try sdk.resumeAuthorizationFlow(with: URL(string: url)!)
            XCTFail()
        } catch {
        }
    }
    
    func testResumingAuthorizationFlowWithCorrectState() {
        let smartCarRequest = SmartcarAuthRequest(clientID: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", redirectURI: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page", scope: ["read_vehicle_info", "read_odometer"])
        let sdk = SmartcarAuth(request: smartCarRequest)
        
        let url = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa://page?code=abc123&state=" + smartCarRequest.state
        
        do {
            let code = try sdk.resumeAuthorizationFlow(with: URL(string: url)!)
            XCTAssertEqual(code, "abc123", "Code returned does not equal code in the URL")
        } catch {
            XCTFail()
        }
    }
}
