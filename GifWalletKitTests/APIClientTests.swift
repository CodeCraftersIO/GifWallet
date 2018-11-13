//
//  APIClientTests.swift
//  GifWalletKitTests
//
//  Created by Jordi Serra i Font on 13/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
@testable import GifWalletKit

enum HTTPBinHosts: Environment {
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

enum HTTPBinEndpoints: Endpoint {
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

class HTTPBinAPITests: XCTestCase {
    func testIPEndpoint() {
        let getIP = HTTPBinEndpoints.ip
        XCTAssert(getIP.path == "/ip")
        XCTAssert(getIP.method == .GET)
    }
}

class APIClientTests: XCTestCase {

    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        
        apiClient = APIClient(environment: HTTPBinHosts.development)
    }
    
    func testGET() {
        apiClient.performRequest(forEndpoint: HTTPBinEndpoints.ip)
    }

}
