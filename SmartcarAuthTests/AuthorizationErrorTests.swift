//
//  AuthorizationErrorTests.swift
//  SmartcarAuthTests
//
//  Created by Smartcar on 11/7/19.
//  Copyright © 2019 SmartCar Inc. All rights reserved.
//

import Nimble
import XCTest

@testable import SmartcarAuth

class AuthorizationErrorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAuthorizationErrorOnlyErrorType() {
        let error = AuthorizationError(type: .accessDenied)

        expect(error.type).to(equal(.accessDenied))
        expect(error.errorDescription).to(beNil())
        expect(error.vehicleInfo).to(beNil())
        expect(error.statusCode).to(beNil())
        expect(error.errorMessage).to(beNil())
    }

    func testAuthorizationErrorWithErrorDescription() {
        let error = AuthorizationError(type: .accessDenied, errorDescription: "Access was denied")

        expect(error.type).to(equal(.accessDenied))
        expect(error.errorDescription).to(equal("Access was denied"))
        expect(error.vehicleInfo).to(beNil())
        expect(error.statusCode).to(beNil())
        expect(error.errorMessage).to(beNil())
    }
    
    func testAuthorizationErrorWithStatusCode() {
        let error = AuthorizationError(type: .configurationError, errorDescription: "There has been an error in the configuration of your application.", statusCode: "400")

        expect(error.type).to(equal(.configurationError))
        expect(error.errorDescription).to(equal("There has been an error in the configuration of your application."))
        expect(error.vehicleInfo).to(beNil())
        expect(error.statusCode).to(equal("400"))
        expect(error.errorMessage).to(beNil())
    }
    
    func testAuthorizationErrorWithErrorMessage() {
        let error = AuthorizationError(type: .configurationError, errorDescription: "There has been an error in the configuration of your application.", errorMessage: "Invalid client ID")

        expect(error.type).to(equal(.configurationError))
        expect(error.errorDescription).to(equal("There has been an error in the configuration of your application."))
        expect(error.vehicleInfo).to(beNil())
        expect(error.statusCode).to(beNil())
        expect(error.errorMessage).to(equal("Invalid client ID"))
    }
    
    func testAuthorizationErrorWithVehicleInfo() {
        let vehicleInfo = VehicleInfo(vin: "12345678901234567", make: "Tesla", model: "Model 3", year: 2019)
        let error = AuthorizationError(type: .accessDenied, errorDescription: nil, vehicleInfo: vehicleInfo)

        expect(error.type).to(equal(.accessDenied))
        expect(error.errorDescription).to(beNil())
        expect(error.vehicleInfo).to(beIdenticalTo(vehicleInfo))
        expect(error.statusCode).to(beNil())
        expect(error.errorMessage).to(beNil())
    }
    
    func testAuthorizationErrorWithAllFields() {
        let vehicleInfo = VehicleInfo(vin: "12345678901234567", make: "Tesla", model: "Model 3", year: 2019)
        let error = AuthorizationError(type: .configurationError, errorDescription: "There has been an error in the configuration of your application.", vehicleInfo: vehicleInfo, statusCode: "400", errorMessage: "Invalid client ID")

        expect(error.type).to(equal(.configurationError))
        expect(error.errorDescription).to(equal("There has been an error in the configuration of your application."))
        expect(error.vehicleInfo).to(beIdenticalTo(vehicleInfo))
        expect(error.statusCode).to(equal("400"))
        expect(error.errorMessage).to(equal("Invalid client ID"))
    }
}
