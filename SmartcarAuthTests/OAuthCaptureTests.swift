//
//  OAuthCaptureTests.swift
//  SmartcarAuthTests
//
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Nimble
import XCTest
import WebKit

@testable import SmartcarAuth

class OAuthCaptureTests: XCTestCase {
    var webView: WKWebView!

    override func setUp() {
        super.setUp()
        webView = WKWebView(frame: .zero)
    }

    override func tearDown() {
        webView = nil
        super.tearDown()
    }

    // Posts a raw JSON-RPC string straight to the "SmartcarSDK" message handler,
    // bypassing the injected JS shim so the test doesn't depend on page-load timing.
    private func postRawRpcMessage(_ json: String, onComplete: @escaping (CompleteParams) -> Void) -> OAuthCapture {
        let capture = OAuthCapture(webView: webView, onComplete: onComplete)
        let escaped = json.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        webView.evaluateJavaScript("window.webkit.messageHandlers.SmartcarSDK.postMessage('\(escaped)');", completionHandler: nil)
        return capture
    }

    func testCompleteMessageRoutesToOnCompleteAndNotStartOAuthCapture() {
        let expectation = self.expectation(description: "onComplete called with complete params")
        var receivedParams: CompleteParams?

        let rpc = """
        {"jsonrpc":"2.0","method":"complete","id":"1","params":{"code":"abc123","externalId":"ext-1"}}
        """

        let capture = postRawRpcMessage(rpc, onComplete: { params in
            receivedParams = params
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5)
        expect(receivedParams?.code).to(equal("abc123"))
        expect(receivedParams?.externalId).to(equal("ext-1"))
        _ = capture
    }

    func testOauthMessageDoesNotRouteToOnComplete() {
        // Regression check: an "oauth" message must still be decoded as RPCRequestObject
        // and dispatched to the OEM-login path, not onComplete. authorizeURL/interceptPrefix
        // are left empty so startOAuthCapture's URL guard fails fast, instead of actually
        // launching a system ASWebAuthenticationSession prompt during the test.
        let onCompleteCalled = self.expectation(description: "onComplete should not be called for an oauth message")
        onCompleteCalled.isInverted = true

        let rpc = """
        {"jsonrpc":"2.0","method":"oauth","id":"1","params":{"authorizeURL":"","interceptPrefix":""}}
        """

        let capture = postRawRpcMessage(rpc, onComplete: { _ in
            onCompleteCalled.fulfill()
        })

        waitForExpectations(timeout: 2)
        _ = capture
    }

    func testUnrecognizedMethodIsDroppedSilently() {
        let onCompleteCalled = self.expectation(description: "onComplete should not be called for an unrecognized method")
        onCompleteCalled.isInverted = true

        let rpc = """
        {"jsonrpc":"2.0","method":"something_unknown","id":"1","params":{}}
        """

        let capture = postRawRpcMessage(rpc, onComplete: { _ in
            onCompleteCalled.fulfill()
        })

        waitForExpectations(timeout: 2)
        _ = capture
    }
}
