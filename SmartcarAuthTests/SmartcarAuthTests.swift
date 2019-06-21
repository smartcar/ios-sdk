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
    let make = "Tesla"

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

    func testGenerateUrlAllOptionalParametersIncluded() {
        let testVehicle = VehicleInfo(make: make)
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope,  development: true, completion: {
            error, code, state in

            fail("Callback should not have been called")

        })

        let url = smartcarSdk.generateUrl(state: state, forcePrompt: true, vehicleInfo: testVehicle)

        expect(url).to(equal("https://connect.smartcar.com/oauth/authorize?response_type=code&client_id=\(self.clientId)&redirect_uri=\(self.redirectUri)&scope=read_vehicle_info%20read_odometer&approval_prompt=force&state=\(self.state)&mode=test&make=\(self.make)"))
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
            
            let expectedError = AuthorizationError(type: .missingQueryParameters, errorDescription: nil,
                                                   vehicleInfo: nil)
            expect(error).to(matchError(expectedError))

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
    
    func testHandleCallbackBadParameters() {
        let exp = expectation(description: "Completion should've been called with an error")
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            let expectedError = AuthorizationError(type: .missingAuthCode, errorDescription: nil,
                                                   vehicleInfo: nil)
            expect(error).to(matchError(expectedError))
            
            exp.fulfill()
            
            return nil
        })
        
        let url = URL(string: "https://localhost:8000?hello=hello")!
        
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
            
            let expectedError = AuthorizationError(type: .missingAuthCode, errorDescription: nil,
                                                   vehicleInfo: nil)
            expect(error).to(matchError(expectedError))

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
            
            let expectedError = AuthorizationError(type: .accessDenied, errorDescription: "User denied access to application.", vehicleInfo: nil)
            expect(error).to(matchError(expectedError))

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
    
    func testHandleCallbackDefaultError() {
        let exp = expectation(description: "Completion should've been called with an error")
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            let expectedError = AuthorizationError(type: .accessDenied, errorDescription: "User denied access to application.", vehicleInfo: nil)
            expect(error).to(matchError(expectedError))
            
            exp.fulfill()
            
            return nil
        })
        
        let url = URL(string: "https://example.com/home?error=fake_error&error_description=User+denied+access+to+application.&state=0facda3319")!
        
        smartcarSdk.handleCallback(with: url)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testHandleCallbackVehicleIncompatible() {
        let exp = expectation(description: "Completion should've been called with an error")
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            let expectedError = AuthorizationError(type: .vehicleIncompatible, errorDescription: "The user's vehicle is not compatible.", vehicleInfo: nil)
            expect(error).to(matchError(expectedError))
            
            exp.fulfill()
            
            return nil
        })
        
        let url = URL(string: "https://example.com/home?error=vehicle_incompatible&error_description=The+user's+vehicle+is+not+compatible.&state=0facda3319")!
        
        smartcarSdk.handleCallback(with: url)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                fail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testHandleCallbackVehicleIncompatibleWithVehicle() {
        let exp = expectation(description: "Completion should've been called with an error")
        
        let smartcarSdk = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, completion: {
            error, code, state in
            
            let expectedVehicle = VehicleInfo(vin: "0000", make: "CHEVROLET", year: 2010, model: "CAMARO")
            let expectedError = AuthorizationError(type: .vehicleIncompatible, errorDescription: "The user's vehicle is not compatible.", vehicleInfo: expectedVehicle)
            
            expect(error).to(matchError(expectedError))
            exp.fulfill()
            
            return nil
        })
        
        let url = URL(string: "https://example.com/home?error=vehicle_incompatible&error_description=The+user's+vehicle+is+not+compatible.&vin=0000&make=CHEVROLET&model=Camaro&year=2010")!
        
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
