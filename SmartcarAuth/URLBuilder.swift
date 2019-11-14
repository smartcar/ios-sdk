//
//  URLBuilder.swift
//  SmartcarAuth
//
//  Created by Smartcar on 11/7/19.
//  Copyright © 2019 SmartCar Inc. All rights reserved.
//

import Foundation

@objc public class URLBuilder: NSObject {
    private var components: URLComponents
    private var queryItems: [URLQueryItem] = []
    
    @objc public init(auth: SmartcarAuth) {
        self.components = URLComponents()
        self.components.scheme = "https"
        self.components.host = "connect.smartcar.com"
        self.components.path = "/oauth/authorize"
    
        self.queryItems.append(contentsOf: [
            URLQueryItem(name: "client_id", value: auth.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "mode", value: auth.testMode ? "test" : "live")
        ])

        if let redirectUri = auth.redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
        }
        
        if !auth.scope.isEmpty {
            let scopeString = auth.scope.joined(separator: " ")
            self.queryItems.append(URLQueryItem(name: "scope", value: scopeString))
        }
    }
    
    @objc public func setState(state: String) -> URLBuilder {
        if (!state.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "state", value: state))
        }
        return self
    }
    
    @objc public func setForcePrompt(forcePrompt: Bool) -> URLBuilder {
        self.queryItems.append(URLQueryItem(name: "approval_prompt", value: forcePrompt ? "force" : "auto"))
        return self
    }
    
    @objc public func setMakeBypass(make: String) -> URLBuilder {
        if (!make.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "make", value: make))
        }
        return self
    }
    
    @objc public func setSingleSelect(singleSelect: Bool) -> URLBuilder {
        self.queryItems.append(URLQueryItem(name: "single_select", value: singleSelect.description))
        return self
    }
    
    @objc public func setSingleSelectVin(vin: String) -> URLBuilder {
        if (!vin.isEmpty) {
            self.queryItems.append(URLQueryItem(name: "single_select_vin", value: vin))
        }
        return self
    }
    
    @objc public func build() -> URL {
        self.components.queryItems = self.queryItems
        return self.components.url!
    }
}
