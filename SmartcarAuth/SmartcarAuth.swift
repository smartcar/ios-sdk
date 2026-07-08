/*
 SmartcarAuth.swift
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
import SafariServices

/**
Smartcar Authentication SDK for iOS written in Swift 5.
    - Facilitates the authorization flow to launch the flow and retrieve an authorization code
*/
@objcMembers public class SmartcarAuth: NSObject {
    var applicationId: String
    var redirectUri: String?
    var scope: [String]?
    var responseType: String
    var completionHandler: (_ code: String?, _ state: String?, _ virtualKeyUrl: String?, _ userId: String?, _ externalId: String?, _ error: AuthorizationError?) -> Void
    var mode: SCMode?
    @available(*, deprecated, message: "Use mode instead")
    var testMode: Bool

    private static let validResponseTypes = ["code", "none"]

    /**
    Constructor for the SmartcarAuth
    - parameters:
        - applicationId: The application's application ID
        - redirectUri: Optional. The application's redirect URI. Required when `responseType` is `"code"`. If required but not specified, uses default set in the Smartcar developer dashboard
        - scope: Optional. An array of authorization scopes. If not specified, fall backs to defaults set in the Smartcar developer dashboard.
        - responseType: Optional, determines whether Connect completes the flow via redirect (`"code"`) or via the `complete` RPC (`"none"`). Defaults to `"code"`.
        - completionHandler: Callback function called upon the completion of the Smartcar Connect
        - mode: Optional, determine what mode Smartcar Connect should be launched in. Should be one of .test, .live or .simulated. If none specified, defaults to live mode.
    */
    public init(
        applicationId: String,
        redirectUri: String? = nil,
        scope: [String]? = nil,
        responseType: String = "code",
        completionHandler: @escaping (String?, String?, String?, String?, String?, AuthorizationError?) -> Void,
        mode: SCMode? = nil
    ) {
        precondition(
            SmartcarAuth.validResponseTypes.contains(responseType),
            "responseType must be one of: \(SmartcarAuth.validResponseTypes.joined(separator: ", "))"
        )
        precondition(
            responseType != "code" || !(redirectUri ?? "").isEmpty,
            "redirectUri is required when responseType is \"code\""
        )
        self.applicationId = applicationId
        self.redirectUri = redirectUri
        self.scope = scope
        self.responseType = responseType
        self.completionHandler = completionHandler
        self.testMode = false
        self.mode = mode
    }

    /**
    Deprecated. Use `init(applicationId:redirectUri:scope:responseType:completionHandler:mode:)` instead.
    - parameters:
        - applicationId: The application's application ID
        - redirectUri: The application's redirect URI. Must be a valid URI.
        - scope: Optional. An array of authorization scopes. If not specified, fall backs to defaults set in the Smartcar developer dashboard.
        - completionHandler: Callback function called upon the completion of the Smartcar Connect
        - mode: Optional, determine what mode Smartcar Connect should be launched in. Should be one of .test, .live or .simulated. If none specified, defaults to live mode.
    */
    @available(*, deprecated, renamed: "init(applicationId:redirectUri:scope:responseType:completionHandler:mode:)")
    public init(
        applicationId: String,
        redirectUri: String,
        scope: [String]? = nil,
        completionHandler: @escaping (String?, String?, String?, String?, AuthorizationError?) -> Void,
        mode: SCMode? = nil
    ) {
        self.applicationId = applicationId
        self.redirectUri = redirectUri
        self.scope = scope
        self.responseType = "code"
        self.completionHandler = { code, state, virtualKeyUrl, userId, _, error in
            completionHandler(code, state, virtualKeyUrl, userId, error)
        }
        self.testMode = false
        self.mode = mode
    }

    /**
    Deprecated. Use `init(applicationId:redirectUri:scope:responseType:completionHandler:mode:)` instead.
    - parameters:
        - clientId: The application's client ID
        - redirectUri: The application's redirect URI. Must be a valid URI.
        - scope: An array of authorization scopes
        - completionHandler: Callback function called upon the completion of the Smartcar Connect
        - testMode: Deprecated, please use `mode` instead. Optional, launch the Smartcar auth flow in test mode when set to true. Defaults to false.
        - mode: Optional, determine what mode Smartcar Connect should be launched in. Should be one of .test, .live or .simulated. If none specified, defaults to live mode.
    */
    @available(*, deprecated, renamed: "init(applicationId:redirectUri:scope:responseType:completionHandler:mode:)")
    public init(
        clientId: String,
        redirectUri: String,
        scope: [String]? = nil,
        completionHandler: @escaping (String?, String?, String?, AuthorizationError?) -> Void,
        testMode: Bool = false,
        mode: SCMode? = nil
    ) {
        self.applicationId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.responseType = "code"
        self.completionHandler = { code, state, virtualKeyUrl, _, _, error in
            completionHandler(code, state, virtualKeyUrl, error)
        }
        self.testMode = testMode
        self.mode = mode
    }

