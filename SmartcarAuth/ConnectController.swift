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
import SmartcarFramework

/**
 A view controller responsible for:
 
 - Initializing and presenting the WKWebView.
 - Detecting redirects back to the application (via `webView(_:decidePolicyFor:decisionHandler:)`).
 - Invoking the callback closure when the application redirect is encountered.
 */
@objcMembers
public class ConnectController: UIViewController, WKNavigationDelegate {
    public var webView: WKWebView!

    private var authUrl: URL
    private var redirectUriHost: String
    private var handleCallback: (URL) -> Void

    // An instance of `OAuthCapture` which handles JS messaging and OEM login flow.
    private var oauthCapture: OAuthCapture?
    private var bleService: SmartcarFramework.BLEService?


    /**
     Initializes the ConnectController.
     
     - Parameters:
       - authUrl: The Connect URL to open in the WKWebView.
       - redirectUriHost: Host of the redirect URI that was passed to SmartcarAuth.
       - handleCallback: Callback function that is invoked upon redirect back to the application.
     */
    public init(authUrl: URL,
                redirectUriHost: String,
                handleCallback: @escaping (URL) -> Void) {
        self.authUrl = authUrl
        self.redirectUriHost = redirectUriHost
        self.handleCallback = handleCallback
        super.init(nibName: nil, bundle: nil)
    }

    // Required initializer for using storyboard/XIB (not used here)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    /**
     Loads the Connect URL into the web view and presents it.
     */
    private func setupWebView() {
        let webviewConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webviewConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        // Enable inspection for debug builds
        #if DEBUG
        if #available(iOS 16.4, *) {
          webView.isInspectable = true
        }
        #endif

        // Constrain the webView to the safe area
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Instantiate OAuthCapture (which handles script messaging + OEM flows)
        oauthCapture = OAuthCapture(webView: webView)
        
        // Set up BLEService
        let webViewHandler = SmartcarFramework.WebViewBridgeImpl(
            webView: webView,
            interfaceName: "SmartcarSDKBLE"
        )
        let contextBridge = SmartcarFramework.ContextBridgeImpl()
        bleService = SmartcarFramework.BLEService(context: contextBridge, webView: webViewHandler)
        injectSdkShimJavascript(webView: webView, channelName: "SmartcarSDKBLE")
        
        // Start web view
        let request = URLRequest(url: authUrl)
        webView.load(request)
    }

    /**
     WKNavigationDelegate method: listens for navigation changes.
     If the navigation is to the redirect URI (matching `redirectUriHost`),
     call the `handleCallback` and remove the webView from the view.
     */
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Intercept sc-sdk URLs and open system page
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("sc-sdk://") {
            // Extract the part after the scheme
            let systemPage = String(url.absoluteString.dropFirst("sc-sdk://".count))
            SmartcarFramework.ContextBridgeImpl().openSystemPage(page: systemPage)
            decisionHandler(.cancel)
            return
        }

        guard let url = navigationAction.request.url,
              let host = url.host,
              host == self.redirectUriHost else {
            // Allow navigation in all other cases
            decisionHandler(.allow)
            return
        }
        
        // If the navigation is the app redirect, cancel and handle callback
        decisionHandler(.cancel)
        self.handleCallback(url)
        
        // Dismiss the ConnectController
        self.dismiss(animated: true, completion: nil)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Destroy BLE service
        bleService?.dispose()
        // Tear down WebView
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        webView?.configuration.userContentController.removeAllScriptMessageHandlers()
    }
}
