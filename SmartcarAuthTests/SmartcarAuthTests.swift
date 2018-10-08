//
//  SmartcarAuthTests.swift
//  SmartcarAuthTests
//
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Nimble
import XCTest
@testable import SmartcarAuth

class SmartcarAuthTests: XCTestCase {
    let clientId = UUID().uuidString
    let redirectUri = "http://localhost.com"
    let state = UUID().uuidString
    let scope = ["read_vehicle_info", "read_odometer"]

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGenerateUrl() {

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope,  development: true, completion: {
            error, code, state in

            fail("Callback should not have been called")

        })

        let url = smartcarSdk.generateUrl(state: state, forcePrompt: true)

        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&scope=read_vehicle_info%20read_odometer&approval_prompt=force&state=\(self.state)&mode=test"))
    }

    func testGenerateUrlTestModeOverrideFalse() {

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope,  development: true, testMode: false, completion: {
            error, code, state in

            fail("Callback should not have been called")

        })

        let url = smartcarSdk.generateUrl(state: state, forcePrompt: true)

        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&scope=read_vehicle_info%20read_odometer&approval_prompt=force&state=\(self.state)&mode=live"))
    }

    func testGenerateUrlTestModeOverrideTrue() {

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope,  development: false, testMode: true, completion: {
            error, code, state in

            fail("Callback should not have been called")

        })

        let url = smartcarSdk.generateUrl(state: state, forcePrompt: true)

        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&scope=read_vehicle_info%20read_odometer&approval_prompt=force&state=\(self.state)&mode=test"))
    }

    func testGenerateUrlDefaultValues() {
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in

            fail("Callback should not have been called")

        })

        let url = smartcarSdk.generateUrl()

        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&approval_prompt=auto&mode=live"))
    }

    func testHandleCallbackNoQueryParameters() {
        let exp = expectation(description: "Completion should've been called with an error")

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in

            expect(error).to(matchError(AuthorizationError.missingQueryParameters))

            exp.fulfill()

            return nil
        })

        let url = URL(string: "https://localhost:8000")!

        smartcarSdk.handleCallback(with: url)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testHandleCallbackNoCode() {

        let exp = expectation(description: "Completion should've been called with an error")

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in

            expect(error).to(matchError(AuthorizationError.missingAuthCode))

            exp.fulfill()

            return nil
        })

        let url = URL(string: "https://localhost:8000?state=fakeState")!

        smartcarSdk.handleCallback(with: url)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testHandleCallbackAccessDenied() {

        let exp = expectation(description: "Completion should've been called with an error")

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in

            expect(error).to(matchError(AuthorizationError.accessDenied))

            exp.fulfill()

            return nil
        })

        let url = URL(string: "https://example.com/home?error=access_denied&error_description=User+denied+access+to+application.&state=0facda3319")!

        smartcarSdk.handleCallback(with: url)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testResumeAuthFlowSuccess() {

        let exp = expectation(description: "Completion should be called")

        let code = UUID().uuidString
        let url = URL(string: "https://localhost:8000?code=\(code)&state=\(self.state)")!

        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, authCode, state in

            expect(error).to(beNil())
            expect(authCode).to(equal(code))
            expect(state).to(equal(self.state))

            exp.fulfill()

            return nil

        })

        smartcarSdk.handleCallback(with: url)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testLaunchAuthFlow() {
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completion: {
            error, code, state in

            fail("Callback should not have been called")
        })

        class ViewControllerStub: UIViewController {
            var presentCount: Int = 0

            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
                presentCount = presentCount + 1
            }
        }

        let vc = ViewControllerStub()

        smartcarSdk.launchAuthFlow(viewController: vc)

        expect(vc.presentCount).to(equal(1))
    }

}