    /**
     Helper method to generate a SCURLBuilder instance, which then can be used (with various setters) to build an auth URL
        See `SCURLBuilder` for a full list of query parameters that can be set on the authorization URL
    */
    public func authUrlBuilder() -> SCUrlBuilder {
        let resolvedMode = mode ?? (testMode ? .test : .live)
        return SCUrlBuilder(applicationId: applicationId, redirectUri: redirectUri, scope: scope ?? [], mode: resolvedMode, responseType: responseType)
    }

    /**
     Starts the launch of Smartcar Connect.

     - parameters:
        - authUrl: the authorization URL for Smartcar Connect. Use `SCURLBuilder` to generate a auth URL
        - viewController: The view controller responsible for presenting the Connect flow
    */
    public func launchAuthFlow(url: String, viewController: UIViewController) {
        let authUrl = URL(string: url)!
        let redirectUrl = redirectUri.flatMap { URL(string: $0) }
        let redirectUriHost = redirectUrl?.host

        let connectVC = ConnectController(
            authUrl: authUrl,
            redirectUriHost: redirectUriHost,
            handleCallback: handleCallback,
            onCompleteResult: receiveDirectResult
        )
        viewController.present(connectVC, animated: true)
    }

    /**
    Builds and delivers the final `completionHandler` response, shared by both the
    redirect callback path (`handleCallback`) and the `complete` RPC path (`receiveDirectResult`).
    */
    private func buildAndDeliverResponse(
        code: String?,
        state: String?,
        virtualKeyUrl: String?,
        userId: String?,
        externalId: String?,
        error: String?,
        errorDescription: String?,
        statusCode: String?,
        errorMessage: String?,
        vin: String?,
        make: String?
    ) {
        let authorizationError: AuthorizationError

        let vehicle: VehicleInfo?
        if let vin = vin {
            vehicle = VehicleInfo(vin: vin, make: make)
        } else {
            vehicle = nil
        }

        if let error = error {
            switch error {
            case "vehicle_incompatible":
                authorizationError = AuthorizationError(type: .vehicleIncompatible, errorDescription: errorDescription, vehicleInfo: vehicle)
            case "invalid_subscription":
                authorizationError = AuthorizationError(type: .invalidSubscription, errorDescription: errorDescription)
            case "access_denied":
                authorizationError = AuthorizationError(type: .accessDenied, errorDescription: errorDescription)
            case "no_vehicles":
                authorizationError = AuthorizationError(type: .noVehicles, errorDescription: errorDescription)
            case "configuration_error":
                authorizationError = AuthorizationError(type: .configurationError, errorDescription: errorDescription, statusCode: statusCode, errorMessage: errorMessage)
            case "server_error":
                authorizationError = AuthorizationError(type: .serverError, errorDescription: errorDescription)
            case "user_manually_returned_to_application", "user_cancelled":
                authorizationError = AuthorizationError(type: .userExitedFlow, errorDescription: errorDescription)
            default:
                authorizationError = AuthorizationError(type: .unknownError, errorDescription: errorDescription)
            }
            return self.completionHandler(nil, state, nil, nil, externalId, authorizationError)
        }

        // response_type=none succeeds without a code; only treat "no code" as
        // success when the flow was configured for it.
        if code == nil && responseType != "none" {
            let authorizationError = AuthorizationError(type: .missingAuthCode, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, state, nil, nil, externalId, authorizationError)
        }

        return self.completionHandler(code, state, virtualKeyUrl, userId, externalId, nil)
    }

    /**
    Authorization callback function. Verifies that no error occurred during the OAuth process and extracts the auth code, state string, virtualKeyUrl, and userId upon success. Invokes the completion function with either the code or an error (and state, virtualKeyUrl, and/or userId if included).
    - parameters:
        - url: callback URL containing authorization code or an error
    */
    public func handleCallback(callbackUrl: URL) {
        let urlComp = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
        guard let query = urlComp?.queryItems else {
            let authorizationError = AuthorizationError(type: .missingQueryParameters, errorDescription: nil, vehicleInfo: nil)
            return self.completionHandler(nil, nil, nil, nil, nil, authorizationError)
        }

        func param(_ name: String) -> String? { query.first(where: { $0.name == name })?.value }

        buildAndDeliverResponse(
            code: param("code"),
            state: param("state"),
            virtualKeyUrl: param("virtual_key_url"),
            userId: param("user_id"),
            externalId: param("external_id"),
            error: param("error"),
            errorDescription: param("error_description"),
            statusCode: param("status_code"),
            errorMessage: param("error_message"),
            vin: param("vin"),
            make: param("make")
        )
    }

    /**
    Receives the result of a redirect-less Smartcar Connect flow delivered over the
    `complete` JSON-RPC message, and invokes the completion function the same way
    `handleCallback` does for the redirect-based flow.
    - parameters:
        - params: the parsed `complete` RPC params
    */
    public func receiveDirectResult(params: CompleteParams) {
        buildAndDeliverResponse(
            code: params.code,
            state: params.state,
            virtualKeyUrl: params.virtualKeyUrl,
            userId: params.userId,
            externalId: params.externalId,
            error: params.error,
            errorDescription: params.errorDescription,
            statusCode: nil,
            errorMessage: nil,
            vin: params.vin,
            make: params.make
        )
    }

}
