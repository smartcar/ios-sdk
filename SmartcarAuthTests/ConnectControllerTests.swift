//
//  ConnectControllerTests.swift
//  SmartcarAuthTests
//
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Nimble
import XCTest
import WebKit

@testable import SmartcarAuth

// Records each navigation policy decision so tests can assert on what Connect's links did.
private class RecordingConnectController: ConnectController {
    var decisions: [(url: URL?, policy: WKNavigationActionPolicy)] = []

    override func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        super.webView(webView, decidePolicyFor: navigationAction) { policy in
            self.decisions.append((navigationAction.request.url, policy))
            decisionHandler(policy)
        }
    }
}

private class StubNavigationAction: WKNavigationAction {
    private let stubRequest: URLRequest
    init(url: URL) { stubRequest = URLRequest(url: url) }
    override var request: URLRequest { stubRequest }
}

class ConnectControllerTests: XCTestCase {
    private let connectURL = URL(string: "https://connect.smartcar.com/")!
    private let teslaURL = URL(string: "https://www.tesla.com/_ak/smartcar.com")!

    private var window: UIWindow!
    private var controller: RecordingConnectController!
    private var openedURLs: [URL] = []
    private var callbackURLs: [URL] = []

    override func setUp() {
        super.setUp()
        openedURLs = []
        callbackURLs = []
        controller = RecordingConnectController(authUrl: URL(string: "about:blank")!,
                                                redirectUriHost: "example.com",
                                                handleCallback: { [unowned self] in self.callbackURLs.append($0) })
        controller.openExternally = { [unowned self] in self.openedURLs.append($0) }

        // The web view only loads content while it's in a window.
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
    }

    override func tearDown() {
        window = nil
        controller = nil
        super.tearDown()
    }

    // Loads a stand-in Connect page containing a single link with id="link".
    private func loadPage(withLink attributes: String) {
        controller.webView.loadHTMLString("<html><body><a id=\"link\" \(attributes)>link</a></body></html>",
                                          baseURL: connectURL)
        // The first page load in a test run can be slow while WebKit spins up its web process.
        var ready = false
        func poll() {
            controller?.webView.evaluateJavaScript("document.getElementById('link') != null") { result, _ in
                if (result as? Bool) == true {
                    ready = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: poll)
                }
            }
        }
        poll()
        expect(ready).toEventually(beTrue(), timeout: .seconds(30))
    }

    private func clickLink(andWaitUntil condition: @escaping () -> Bool) {
        controller.webView.evaluateJavaScript("document.getElementById('link').click()", completionHandler: nil)
        expect(condition()).toEventually(beTrue(), timeout: .seconds(5))
    }

    func testBlankTargetLinkOpensExternallyAndKeepsConnectPage() {
        loadPage(withLink: "target=\"_blank\" href=\"\(teslaURL.absoluteString)\"")

        clickLink(andWaitUntil: { !self.openedURLs.isEmpty })

        expect(self.openedURLs).to(equal([teslaURL]))
        expect(self.controller.decisions.last?.url).to(equal(teslaURL))
        expect(self.controller.decisions.last?.policy).to(equal(.cancel))
        expect(self.controller.webView.url).to(equal(connectURL))
        expect(self.callbackURLs).to(beEmpty())
    }

    func testSameFrameLinkNavigatesInPlace() {
        let nextURL = URL(string: "https://connect.smartcar.com/next")!
        loadPage(withLink: "href=\"\(nextURL.absoluteString)\"")

        clickLink(andWaitUntil: { self.controller.decisions.last?.url == nextURL })

        expect(self.controller.decisions.last?.policy).to(equal(.allow))
        expect(self.openedURLs).to(beEmpty())
    }

    func testBlankTargetRedirectStillHandledAsCallback() {
        let redirectURL = URL(string: "https://example.com/callback?code=abc")!
        loadPage(withLink: "target=\"_blank\" href=\"\(redirectURL.absoluteString)\"")

        clickLink(andWaitUntil: { !self.callbackURLs.isEmpty })

        expect(self.callbackURLs).to(equal([redirectURL]))
        expect(self.openedURLs).to(beEmpty())
    }

    func testCreateWebViewOpensExternallyAndDeclinesNewWebView() {
        let newWebView = controller.webView(controller.webView,
                                            createWebViewWith: WKWebViewConfiguration(),
                                            for: StubNavigationAction(url: teslaURL),
                                            windowFeatures: WKWindowFeatures())

        expect(newWebView).to(beNil())
        expect(self.openedURLs).to(equal([teslaURL]))
    }

    func testCreateWebViewIgnoresNonWebSchemes() {
        let newWebView = controller.webView(controller.webView,
                                            createWebViewWith: WKWebViewConfiguration(),
                                            for: StubNavigationAction(url: URL(string: "javascript:alert(1)")!),
                                            windowFeatures: WKWindowFeatures())

        expect(newWebView).to(beNil())
        expect(self.openedURLs).to(beEmpty())
    }
}
