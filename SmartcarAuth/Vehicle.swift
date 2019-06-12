//
//  Vehicle.swift
//  SmartcarAuth
//
//  Created by Rishab Luthra on 6/12/19.
//  Copyright © 2019 SmartCar Inc. All rights reserved.
//

import Foundation

struct Vehicle {
    var vin: String
    var make: String
    var model: String
    var year: String
    
    init() {
        self.vin = ""
        self.make = ""
        self.model = ""
        self.year = ""
    }
}
