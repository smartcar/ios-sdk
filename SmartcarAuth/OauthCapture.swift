/*
 OauthCapture.swift
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
import AuthenticationServices

/**
 Class for the OauthCapture that will launch a webview for the specified auth URL, open an ASWebAuthenticationSession for a specified OEM, and process the redirect from Connect
 */
@objcMembers public class OauthCapture: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    var webView: WKWebView!
    var viewController: UIViewController
    var authUrl: URL
    var redirectUriHost: String
    var handleCallback: (URL) -> Void
    
    private var session: Session?
    /**
     Constructor for OauthCapture
     - parameters:
        - viewController: the UIViewController responsible for presenting Connect
        - authUrl: the Connect URL to open
        - redirectUriHost: host of the redirect URI that was passed to SmartcarAuth
        - handleCallback: callback function from SmartcarAuth that verifies that no error occured during the OAuth process and extracts the auth code, state string, and virtualKeyUrl upon success. Invokes the completion function with either the code or an error (and state and/or virtualKeyUrl if included).
     */
    public init(viewController: UIViewController, authUrl: URL, redirectUriHost: String, handleCallback: @escaping (URL) -> Void) {
        self.authUrl = authUrl
        self.redirectUriHost = redirectUriHost
        self.viewController = viewController
        self.handleCallback = handleCallback
        
        super.init();
        
        
        let webviewConfiguration = WKWebViewConfiguration()
        webviewConfiguration.userContentController.add(self, name: "SmartcarSDK")
        self.webView = WKWebView(frame: CGRect(x: 0, y:50, width: Int((viewController.view.frame.width)), height: Int((viewController.view.frame.height))), configuration: webviewConfiguration)
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.navigationDelegate = self
        
        // String of JS code to that SmartcarSDK object to the webview's window object
        let javascript = WKUserScript(
            source: getJavascript(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        
        // adds the JS code to the webview
        self.webView.configuration.userContentController.addUserScript(javascript)
    }
    
    /**
     Listens to changes in the navigation to determine if the redirect from Connect has happened. If so, call the handleCallback function and close the webview
     */
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // detect changes in the URL host, stop navigation and call the callback handler if we've redirected back to the application's redirect uri
        guard let host = navigationAction.request.url?.host,
              host == self.redirectUriHost else {
            // allow navigation in all other cases
            decisionHandler(.allow)
            return
        }
        // do not continue navigating to the redirect URI
        decisionHandler(.cancel)
        
        self.handleCallback(navigationAction.request.url!)
        
        self.webView.removeFromSuperview()
    }
    
    /**
     Generates a String of JS code that adds a `SmartcarSDK` object to the `window` of the webview with a `sendMessage` method. This method when called from the Connect JS will pass the RPC string to the iOS SDK so that we can launch the OEM's auth flow.
     */
    private func getJavascript() -> String {
        return  """
                (() => {
                    window.SmartcarSDK = {};
                    window.SmartcarSDK.sendMessage = (rpcString) => {
                        window.webkit.messageHandlers.SmartcarSDK.postMessage(rpcString);
                    };
                })();
                """
    }

    /**
    Launches the webview to begin the Smartcar Connect flow
     */
    public func launchWebView() {
        let myRequest = URLRequest(url: self.authUrl)
        self.webView.load(myRequest)
        self.viewController.view.addSubview(webView)
    }

    /**
     Handles the response from the OEM after the ASWebAuthenticationSession is finished. Either the callback URL (in the success case) or an error is packaged into a JSONRPC response object, and then we evaluate JS in the webview to emit it as part of a CustomEvent to notify Connect that the OEM login process has finished and wtih what results
     */
    private func webAuthSessionCompletion(callback: URL?, error: Error?) -> Void {
        // handle error cases
        guard error == nil, let callback = callback else {
            let canceledLoginCode = ASWebAuthenticationSessionError.canceledLogin.rawValue
            let jsonRPCError: OauthError

            switch error?._code {
                case canceledLoginCode:
                    // set error object with cancel code
                    jsonRPCError = OauthError(code: -32000, message: "OAuth capture cancelled")
                default:
                    // set error object with generic error
                    jsonRPCError = OauthError(code: -32603, message: "Internal JSONRPC error")
            }
            // run javascript to send error object
            let jsonRPCErrorResponse = JSONRPCErrorResponse(error: jsonRPCError)
            let jsonRPCResponseData = try! JSONEncoder().encode(jsonRPCErrorResponse)
            self.webView.evaluateJavaScript(getOauthCaptureCompletionJavascript(jsonRPCResponseData: jsonRPCResponseData), completionHandler: nil)
            return
        }
        
        // handle successful response
        let result = OauthResult(returnUri: callback.absoluteString)
        let jsonRPCResponse = JSONRPCResponse(result: result)
        let jsonRPCResponseData = try! JSONEncoder().encode(jsonRPCResponse )
        
        // run javascript to send result object
        self.webView.evaluateJavaScript(getOauthCaptureCompletionJavascript(jsonRPCResponseData: jsonRPCResponseData), completionHandler: nil)
    }
    
    /**
     Recieves the SmartcarSDK message when the custom JS injected into the webview is called by Connect. Launches the ASWebAuthenticationSession for login with the OEM.
     */
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // turn message.body into RPCRequestObject
        guard let rpcObjectData = (message.body as! String).data(using: .utf8),
              let rpcObject = try? JSONDecoder().decode(RPCRequestObject.self, from: rpcObjectData) else {
            return
        }
        
        let authorizeURL = URL(string: rpcObject.params.authorizeURL)!
        
        let interceptPrefixURL = URL(string: rpcObject.params.interceptPrefix)!
        let interceptPrefixScheme = interceptPrefixURL.scheme
        
        let authSession = ASWebAuthenticationSession.init(url: authorizeURL, callbackURLScheme: interceptPrefixScheme, completionHandler: webAuthSessionCompletion)
        // this is required for the browser to open in iOS 13 and above
        authSession.presentationContextProvider = self
        self.session = authSession
        
        // start OEM auth flow using ASWebAuthenticationSession
        self.session?.start()
    }
}

// Required if we want to provide a default browser window so that developers don't have to (so that they can use ASWebAuthenticationSession)
@available(iOS 13, *)
extension OauthCapture: ASWebAuthenticationPresentationContextProviding {
    /**
        Provides a default window to act as the presentation anchor for the authentication session
     */
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first ?? ASPresentationAnchor()
    }
}


private protocol Session {
    @discardableResult
    func start() -> Bool
}

@available(iOS 12.0, *)
extension ASWebAuthenticationSession: Session {
}
