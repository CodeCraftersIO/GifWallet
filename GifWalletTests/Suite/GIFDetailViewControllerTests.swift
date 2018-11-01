//
//  Created by Pierluigi Cifani on 18/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import XCTest
@testable import GifWallet

class GIFDetailViewControllerTests: SnapshotTest {

    func testGIFWalletViewController() {
        let vc = GIFDetailsViewController(gifID: "NK1")
        vc.presenter = {
            let presenter = GIFDetailsViewController.MockDataPresenter()
            presenter.delaySeconds = 0
            return presenter
        }()
        let navigationController = UINavigationController(rootViewController: vc)
        waitABitAndVerify(viewController: navigationController)
    }
}
