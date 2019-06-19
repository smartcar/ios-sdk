//
//  VehicleInfo.swift
//  SmartcarAuthTests
//
//  Created by Morgan Newman on 6/14/19.
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
        let vehicle = VehicleInfo()
        vehicle.vin = "0000"
        vehicle.make = "TESLA"
        vehicle.model = "Model S"
        vehicle.year = 2019
        expect(vehicle.vin).to(equal("0000"))
        expect(vehicle.make).to(equal("TESLA"))
        expect(vehicle.model).to(equal("Model S"))
        expect(vehicle.year).to(equal(2019))
    }
}
