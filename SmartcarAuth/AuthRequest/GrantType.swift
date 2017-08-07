//
//  GrantType.swift
//  SmartcarAuth
//
//  Created by Jeremy Zhang on 1/7/17.
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Foundation

/**
    Enum for the request Grant Types (code and token)
 */

@objc public enum GrantType: Int {
    case code
    case token
    
    var stringValue: String {
        switch self {
        case .code:
            return "code"
        case .token:
            return "token"
        }
    }
}
