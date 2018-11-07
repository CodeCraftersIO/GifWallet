//
//  GIFCreateViewControllerTests.swift
//  GifWalletTests
//
//  Created by Jordi Serra i Font on 07/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
@testable import GifWallet

class GIFCreateViewControllerTests: SnapshotTest {

    func testBasicLayout() {
        let vc = GIFCreateViewController.Factory.viewController()
        debug(viewController: vc)
    }
}
