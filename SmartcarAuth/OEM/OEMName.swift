//
//  OEM.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/6/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Foundation

/**
    Enum for the list of currently available OEM names
*/

@objc public enum OEMName: Int {
    case acura
    case audi
    case bmw
    case bmwConnected
    case buick
    case cadillac
    case chevrolet
    case chrysler
    case dodge
    case ford
    case fiat
    case gmc
    case honda
    case hyundai
    case infiniti
    case jeep
    case kia
    case landrover
    case lexus
    case mercedes
    case mock
    case nissan
    case nissanev
    case ram
    case tesla
    case volkswagen
    case volvo
    
    var stringValue: String {
        switch self {
        case .acura:
            return "acura"
        case .audi:
            return "audi"
        case .bmw:
            return "bmw"
        case .bmwConnected:
            return "bmw-connected"
        case .buick:
            return "buick"
        case .cadillac:
            return "cadillac"
        case .chevrolet:
            return "chevrolet"
        case .chrysler:
            return "chrysler"
        case .dodge:
            return "dodge"
        case .ford:
            return "ford"
        case .fiat:
            return "fiat"
        case .gmc:
            return "gmc"
        case .honda:
            return "honda"
        case .hyundai:
            return "hyundai"
        case .infiniti:
            return "infiniti"
        case .jeep:
            return "jeep"
        case .kia:
            return "kia"
        case .landrover:
            return "landrover"
        case .lexus:
            return "lexus"
        case .mercedes:
            return "mercedes"
        case .mock:
            return "mock"
        case .nissan:
            return "nissan"
        case .nissanev:
            return "nissanev"
        case .ram:
            return "ram"
        case .tesla:
            return "tesla"
        case .volkswagen:
            return "volkswagen"
        case .volvo:
            return "volvo"
        }
    }
}
