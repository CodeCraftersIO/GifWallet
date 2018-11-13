//
//  APIClientTests.swift
//  GifWalletKitTests
//
//  Created by Jordi Serra i Font on 13/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
@testable import GifWalletKit

fileprivate enum HTTPBin {
    fileprivate enum Hosts: Environment {
        case production
        case development
        
        var baseURL: URL {
            switch self {
            case .production:
                return URL(string: "https://httpbin.org")!
            case .development:
                return URL(string: "https://dev.httpbin.org")!
            }
        }
    }
    
    fileprivate enum Endpoints: Endpoint {
        case ip
        case orderPizza
        
        var path: String {
            switch self {
            case .ip:
                return "/ip"
            case .orderPizza:
                return "/forms/post"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .ip:
                return .GET
            case .orderPizza:
                return .POST
            }
        }
    }
    
    fileprivate enum Responses {
        struct IP: Decodable {
            let origin: String
        }
    }
}

class HTTPBinAPITests: XCTestCase {
    func testIPEndpoint() {
        let getIP = HTTPBin.Endpoints.ip
        XCTAssert(getIP.path == "/ip")
        XCTAssert(getIP.method == .GET)
    }
}

class APIClientTests: XCTestCase {

    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        
        apiClient = APIClient(environment: HTTPBin.Hosts.production)
    }
    
    func testGET() {
        let exp = expectation(description: "Fetch completes")
        
        apiClient.performRequest(forEndpoint: HTTPBin.Endpoints.ip) { (data, error) in
            XCTAssert(data != nil)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    
    func testParseIPResponse() throws {
        let json =
            """
{
  "origin": "80.34.92.76"
}
"""
                .data(using: .utf8)!
        guard let response: HTTPBin.Responses.IP = try? apiClient.parseResponse(data: json) else {
            XCTFail("Response threw error")
            return
        }
        XCTAssert(response.origin == "80.34.92.76")
    }


}
