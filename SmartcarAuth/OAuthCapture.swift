/*
 OAuthCapture.swift
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
import UIKit


/**
 Responsible for:
 
 - Injecting JavaScript that lets Connect communicate back to the native SDK (via `SmartcarSDK.sendMessage`).
 - Responding to the JS messages (WKScriptMessageHandler).
 - Starting an ASWebAuthenticationSession for the OEM login flow.
 - Capturing the OEM callback or error, then sending a JS event back to the web context.
 */
@objcMembers
public class OAuthCapture: NSObject, WKScriptMessageHandler {
    
    private weak var webView: WKWebView?
    private var session: Session?
    
    /**
     Creates an instance of `OAuthCapture` which:
       - Sets up the JS injection (`window.SmartcarSDK.sendMessage`) in the provided WKWebView.
       - Registers itself as the script message handler named "SmartcarSDK".
     */
    public init(webView: WKWebView) {
        self.webView = webView
        super.init()
        
        // Add the message handler so we can receive `window.webkit.messageHandlers.SmartcarSDK.postMessage(...)`
        webView.configuration.userContentController.add(self, name: "SmartcarSDK")
        
        // Inject JS into the webview
        let javascript = WKUserScript(
            source: getJavascript(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        webView.configuration.userContentController.addUserScript(javascript)
    }
    
    /**
     Required delegate function to handle messages posted from JavaScript code
     (`SmartcarSDK.sendMessage`).
     
     This will:
      - Parse the JSON-RPC request from JS.
      - Start the OEM login flow using ASWebAuthenticationSession.
     */
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        
        guard let bodyString = message.body as? String,
              let rpcObjectData = bodyString.data(using: .utf8),
              let rpcObject = try? JSONDecoder().decode(RPCRequestObject.self, from: rpcObjectData)
        else {
            return
        }
        
        // OEM authorize URL
        guard let authorizeURL = URL(string: rpcObject.params.authorizeURL),
              let interceptPrefixURL = URL(string: rpcObject.params.interceptPrefix)
        else {
            return
        }
        
        // Use the intercept prefix's scheme for the callbackURLScheme
        let interceptPrefixScheme = interceptPrefixURL.scheme
        
        // Start an ASWebAuthenticationSession to handle the OEM login
        let authSession = ASWebAuthenticationSession(url: authorizeURL,
                                                     callbackURLScheme: interceptPrefixScheme,
                                                     completionHandler: webAuthSessionCompletion)
        
        // Required for iOS 13+ to present the session
        if #available(iOS 13.0, *) {
            authSession.presentationContextProvider = self
        }
        
        self.session = authSession
        self.session?.start()
    }
    
    /**
     The completion handler for the ASWebAuthenticationSession.
     If successful, a success JSON-RPC response is sent back to the web context.
     If canceled or errored, an error JSON-RPC response is sent instead.
     */
    private func webAuthSessionCompletion(callbackURL: URL?, error: Error?) {
        // If an error, or no valid callbackURL, return JSON-RPC error to webview JS
        guard error == nil, let callback = callbackURL else {
            let canceledLoginCode = ASWebAuthenticationSessionError.canceledLogin.rawValue
            let jsonRPCError: OauthError
            
            switch error?._code {
            case canceledLoginCode:
                // The user canceled the login
                jsonRPCError = OauthError(code: -32000, message: "OAuth capture cancelled")
            default:
                // Some other error
                jsonRPCError = OauthError(code: -32603, message: "Internal JSONRPC error")
            }
            
            let jsonRPCErrorResponse = JSONRPCErrorResponse(error: jsonRPCError)
            if let data = try? JSONEncoder().encode(jsonRPCErrorResponse),
               let webView = self.webView {
                webView.evaluateJavaScript(
                    getOauthCaptureCompletionJavascript(jsonRPCResponseData: data),
                    completionHandler: nil
                )
            }
            return
        }
        
        // If successful, return the redirect URL in a JSON-RPC success response
        let result = OauthResult(returnUri: callback.absoluteString)
        let jsonRPCResponse = JSONRPCResponse(result: result)
        
        if let data = try? JSONEncoder().encode(jsonRPCResponse),
           let webView = self.webView {
            webView.evaluateJavaScript(
                getOauthCaptureCompletionJavascript(jsonRPCResponseData: data),
                completionHandler: nil
            )
        }
    }
    
    /**
     Returns a JS snippet that creates a global `SmartcarSDK` object
     with a `sendMessage` method to pass data from JS -> iOS.
     */
    private func getJavascript() -> String {
        return """
        (() => {
            window.SmartcarSDK = {};
            window.SmartcarSDK.sendMessage = (rpcString) => {
                window.webkit.messageHandlers.SmartcarSDK.postMessage(rpcString);
            };
        })();
        """
    }
}


// Required if we want to provide a default browser window so that developers don't have to (so that they can use ASWebAuthenticationSession)
@available(iOS 13, *)
extension OAuthCapture: ASWebAuthenticationPresentationContextProviding {
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
