//
//  Created by Pierluigi Cifani on 30/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import XCTest
@testable import GifWallet

class GIFCreateViewControllerTests: SnapshotTest {
    func testBasicLayout() {
        recordMode = true
        let vc = GIFCreateViewController.Factory.viewController()
        waitABitAndVerify(viewController: vc)
    }
}
