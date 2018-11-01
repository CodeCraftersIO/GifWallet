//
//  Created by Pierluigi Cifani on 18/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import XCTest
@testable import GifWallet

class GIFWalletViewControllerTests: SnapshotTest {
    
    func testGIFWalletViewController() {
        let vc = GIFWalletViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        waitABitAndVerify(viewController: navigationController)
    }
}
