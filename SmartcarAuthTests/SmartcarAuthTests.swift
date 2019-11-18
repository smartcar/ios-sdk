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
    let vin = "12345678901234"
    let code = UUID().uuidString

    func completion(code: String?, state: String?, err: AuthorizationError?) -> Void {
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSmartcarAuthGenerateAuthUrl() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: completion(code:state:err:))
        
        let builder = smartcar.generateAuthUrl()
        
        expect(builder).to(beAnInstanceOf(SCURLBuilder.self))
    }

    func testHandleCallbackSuccess() {
        func completionCheck(code: String?, state: String?, err: AuthorizationError?) -> Void {
            expect(code).to(equal(self.code))
            expect(state).to(beNil())
            expect(err).to(beNil())
        }
        
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
                expect(code).to(equal(self.code))
                expect(state).to(beNil())
                expect(err).to(beNil())
        })
        
        let urlString = redirectUri + "?code=" + code
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackSuccessWithState() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(equal(self.code))
            expect(state).to(equal(self.state))
            expect(err).to(beNil())
        })
        
        let urlString = redirectUri + "?code=" + code + "&state=" + state
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackAccessDenied() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("User denied access to the requested scope of permissions."))
            expect(err?.type).to(equal(.accessDenied))
            expect(err?.vehicleInfo).to(beNil())
        })
        
        let urlString = redirectUri + "?error=access_denied&error_description=User%20denied%20access%20to%20the%20requested%20scope%20of%20permissions."
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackVehicleIncompatible() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("The user's vehicle is not compatible."))
            expect(err?.type).to(equal(.vehicleIncompatible))
            expect(err?.vehicleInfo?.make).to(equal(self.make))
            expect(err?.vehicleInfo?.model).to(equal("Model 3"))
            expect(err?.vehicleInfo?.vin).to(equal(self.vin))
            expect(err?.vehicleInfo?.year).to(equal(2019))
        
        })

        let urlString = redirectUri + "?error=vehicle_incompatible&error_description=The%20user\'s%20vehicle%20is%20not%20compatible.&make=" + make + "&model=Model%203&year=2019&vin=" + vin
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackInvalidSubscription() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("The user's subscription is invalid."))
            expect(err?.type).to(equal(.invalidSubscription))
            expect(err?.vehicleInfo).to(beNil())
        })

        let urlString = redirectUri + "?error=invalid_subscription&error_description=The%20user\'s%20subscription%20is%20invalid."
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackUnrecognizedError() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("I'm an unidentified error."))
            expect(err?.type).to(equal(.unknownError))
            expect(err?.vehicleInfo).to(beNil())
        })

        let urlString = redirectUri + "?error=blargh&error_description=I\'m%20an%20unidentified%20error."
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackMissingQueryParameters() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(beNil())
            expect(err?.type).to(equal(.missingQueryParameters))
            expect(err?.vehicleInfo).to(beNil())
        })

        let urlString = redirectUri
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackNoCode() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(beNil())
            expect(err?.type).to(equal(.missingAuthCode))
            expect(err?.vehicleInfo).to(beNil())
        })

        let urlString = redirectUri + "?test=blah"
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }

    func testLaunchAuthFlow() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            fail("Callback should not have been called")
        })


        class ViewControllerStub: UIViewController {
            var presentCount: Int = 0

            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
                presentCount = presentCount + 1
            }
        }

        let vc = ViewControllerStub()
        
        let authUrl = smartcar.generateAuthUrl().build()

        smartcar.launchAuthFlow(url: authUrl, viewController: vc)

        expect(vc.presentCount).to(equal(1))
    }

}
