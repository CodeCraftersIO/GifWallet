//
//  GiphyAPIClientTests.swift
//  GifWalletKitTests
//
//  Created by Jordi Serra i Font on 14/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
@testable import GifWalletKit

class GiphyAPIClientTests: XCTestCase {
    
    var apiClient: GiphyAPIClient!
    
    override func setUp() {
        super.setUp()
        apiClient = GiphyAPIClient()
    }
    
    func testGetTrending() throws {
        let task = apiClient.fetchTrending()
        _ = try self.waitForTask(task)
    }
    
    func testSearchTerm() throws {
        let task = apiClient.searchGif(term: "hello")
        _ = try self.waitForTask(task)
    }
    
}
