/*
 ConnectController.swift
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
import WebKit
import UIKit

/**
 A controller responsible for:
 
 - Initializing and presenting the WKWebView.
 - Detecting redirects back to the application (via `webView(_:decidePolicyFor:decisionHandler:)`).
 - Invoking the callback closure when the application redirect is encountered.
 */
@objcMembers
public class ConnectController: NSObject, WKNavigationDelegate {
    public var webView: WKWebView!
    
    private var viewController: UIViewController
    private var authUrl: URL
    private var redirectUriHost: String
    private var handleCallback: (URL) -> Void
    
    // An instance of `OAuthCapture` which handles JS messaging and OEM login flow.
    private var oauthCapture: OAuthCapture?

    /**
     Initializes the ConnectController.
     - parameters:
       - viewController: the UIViewController responsible for presenting Smartcar Connect.
       - authUrl: the Connect URL to open in the WKWebView.
       - redirectUriHost: host of the redirect URI that was passed to SmartcarAuth.
       - handleCallback: callback function that is invoked upon redirect back to the application.
     */
    public init(viewController: UIViewController,
                authUrl: URL,
                redirectUriHost: String,
                handleCallback: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.authUrl = authUrl
        self.redirectUriHost = redirectUriHost
        self.handleCallback = handleCallback
        
        super.init()
        
        // Configure a WKWebView.
        let webviewConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(
            frame: CGRect(x: 0, y: 50,
                          width: Int(viewController.view.frame.width),
                          height: Int(viewController.view.frame.height)),
            configuration: webviewConfiguration
        )
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.navigationDelegate = self
        
        // Instantiate OAuthCapture (which handles script messaging + OEM flows)
        // and attach it to this webView's userContentController.
        self.oauthCapture = OAuthCapture(webView: self.webView)
    }
    
    /**
     Loads the Connect URL into the web view and presents it.
     */
    public func launchWebView() {
        let request = URLRequest(url: self.authUrl)
        self.webView.load(request)
        self.viewController.view.addSubview(webView)
    }
    
    /**
     WKNavigationDelegate method: listens for navigation changes.
     If the navigation is to the redirect URI (matching `redirectUriHost`),
     call the `handleCallback` and remove the webView from the view.
     */
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let host = navigationAction.request.url?.host,
              host == self.redirectUriHost else {
            // allow navigation in all other cases
            decisionHandler(.allow)
            return
        }
        
        // If the navigation is the app redirect, cancel and call back
        decisionHandler(.cancel)
        self.handleCallback(navigationAction.request.url!)
        
        // Remove the webView from the view
        self.webView.removeFromSuperview()
    }
}
