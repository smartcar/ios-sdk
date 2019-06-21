//
//  VehicleInfo.swift
//  SmartcarAuthTests
//
//  Copyright © 2019 SmartCar Inc. All rights reserved.
//

import Nimble
import XCTest

@testable import SmartcarAuth

class VehicleInfoTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyVehicleInfo() {
        let vehicleInfo = VehicleInfo()
        expect(vehicleInfo.make).to(beNil())
    }
    
    func testVehicleInfo() {
        let vehicleInfo = VehicleInfo(make: "TESLA")
        expect(vehicleInfo.make).to(equal("TESLA"))
    }
    
    func testFullVehicleInfo() {
        let vehicleInfo = VehicleInfo()
        vehicleInfo.vin = "0000"
        vehicleInfo.make = "TESLA"
        vehicleInfo.model = "Model S"
        vehicleInfo.year = 2019
        expect(vehicleInfo.vin).to(equal("0000"))
        expect(vehicleInfo.make).to(equal("TESLA"))
        expect(vehicleInfo.model).to(equal("Model S"))
        expect(vehicleInfo.year).to(equal(2019))
    }
}
