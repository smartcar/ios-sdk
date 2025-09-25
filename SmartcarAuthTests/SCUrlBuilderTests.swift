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

class SCUrlBuilderTests: XCTestCase {
    let clientId = UUID().uuidString
    let redirectUri = "scTesting://exchange"
    let scope = ["read_vehicle_info", "read_odometer"]
    let state = UUID().uuidString
    let make = "TESLA"
    let vin = "12345678901234567"
    let flags = ["country:DE", "flag:suboption"]
    var testMode = false
    var connectMode = SCMode.live
    let user = "a60d61bb-3f7b-49bd-b7ec-bf1d87db0e47"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSCUrlBuilderBaseUrl() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope).build()

        expect(baseUrl).to(equal(expectedUrl))
    }
    
    func testSCUrlBuilderBaseUrlNoScope() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri).build()

        expect(baseUrl).to(equal(expectedUrl))
    }

    func testSCUrlBuilderBaseUrlTestMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=test&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        self.testMode = true

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }
    
    func testSCUrlBuilderBaseUrlModeTest() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=test&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        self.connectMode = SCMode.test

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, mode: connectMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }
    
    func testSCUrlBuilderBaseUrlModeSimulated() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=simulated&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        self.connectMode = SCMode.simulated

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, mode: connectMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }
    
    func testSCUrlBuilderBaseUrlTestModeAndMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=simulated&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        self.connectMode = SCMode.simulated
        self.testMode = true

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode, mode: connectMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetState() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setState(state: state)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetForcePromptTrue() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&approval_prompt=force"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setForcePrompt(forcePrompt: true)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetForcePromptFalse() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&approval_prompt=auto"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setForcePrompt(forcePrompt: false)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetMakeBypass() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&make=TESLA"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setMakeBypass(make: make)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetSingleSelectTrue() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=true"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setSingleSelect(singleSelect: true)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetSingleSelectFalse() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=false"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setSingleSelect(singleSelect: false)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetSingleSelectVin() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=true&single_select_vin=12345678901234567"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetFlags() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&flags=country:DE%20flag:suboption"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setFlags(flags: flags)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetUser() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&user=a60d61bb-3f7b-49bd-b7ec-bf1d87db0e47"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope)
            .setUser(user: user)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetAllSupportedParameters() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=simulated&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state + "&approval_prompt=force&make=TESLA&single_select=true&single_select_vin=12345678901234567&flags=country:DE%20flag:suboption&user=a60d61bb-3f7b-49bd-b7ec-bf1d87db0e47"
        self.connectMode = SCMode.simulated

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, mode: connectMode)
            .setState(state: state)
            .setForcePrompt(forcePrompt: true)
            .setMakeBypass(make: make)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .setFlags(flags: flags)
            .setUser(user: user)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }
    
    func testSCUrlBuilderSetAllParametersWithTestMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=simulated&sdk_platform=iOS&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state + "&approval_prompt=force&make=TESLA&single_select=true&single_select_vin=12345678901234567&flags=country:DE%20flag:suboption&user=a60d61bb-3f7b-49bd-b7ec-bf1d87db0e47"
        self.testMode = true
        self.connectMode = SCMode.simulated

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode, mode: connectMode)
            .setState(state: state)
            .setForcePrompt(forcePrompt: true)
            .setMakeBypass(make: make)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .setFlags(flags: flags)
            .setUser(user: user)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }
}
