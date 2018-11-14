//
//  Created by Pierluigi Cifani on 14/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
import Deferred

extension XCTestCase {
    func waitForTask<T>(_ task: Task<T>) throws -> T {
        var capturedValue: T?
        var capturedError: Error?
        let exp = expectation(description: "Task completes")
        task.upon(.main) { (result) in
            switch result {
            case .success(let value):
                capturedValue = value
                exp.fulfill()
            case .failure(let error):
                exp.fulfill()
                capturedError = error
            }
        }
        waitForExpectations(timeout: 3)
        guard capturedError == nil else {
            throw capturedError!
        }

        guard let _capturedValue = capturedValue else {
            throw XCTestError(message: "No captured value")
        }
        return _capturedValue
    }
}

struct XCTestError: Error {
    let message: String
}
