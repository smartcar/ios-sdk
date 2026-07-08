//
//  SmartcarAuthVersionTests.swift
//  SmartcarAuthTests
//
//  Copyright © 2017 Smartcar Inc. All rights reserved.
//

import Nimble
import XCTest

@testable import SmartcarAuth

class SmartcarAuthVersionTests: XCTestCase {
    func testVersionMatchesPodspec() {
        let testFileUrl = URL(fileURLWithPath: #filePath)
        let podspecUrl = testFileUrl
            .deletingLastPathComponent() // SmartcarAuthTests/
            .deletingLastPathComponent() // repo root
            .appendingPathComponent("SmartcarAuth.podspec")

        let podspec = try! String(contentsOf: podspecUrl, encoding: .utf8)
        let match = podspec.range(of: #"s\.version\s*=\s*'([^']+)'"#, options: .regularExpression)!
        let podspecVersion = podspec[match]
            .replacingOccurrences(of: #"s\.version\s*=\s*'"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "'", with: "")

        expect(SmartcarAuthVersion.current).to(equal(podspecVersion))
    }
}
