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

    func emptyVehicleInfo() {
        let vehicleInfo = VehicleInfo()
        expect(vehicleInfo.make).to(equal(nil))
    }
    
    func nonEmptyVehicleInfo() {
        let vehicleInfo = VehicleInfo(make: "TESLA")
        expect(vehicleInfo.make).to(equal("TESLA"))
    }
}
