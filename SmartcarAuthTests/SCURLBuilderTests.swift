//
//  URLBuilderTests.swift
//  SmartcarAuthTests
//
//  Created by Smartcar on 11/7/19.
//  Copyright © 2019 SmartCar Inc. All rights reserved.
//

import Nimble
import XCTest

@testable import SmartcarAuth

class SCURLBuilderTests: XCTestCase {
    let clientId = UUID().uuidString
    let redirectUri = "scTesting://exchange"
    let scope = ["read_vehicle_info", "read_odometer"]
    let state = UUID().uuidString
    let make = "TESLA"
    let vin = "12345678901234567"
    var testMode = false

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSCURLBuilderBaseUrlLiveMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        
        let baseUrl = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode).build()
        
        expect(baseUrl).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderBaseUrlTestMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=test&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        self.testMode = true
        
        let baseUrl = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetState() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setState(state: state)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetForcePromptTrue() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&approval_prompt=force"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setForcePrompt(forcePrompt: true)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetForcePromptFalse() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&approval_prompt=auto"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setForcePrompt(forcePrompt: false)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetMakeBypass() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&make=TESLA"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setMakeBypass(make: make)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetSingleSelectTrue() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=true"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setSingleSelect(singleSelect: true)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetSingleSelectFalse() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=false"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setSingleSelect(singleSelect: false)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetSingleSelectVin() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=true&single_select_vin=12345678901234567"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCURLBuilderSetAllParameters() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state + "&approval_prompt=force&make=TESLA&single_select=true&single_select_vin=12345678901234567"
        
        let urlWithState = SCURLBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setState(state: state)
            .setForcePrompt(forcePrompt: true)
            .setMakeBypass(make: make)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .build()
        
        expect(urlWithState).to(equal(expectedUrl))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
