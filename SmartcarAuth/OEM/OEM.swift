//
//  OEM.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/6/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//
import UIKit

/**
    Class containing the name and the specific configurations for the OEMs
 */

public class OEM {
    static let oemDictionary: [OEMName: OEMConfig] =
        [.acura: OEMConfig(color: "#020202", displayName: "Acura"),
         .audi: OEMConfig(color: "#000000", displayName: "Audi"),
         .bmw: OEMConfig(color: "#2E9BDA", displayName: "BMW"),
         .bmwConnected: OEMConfig(color: "#2E9BDA", displayName: "BMW Connected"),
         .buick: OEMConfig(color: "#333333", displayName: "Buick"),
         .cadillac: OEMConfig(color: "#941711", displayName: "Cadillac"),
         .chevrolet: OEMConfig(color: "#042F6B", displayName: "Chevrolet"),
         .chrysler: OEMConfig(color: "#231F20", displayName: "Chrysler"),
         .dodge: OEMConfig(color: "#000000", displayName: "Dodge"),
         .ford: OEMConfig(color: "#003399", displayName: "Ford"),
         .fiat: OEMConfig(color: "#B50536", displayName: "Fiat"),
         .gmc: OEMConfig(color: "#CC0033", displayName: "GMC"),
         .honda: OEMConfig(color: "#DA251D", displayName: "Honda"),
         .hyundai: OEMConfig(color: "#00287A", displayName: "Hyundai"),
         .infiniti: OEMConfig(color: "#1F1F1F", displayName: "INFINITI"),
         .jeep: OEMConfig(color: "#374B00", displayName: "Jeep"),
         .kia: OEMConfig(color: "#C4172C", displayName: "Kia"),
         .landrover: OEMConfig(color: "#005A2B", displayName: "Land Rover"),
         .lexus: OEMConfig(color: "#5B7F95", displayName: "Lexus"),
         .nissan: OEMConfig(color: "#C71444", displayName: "Nissan"),
         .nissanev: OEMConfig(color: "#C71444", displayName: "Nissan EV"),
         .ram: OEMConfig(color: "#000000", displayName: "Ram"),
         .tesla: OEMConfig(color: "#CC0000", displayName: "Tesla"),
         .volkswagen: OEMConfig(color: "#000000", displayName: "Volkswagen"),
         .volvo: OEMConfig(color: "#000F60", displayName: "Volvo"),
         .mercedes: OEMConfig(color: "#222222", displayName: "Mercedes-Benz"),
         .mock: OEMConfig(color: "#495F5D", displayName: "mock")]
    
    /**
        Return the OEMConfig object of the OEM
     
        - Returns: OEMConfig object for the OEM
    */
    public static func getOEMConfig(for oem: OEMName) -> OEMConfig {
        return self.oemDictionary[oem]!
    }
    
    /**
        Return the UIColor object of the OEM
    */
    public static func getColor(for oem: OEMName) -> UIColor {
        return self.oemDictionary[oem]!.color
    }
    
    /**
        Return the displayName of the OEM
    */
    public static func getDisplayName(for oem: OEMName) -> String {
        return self.oemDictionary[oem]!.displayName
    }
    
    /**
        Return the full list of OEMNames
    */
    public static func getDefaultOEMList() -> [OEMName] {
        var array = Array(oemDictionary.keys).sorted {
            getDisplayName(for: $0) < getDisplayName(for: $1)
        }
        
        array.remove(at: array.index(of: .mock)!)
        
        return array
    }
    
}

extension Array where Element == OEMName {
    /**
     Return sorted list of contained `OEMName`s by `displayName`, while keeping `mock` at the end
     */
    public func sortedByDisplayName() -> [Element] {
        return sorted(by: { (oem1, oem2) -> Bool in
            if oem1 == .mock {
                return false
            }
            return OEM.getDisplayName(for: oem1) < OEM.getDisplayName(for: oem2)
        })
    }
}
