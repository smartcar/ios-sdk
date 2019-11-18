/*
SCURLBuilder.swift
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


@objcMembers public class SCURLBuilder: NSObject {
    private var components: URLComponents
    private var queryItems: [URLQueryItem] = []

    public init(clientId: String, redirectUri: String, scope: [String], testMode: Bool) {
        self.components = URLComponents()
        self.components.scheme = "https"
        self.components.host = "connect.smartcar.com"
        self.components.path = "/oauth/authorize"

        self.queryItems.append(contentsOf: [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "mode", value: testMode ? "test" : "live")
        ])

        if let redirectUri = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
        }

        if !scope.isEmpty {
            let scopeString = scope.joined(separator: " ")
            self.queryItems.append(URLQueryItem(name: "scope", value: scopeString))
        }
    }

    public func setState(state: String) -> SCURLBuilder {
        if (!state.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "state", value: state))
        }
        return self
    }

    public func setForcePrompt(forcePrompt: Bool) -> SCURLBuilder {
        self.queryItems.append(URLQueryItem(name: "approval_prompt", value: forcePrompt ? "force" : "auto"))
        return self
    }

    public func setMakeBypass(make: String) -> SCURLBuilder {
        if (!make.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "make", value: make))
        }
        return self
    }

    public func setSingleSelect(singleSelect: Bool) -> SCURLBuilder {
        self.queryItems.append(URLQueryItem(name: "single_select", value: singleSelect.description))
        return self
    }

    public func setSingleSelectVin(vin: String) -> SCURLBuilder {
        if (!vin.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "single_select_vin", value: vin))
        }
        return self
    }

    public func build() -> String {
        self.components.queryItems = self.queryItems
        return self.components.url!.absoluteString
    }

}
