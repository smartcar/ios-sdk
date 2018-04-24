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
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completion: {
            error, code, state in
            
            fail("Calback should not have been called")
            
        })
        
        let url = smartcarSdk.generateUrl(state: state, forcePrompt: true, showMock: true)
        
        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&scope=read_vehicle_info%2520read_odometer&approval_prompt=force&state=\(self.state)&mock=true"))
    }
    
    func testGenerateUrlDefaultValues() {
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            fail("Calback should not have been called")
        
        })
        
        let url = smartcarSdk.generateUrl(state: "", forcePrompt: true, showMock: true)
        
        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&approval_prompt=force&mock=true"))
    }
    
    func testResumeAuthFlowNoQueryParameters() {
        let exp = expectation(description: "Completion should've been called with an error")
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            expect(error).toNot(beNil())
            
            exp.fulfill()
            
            return nil
        })
        
        let url = URL(string: "https://localhost:8000")!
        
        smartcarSdk.resumeAuthFlow(with: url)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testResumeAuthFlowNoCode() {
        
        let exp = expectation(description: "Completion should've been called with an error")
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            expect(error).toNot(beNil())
            
            exp.fulfill()
            
            return nil
        })
        
        let url = URL(string: "https://localhost:8000?state=fakeState")!
        
        smartcarSdk.resumeAuthFlow(with: url)
        
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
        
        smartcarSdk.resumeAuthFlow(with: url)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testLaunchAuthFlow() {
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completion: {
            error, code, state in
            
            fail("Calback should not have been called")
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
