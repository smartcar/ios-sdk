//
//  Vehicle.swift
//  SmartcarAuth
//
//  Created by Morgan Newman on 6/14/19.
//  Copyright © 2019 SmartCar Inc. All rights reserved.
//
import Nimble
import XCTest

@testable import SmartcarAuth

class VehicleTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func initializeEmptyVehicle() {
        let vehicle = Vehicle()
        expect(vehicle.vin).to(equal(""))
        expect(vehicle.make).to(equal(""))
        expect(vehicle.model).to(equal(""))
        expect(vehicle.year).to(equal(""))
    }
    
    func fullVehicle() {
        var vehicle = Vehicle()
        vehicle.vin = "0000"
        vehicle.make = "TESLA"
        vehicle.model = "Model S"
        vehicle.year = "2019"
        expect(vehicle.vin).to(equal("0000"))
        expect(vehicle.make).to(equal("TESLA"))
        expect(vehicle.model).to(equal("Model S"))
        expect(vehicle.year).to(equal("2019"))
    }
    
}
