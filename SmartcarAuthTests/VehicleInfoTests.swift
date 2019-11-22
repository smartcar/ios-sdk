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
    
    func testVehicleInfoMakeOnly() {
        let vehicleInfo = VehicleInfo(make: "TESLA")
        expect(vehicleInfo.make).to(equal("TESLA"))
    }

    func testVehicleInfoModelOnly() {
        let vehicleInfo = VehicleInfo(model: "Model S")
        expect(vehicleInfo.model).to(equal("Model S"))
    }
    
    func testVehicleInfoYearOnly() {
        let vehicleInfo = VehicleInfo(year: 2019)
        expect(vehicleInfo.year).to(equal(2019))
    }
    
    func testVehicleInfoVinOnly() {
        let vehicleInfo = VehicleInfo(vin: "SC123456789012345")
        expect(vehicleInfo.vin).to(equal("SC123456789012345"))
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

