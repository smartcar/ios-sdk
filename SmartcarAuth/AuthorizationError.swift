/*
 AuthorizationError.swift
 SmartcarAuth
 
 Copyright (c) 2017-present, Smartcar, Inc. All rights reserved.
 You are hereby granted a limited, non-exclusive, worldwide, royalty-free
 license to use, copy, modify, and distribute this software in source code or
 binary form, for the limited purpose of this software's use in connection
 with the web services and APIs provided by Smartcar.
 
 As with any software that integrates with the Smartcar platform, your use of
 this software is subject to the Smartcar Developer Agreement. This copyright
 notice shall be included in all copies or substantial portions of the software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

@objc public class AuthorizationError: NSObject, Error {
    enum ErrorType {
        case missingQueryParameters
        case missingAuthCode
        case accessDenied
        case vehicleIncompatible
        case invalidSingleSelectOptions
        case subscriptionInactive
        case userExitedFlow
        case unknownError
    }
    
    var type: ErrorType
    var errorDescription: String?
    var vehicleInfo: VehicleInfo?
    
    init(type: ErrorType, errorDescription: String? = nil, vehicleInfo: VehicleInfo? = nil) {
        self.type = type
        self.errorDescription = errorDescription
        self.vehicleInfo = vehicleInfo
    }
}
