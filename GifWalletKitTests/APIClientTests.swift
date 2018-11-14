//
//  APIClientTests.swift
//  GifWalletKitTests
//
//  Created by Jordi Serra i Font on 13/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
import Deferred
@testable import GifWalletKit

class HTTPBinAPITests: XCTestCase {
    func testIPEndpoint() {
        let getIP = HTTPBin.API.ip
        XCTAssert(getIP.path == "/ip")
        XCTAssert(getIP.method == .GET)
    }
}

class APIClientTests: XCTestCase {

    var apiClient: HTTPBinAPIClient!
    
    override func setUp() {
        super.setUp()
        
        apiClient = HTTPBinAPIClient(environment: HTTPBin.Hosts.production)
    }
    
    func testGET() throws {
        let task = apiClient.fetchIPAddress()
        let response = try waitForTask(task)
        XCTAssert(response.origin.count > 0)
    }
    
    func testParseIPResponse() throws {
        let json =
            """
{
  "origin": "80.34.92.76"
}
"""
                .data(using: .utf8)!
        let task: Task<HTTPBin.Responses.IP> = apiClient.parseResponse(data: json)
        let response = try waitForTask(task)
        XCTAssert(response.origin == "80.34.92.76")
    }
}
