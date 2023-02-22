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
        
        let builder = smartcar.authUrlBuilder()
        
        expect(builder).to(beAnInstanceOf(SCUrlBuilder.self))
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
    
    func testHandleCallbackNoVehicles() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("User does not have any vehicles connected to this connected services account"))
            expect(err?.type).to(equal(.noVehicles))
            expect(err?.vehicleInfo).to(beNil())
        })

        let urlString = redirectUri + "?error=no_vehicles&error_description=User%20does%20not%20have%20any%20vehicles%20connected%20to%20this%20connected%20services%20account"
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackConfigurationError() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("There has been an error in the configuration of your application."))
            expect(err?.type).to(equal(.configurationError))
            expect(err?.vehicleInfo).to(beNil())
            expect(err?.statusCode).to(equal("400"))
            expect(err?.errorMessage).to(equal("You have entered a test mode VIN. Please enter a VIN that belongs to a real vehicle."))
        })

        let urlString = redirectUri + "?error=configuration_error&error_description=There%20has%20been%20an%20error%20in%20the%20configuration%20of%20your%20application.&status_code=400&error_message=You%20have%20entered%20a%20test%20mode%20VIN.%20Please%20enter%20a%20VIN%20that%20belongs%20to%20a%20real%20vehicle."
        
        let url = URL(string: urlString)!
        
        smartcar.handleCallback(callbackUrl: url)
    }
    
    func testHandleCallbackServerError() {
        let smartcar = SmartcarAuth(clientId: clientId, redirectUri: redirectUri, scope: scope, completionHandler: { code, state, err in
            expect(code).to(beNil())
            expect(state).to(beNil())
            
            expect(err?.errorDescription).to(equal("Unexpected server error. Please try again."))
            expect(err?.type).to(equal(.serverError))
            expect(err?.vehicleInfo).to(beNil())
            expect(err?.statusCode).to(beNil())
            expect(err?.errorMessage).to(beNil())
        })

        let urlString = redirectUri + "?error=server_error&error_description=Unexpected%20server%20error.%20Please%20try%20again."
        
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
        
        let authUrl = smartcar.authUrlBuilder().build()

        smartcar.launchAuthFlow(url: authUrl, viewController: vc)

        expect(vc.presentCount).to(equal(0))
    }

}
