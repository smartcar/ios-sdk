//
//  AuthorizationError.swift
//  SmartcarAuth
//
//  Created by Ziyu Zhang on 1/31/17.
//  Copyright © 2017 SmartCar Inc. All rights reserved.
//

enum AuthorizationError: Error {
    case invalidState
    case missingURL
    case missingState
}
