/*
 VehicleInfo.swift
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

/**
 VehicleInfo class is used to describe the vehicle information that may be returned via query parameters in the case of authentication failure.
 */
@objcMembers public class VehicleInfo: NSObject {
    var vin: String?
    var make: String?
    var model: String?
    var year: NSNumber?
    
    /**
    Constructor for the VehicleInfo
    - parameters:
        - vin: Optional, the VIN of the vehicle. Defaults to nil.
        - make: Optional, the make of the vehicle. Defaults to nil.
        - model: Optional, the model of the vehicle. Defaults to nil.
        - year: Optional, the year of the vehicle. Defaults to nil.

    */
    public init(vin: String? = nil, make: String? = nil, model: String? = nil, year: NSNumber? = nil) {
        self.vin = vin
        self.make = make
        self.model = model
        self.year = year
    }
}
