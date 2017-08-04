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
        [.acura: OEMConfig(color: "#020202", displayName: "acura"),
         .audi: OEMConfig(color: "#000000", displayName: "audi"),
         .bmw: OEMConfig(color: "#2E9BDA", displayName: "bmw"),
         .bmwConnected: OEMConfig(color: "#2E9BDA", displayName: "bmw-connected"),
         .buick: OEMConfig(color: "#333333", displayName: "buick"),
         .cadillac: OEMConfig(color: "#941711", displayName: "cadillac"),
         .chevrolet: OEMConfig(color: "#042F6B", displayName: "chevrolet"),
         .chrysler: OEMConfig(color: "#231F20", displayName: "chrysler"),
         .dodge: OEMConfig(color: "#000000", displayName: "dodge"),
         .ford: OEMConfig(color: "#003399", displayName: "ford"),
         .fiat: OEMConfig(color: "#B50536", displayName: "fiat"),
         .gmc: OEMConfig(color: "#CC0033", displayName: "gmc"),
         .honda: OEMConfig(color: "#DA251D", displayName: "honda"),
         .hyundai: OEMConfig(color: "#00287A", displayName: "hyundai"),
         .infiniti: OEMConfig(color: "#1F1F1F", displayName: "infiniti"),
         .jeep: OEMConfig(color: "#374B00", displayName: "jeep"),
         .kia: OEMConfig(color: "#C4172C", displayName: "kia"),
         .landrover: OEMConfig(color: "#005A2B", displayName: "landrover"),
         .lexus: OEMConfig(color: "#5B7F95", displayName: "lexus"),
         .nissan: OEMConfig(color: "#C71444", displayName: "nissan"),
         .nissanev: OEMConfig(color: "#C71444", displayName: "nissanev"),
         .ram: OEMConfig(color: "#000000", displayName: "ram"),
         .tesla: OEMConfig(color: "#CC0000", displayName: "tesla"),
         .volkswagen: OEMConfig(color: "#000000", displayName: "volkswagen"),
         .volvo: OEMConfig(color: "#000F60", displayName: "volvo"),
         .mercedes: OEMConfig(color: "#222222", displayName: "mercedes"),
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
