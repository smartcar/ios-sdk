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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSCUrlBuilderBaseUrlLiveMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }

    func testSCUrlBuilderBaseUrlTestMode() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=test&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer"
        self.testMode = true

        let baseUrl = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode).build()

        expect(baseUrl).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetState() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setState(state: state)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetForcePromptTrue() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&approval_prompt=force"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setForcePrompt(forcePrompt: true)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetForcePromptFalse() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&approval_prompt=auto"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setForcePrompt(forcePrompt: false)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetMakeBypass() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&make=TESLA"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setMakeBypass(make: make)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetSingleSelectTrue() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=true"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setSingleSelect(singleSelect: true)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetSingleSelectFalse() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=false"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setSingleSelect(singleSelect: false)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetSingleSelectVin() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&single_select=true&single_select_vin=12345678901234567"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetFlags() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&flags=country:DE%20flag:suboption"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setFlags(flags: flags)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }

    func testSCUrlBuilderSetAllParameters() {
        let expectedUrl = "https://connect.smartcar.com/oauth/authorize?client_id=" + clientId + "&response_type=code&mode=live&redirect_uri=" + redirectUri + "&scope=read_vehicle_info%20read_odometer&state=" + state + "&approval_prompt=force&make=TESLA&single_select=true&single_select_vin=12345678901234567"

        let urlWithState = SCUrlBuilder(clientId: clientId, redirectUri: redirectUri, scope: scope, testMode: testMode)
            .setState(state: state)
            .setForcePrompt(forcePrompt: true)
            .setMakeBypass(make: make)
            .setSingleSelect(singleSelect: true)
            .setSingleSelectVin(vin: vin)
            .setFlags(flags: flags)
            .build()

        expect(urlWithState).to(equal(expectedUrl))
    }
}
