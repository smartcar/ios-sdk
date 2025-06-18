/*
 RPCInterface.swift
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

struct RPCRequestObjectParams: Codable {
    var authorizeURL: String
    var interceptPrefix: String
}

struct RPCRequestObject: Codable {
    var jsonrpc: String
    var method: String
    var params: RPCRequestObjectParams
    var id: String
}

struct OauthResult: Codable {
    var returnUri: String
}

struct OauthError: Codable {
    var code: Int
    var message: String
}

struct JSONRPCResponse: Codable {
    var jsonrpc: String = "2.0"
    var result: OauthResult
    var id: String = "temp"
}

struct JSONRPCErrorResponse: Codable {
    var jsonrpc: String = "2.0"
    var error: OauthError
    var id: String = "temp"
}

/**
 Generates a String of JS code that is to be evaluated when the Oauth capture activity is finished and we have the response to notify Connect with
 - parameters:
    - jsonRPCResponseData: The Data for the response object that we are emitting to Connect via the SmartcarSDKResponse CustomEvent
 */
public func getOauthCaptureCompletionJavascript(jsonRPCResponseData: Data) -> String {
    let jsonRPCResponseString = String(data: jsonRPCResponseData, encoding: .utf8)

    return """
        dispatchEvent(new CustomEvent('SmartcarSDKResponse', { detail: JSON.parse('\(jsonRPCResponseString!)') }))
    """
}
