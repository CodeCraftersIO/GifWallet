//
//  Created by Pierluigi Cifani on 28/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import XCTest
@testable import GifWalletKit

class DataStoreTests: XCTestCase {

    var dataStore: DataStore!

    override func setUp() {
        super.setUp()
        dataStore = DataStore(kind: .memory)
        let task = dataStore.loadAndMigrateIfNeeded()
        _ = try? waitForTask(task)
        XCTAssert(dataStore.storeIsReady)
    }

    func testCreateAndFetchGIF() throws {
        let id = "007"
        let createTask = dataStore.createGIF(
            giphyID: "007",
            title: "James Bond",
            subtitle: "GoldenEye",
            url: URL(string: "google.com/007")!,
            tags: ["007"]
        )
        _ = try waitForTask(createTask)
        
        guard let managedGIF = try dataStore.fetchGIF(id: id) else {
            throw Error.objectUnwrappedFailed
        }
        XCTAssert(managedGIF.giphyID == id)
        XCTAssert(managedGIF.title == "James Bond")
        XCTAssert(managedGIF.creationDate != nil)
    }

    enum Error: Swift.Error {
        case objectUnwrappedFailed
    }
}

