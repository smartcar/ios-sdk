//
//  OEM.swift
//  SmartCarOAuthSDK
//
//  Created by Jeremy Zhang on 1/6/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

/**
    OEM class storing the name and the specific configurations for the OEM
 */

public class OEM {
    let oemName: OEMName
    let oemConfig: OEMConfig
    
    /**
        Constructor taking the oemName as an input and setting the OEMConfig for the OEM
    */
    public init(oemName: OEMName) {
        self.oemName = oemName
        
        switch oemName {
        case .acura:
            self.oemConfig = OEMConfig(color: "#020202")
        case .audi:
            self.oemConfig = OEMConfig(color: "#000000")
        case .bmw:
            self.oemConfig = OEMConfig(color: "#2E9BDA")
        case .bmwConnected:
            self.oemConfig = OEMConfig(color: "#2E9BDA")
        case .buick:
            self.oemConfig = OEMConfig(color: "#333333")
        case .cadillac:
            self.oemConfig = OEMConfig(color: "#941711")
        case .chevrolet:
            self.oemConfig = OEMConfig(color: "#042F6B")
        case .chrysler:
            self.oemConfig = OEMConfig(color: "#231F20")
        case .dodge:
            self.oemConfig = OEMConfig(color: "#000000")
        case .ford:
            self.oemConfig = OEMConfig(color: "#003399")
        case .fiat:
            self.oemConfig = OEMConfig(color: "#B50536")
        case .gmc:
            self.oemConfig = OEMConfig(color: "#CC0033")
        case .hyundai:
            self.oemConfig = OEMConfig(color: "#00287A")
        case .infiniti:
            self.oemConfig = OEMConfig(color: "#1F1F1F")
        case .jeep:
            self.oemConfig = OEMConfig(color: "#374B00")
        case .kia:
            self.oemConfig = OEMConfig(color: "#C4172C")
        case .landrover:
            self.oemConfig = OEMConfig(color: "#005A2B")
        case .lexus:
            self.oemConfig = OEMConfig(color: "#5B7F95")
        case .nissan:
            self.oemConfig = OEMConfig(color: "#C71444")
        case .nissanev:
            self.oemConfig = OEMConfig(color: "#C71444")
        case .ram:
            self.oemConfig = OEMConfig(color: "#000000")
        case .tesla:
            self.oemConfig = OEMConfig(color: "#CC0000")
        case .volkswagen:
            self.oemConfig = OEMConfig(color: "#000000")
        case .volvo:
            self.oemConfig = OEMConfig(color: "#000F60")
        case .mercedes:
            self.oemConfig = OEMConfig(color: "#222222")
        case .mock:
            self.oemConfig = OEMConfig(color: "#495F5D")
        }
    }
}
